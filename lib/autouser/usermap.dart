
// // ignore_for_file: deprecated_member_use, unused_import, unnecessary_cast, prefer_interpolation_to_compose_strings, unused_local_variable, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/autouser/userhome.dart';
import 'package:appointments/autouser/userlogin.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:latlong2/latlong.dart' as latlng;

class userMapscreen extends StatefulWidget {
 
  const userMapscreen( {Key? key, required this. autoclick,required this.autoadmin,required this.AutouserId, required this. userhometomap, required this.adminuserid}) : super(key: key);
 final bool autoclick;
 final bool userhometomap;
 final bool autoadmin;
 final String? AutouserId;
 final String? adminuserid;
  @override
  State<userMapscreen> createState() => _userMapscreenState();
}

class _userMapscreenState extends State<userMapscreen> {
  List<Marker> markers = [];
  List<String> userIdList = [];
  List<String> adminresourceIdlist = [];
  List<String> admindevicetokenList = [];
  Position? position;
  MapController mapController = MapController();
 


 
 final String SubAuto="Auto";
    TextEditingController name = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  final bool _mounted = false;


    List<Marker> automarkers = [];
   List<Marker> usermarkers=[];
   
  Stream<Position>? _currentPosition;
 
 String? Domain='';
  String? SubDomain='';
  String? userId='';

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }


 Timer?pagerefresh;
  void pagerefreshmethod() {
   
    pagerefresh = Timer.periodic(Duration(seconds: 10), (timer) {
    _AutofetchMarkerPositions();
    });
  }
  @override
  void initState() {
    super.initState();
    pagerefreshmethod;
    _fetchCurrentPosition();
   widget.autoclick? _initializeMarkers():print("no autos for users");
  widget. userhometomap?_initializeautoMarkers():print("your auto");
  }
    @override
  void dispose() {
    pagerefresh?.cancel();
    super.dispose();
  }

  Future<void> _initializeMarkers() async {
    await _fetchCurrentPosition();
    if (position != null) {
      await _AutofetchMarkerPositions();
      setState(() {});
    }
  }
   Future<void> _initializeautoMarkers() async {
    await _fetchCurrentPosition();
    if (position != null) {
      await whereisauto();
      setState(() {});
    }
  }

  Future<void> _fetchCurrentPosition() async {
    try {
      final currentposition = await _getCurrentPosition();
      position = currentposition;
    } catch (e) {
      print('Error fetching current position: $e');
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

     String? adminDomain;
     String? adminSubDomain;
 getShareduserId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('SubDomain');
    }
  Future<void> _AutofetchMarkerPositions() async {
    try {
    
      getShareduserId();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('SubDomain');
print("Domain:$Domain");
    print("SubDomain:$SubDomain");
      markers.clear();
      userIdList.clear();
      adminresourceIdlist.clear();
      admindevicetokenList.clear();

      final response = await http.get(Uri.parse(
        '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=1&f1_field=Live_S&f1_op=eq&f1_value=true'
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];

        for (final dynamic source in sources) {
          final Map<String, dynamic> prodata = jsonDecode(source);

          if (prodata.containsKey('currentlocation') &&
              prodata.containsKey('business name') &&
              prodata.containsKey('address') &&
              prodata.containsKey('about business') &&
              prodata.containsKey('gender')) {
            double? lat = prodata['currentlocation']?['currentlat']?.toDouble();
            double? lon = prodata['currentlocation']?['currentlon']?.toDouble();
            final String businessName = prodata['business name'].toString();
            final String Name = prodata['name'].toString();
            final String address = prodata['address'].toString();
            String adminmobileno = prodata['mobileno'].toString();
            final String aboutBusiness = prodata['about business'].toString();
            final String gender = prodata['gender'].toString();
            String adminId = prodata['userId']['\$oid'].toString();
            userIdList.add(adminId);
            String adminresourceId = prodata['_id']['\$oid'].toString();
            adminresourceIdlist.add(adminresourceId);
            String admindevicetoken = prodata['deviceToken'] ?? '';
            admindevicetokenList.add(admindevicetoken);
             adminDomain = prodata['domain'] ?? '';
            adminSubDomain = prodata['subdomain'] ?? '';
          String  Live = prodata['Live'] ?? '';
  prefs.setString('AutoSubDomain',adminSubDomain!);
            if (lat != null && lon != null&&Live=="true") {
              double distance = calculateDistance(
                position!.latitude,
                position!.longitude,
                lat,
                lon,
              );

              print("Marker $Name is $distance km away from current location.");

              if (distance <= 2) {
                markers.add(
                  Marker(
                    point: LatLng(lat, lon),
                    child:  IconButton(
                      iconSize: 100,
                      onPressed: () {
                        _AutoshowMarkerInfoDialog(
                          context,
                          prodata['name'],
                          double.parse(prodata['feedback'] ?? "0"),
                          prodata['registrationno'],
                          prodata['gender'],
                          adminId,
                          prodata['mobileno'],
                          () => createProfile(context, adminId, admindevicetoken, Name, adminmobileno, adminresourceId),
                        );
                      },
                      icon: Image.asset(
                        "assets/autohd.png",
                        height: 400,
                        width: 800,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                );
              } else {
                print("Marker $Name is more than 2 km away, not adding.");
              }
            } else {
              print("Current location is missing for marker $Name.");
            }
  
          // Print each value one by one

          print("adminDomain: $adminDomain");
          
          print("adminSubDomain: $adminSubDomain");
            print("Response Body: $responseBody");
            print("Name: $Name");
            print("Gender: $gender");
            print("Latitude: $lat");
            print("Longitude: $lon");
            print("Business Name: $businessName");
            print("Address: $address");
            print("About Business: $aboutBusiness");
            print("AutoUser IDs: $userIdList");
            print("Auto resourceIDs: $adminresourceIdlist");
            print("AutoUser device tokens: $admindevicetokenList");
            print("position!.latitude: ${position!.latitude}");
            print("position!.longitude: ${position!.longitude}");
            print("lat: $lat");
            print("lon: $lon");
            print("admindomani:$adminDomain");
            print("adminsubdomain:$adminSubDomain");
          }
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching marker positions: $e');
    }
  }
   Future<void> salooncreateProfile(String adminId) async {
    try {
      print("goingggggggggggggggggggggggg");
       String? token = await notificationServices.getDeviceToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? mobileno = prefs.getString('mobileno') ?? "";
      String? storedName = prefs.getString('username');
      String? USERId = prefs.getString('userId');
      String SubDomain = prefs.getString('SubDomain') ?? "";
        String Domain = prefs.getString('domain') ?? "";
      print(SubDomain);
      print(USERId);
   

      final response = await http.post(
        Uri.parse(
            "https://broadcastmessage.mannit.co/mannit/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$USERId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "mobileno": phoneno.text,
          "mobileno": mobileno,
          "name": storedName,
          "shopname": name,
          "userdeviceToken": token,
          "adminId":adminId,
          "admindeviceTocken":"",
          "business name": SubDomain,
          "status": "true",
          "condition": "waiting",
          // "currentTime": _currentDateTime,
          // "currentDate": curr,
          "currentDate": "${DateFormat('dd/MM/yy').format(_currentDateTime)}",
          "currentTime":"${DateFormat('hh:mm a').format(_currentDateTime)}",
        }),
      );

      if (response.statusCode == 200) {
        // Successfully created the profile, handle the response accordingly
        print('User created successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => userhome(userhometomap: false,
              
                  )),
        );
        snackbar_green(context, "Appoinment  Booked Successfully ");
        print(response.body);

        try {
          var responseData = jsonDecode(response.body);
          // print(_currentDateTime);
          print('Response body: $responseData');

          if (responseData['message'] == 'Resource Created Successfully') {
            var source = jsonDecode(responseData['source']);
          //  sendNotification();
            print('Profile created Successfully');
          } else {
            print('Response message is not "Resource Created Successfully".');
          }
        } catch (e) {
          print('Error decoding response: $e');
        }
      } else {
        // Failed to create the profile, handle the error accordingly
        print('Failed to create user. Status code: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // Handle any other errors that might occur during the API call
      print('Error in create user API: $e');
    }
  }

 List<Map<String, dynamic>> Countdata = [];
  void fetchDataCount() async {
    try {
      DateTime currentDate = DateTime.now();
      // print(name);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String Domain = prefs.getString('domain') ?? "";
        String SubDomain = prefs.getString('SubDomain') ?? "";
      String? adminId = prefs.getString('adminid') ?? "";
      print(adminId);
      // Format the date according to your API URL format (assuming dd/MM/yy)
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
      final fetch =
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=status_S&f2_op=eq&f2_value=true&f3_field=adminId_S&f3_op=eq&f3_value=$adminId';
      //&f3_field=shopname_S&f3_op=eq&f3_value=$name';

      final response = await http.get(Uri.parse(fetch));

      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        Countdata.clear();
        // Check if the response data is in the expected format
        if (responseBody.containsKey('message') &&
            responseBody['message'] == 'Successfully Searched' &&
            responseBody.containsKey('source')) {
          List<dynamic> sources = responseBody['source'];

          // Check if there are entries for the specified shopname and today's date
          if (sources.isNotEmpty) {
            // setState(() {
            Countdata.clear();
            // Update salonData with the parsed source data
            Countdata = List<Map<String, dynamic>>.from(
                sources.map((source) => jsonDecode(source)));
            // Display the length of Countdata
            print('Countdata length: ${Countdata.length}');
            //  });
          } else {
            // Print a message if no entries are found for the specified criteria
            print('No entries found for shopname  and today\'s date.');
          }
        } else {
          // Print an error message if the response data does not contain the expected fields
          print('Unexpected response format: $responseBody');
        }
      } else {
        // Print an error message if the response status code is not 200
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Print an error message if an exception occurs
      print('Error fetching data: $e');
    }
  }
 List<LatLng> polylineCoordinates = [];
Future<void> _saloonfetchMarkerPositions() async {
    // if (_initialFetchDone) return;
    try {
      // setState(() {
      //   isLoading = true; // Start loading
      // });
  
      print("salooooooooooooooooooooooooooon maarkers");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String selectedGender = prefs.getString('selectedGender') ?? "";
      // String selecteduni = prefs.getString('unisex') ?? "";
      String businesstype = prefs.getString('SubDomain') ?? "";
         String Domain = prefs.getString('domain') ?? "";
      // print(selecteduni);
      print(selectedGender);
      print(businesstype);
      String logoAssetPath = selectedGender == 'Male'
          ? "assets/mensaloon.jpg"
          : selectedGender == 'Female'
              ? "assets/femalesaloon.jpg"
              : "assets/unisaloon.jpg";
      String apiUrl = '';

      // Modify the API URL based on the category
      if (businesstype == 'Saloon') {
        apiUrl =
            "https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$businesstype&filtercount=3&f1_field=gender_S&f1_op=eq&f1_value=$selectedGender&f2_field=business name_S&f2_op=eq&f2_value=$businesstype&f3_field=Live_S&f3_op=eq&f3_value=true";
        //'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$cat&filtercount=3&f1_field=gender_S&f1_op=eq&f1_value=$selectedGender&f2_field=_S&f2_op=eq&f2_value=Saloon&f3_field=Live_S&f3_op=eq&f3_value=true';
      } else if (businesstype == 'Clinic') {
        apiUrl =
            'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$businesstype&filtercount=2&f1_field=category_S&f1_op=eq&f1_value=Clinic&f2_field=Live_S&f2_op=eq&f2_value=true';
      } else if (businesstype == 'Pets') {
        apiUrl =
            'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$businesstype&filtercount=2&f1_field=category_S&f1_op=eq&f1_value=Pets&f2_field=Live_S&f2_op=eq&f2_value=true';
      } else {
        throw Exception('Invalid category');
      }
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];
        markers.clear();

        print(response.body);
        setState(() {
          for (final dynamic source in sources) {
            final Map<String, dynamic> prodata = jsonDecode(source);
            if (prodata.containsKey('location') &&
                prodata.containsKey('business name') &&
                prodata.containsKey('shop address') &&
                prodata.containsKey('about business') &&
                prodata.containsKey('userId') &&
                prodata.containsKey('_id') &&
                prodata.containsKey('feedback') &&
                //prodata.containsKey('category') &&
                prodata.containsKey('DeviceToken') &&
                prodata.containsKey('gender')) {
              double? lat = prodata['location']?['lat'];
              double? lon = prodata['location']?['lon'];
              if (lat != null && lon != null) {
                polylineCoordinates.add(latlng.LatLng(lat, lon));

                final String businessName = prodata['business name'].toString();
                final String address = prodata['shop address'].toString();
                final String aboutBusiness =
                    prodata['about business'].toString();
                final String id = prodata['_id']['\$oid'].toString();
                final String profiD = prodata['userId']['\$oid'].toString();
                final String admintoken = prodata['DeviceToken'].toString();
                final String gender = prodata['gender'].toString();
                   final String adminname = prodata['name'].toString();
                double feedback = double.parse(prodata['feedback'] ?? "2.0");
                final String mobileno = prodata['mobileno'].toString();
                final String shopname = prodata['shopname'].toString();
                print(admintoken);
                print(profiD);
                print(id);
                print("Location lat:$lat");
                  print("Location lon:$lon");
                print(id);
                prefs.setString('adminmobile', mobileno);
                 prefs.setString('adminname', adminname);
                
                prefs.setString('adminid', profiD);
                prefs.setString('business name', businessName);
                prefs.setString('id', id);
                 prefs.setString('shopname', shopname);
                prefs.setString('gender', gender);
                final Admintoken = prefs.setString('admintoken', admintoken);
                if (position != null) {
                  final userLat = position!.latitude;
                  final userLon = position!.longitude;
                  final distance = Distance().distance(
                    LatLng(userLat, userLon),
                    LatLng(lat!, lon!),
                  );
   // 13.099823761029572, 80.02236316123232
                  // Only add marker if it's within 2km
               //  if (distance < 2000) {
                    markers.add(
                      Marker(
                        point: 
                        LatLng(lat, lon),
                                              // LatLng(13.099823761029572, 80.02236316123232),

                        child: GestureDetector(
                          onTap: () {
                            if (businesstype == "Saloon") {
                              _showMarkerInfoDialog1(
                                context,
                                prodata['name'],
                                prodata['shop address'],
                                prodata['business name'],
                                prodata['mobileno'],
                                prodata['about business'],
                                double.parse(prodata['feedback'] ?? "0.0"),
                                prodata['DeviceToken'],
                                prodata['userId']['\$oid'],
                                prodata['_id']['\$oid'],
                                Countdata,
                                prodata['gender'],
                                () => salooncreateProfile(profiD),
                                  prodata['shopname'],
                              );
                            
                             }
                          },
                          child: businesstype == "Saloon"
                              ? CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      radius: 51,
                                      child: Image.asset(
                                        logoAssetPath,
                                        width: 60,
                                        height: 60,
                                      )),
                                )
                          
                              : businesstype == "Clinic"
                                  ? CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 50,
                                      child: Image.asset(
                                        color: Colors.white,
                                        "assets/hos.png",
                                        height: 70,
                                        width: 70,
                                      ),
                                    )
                                  : businesstype == "Pets"
                                      ? Icon(
                                          Icons.location_on,
                                          size: 40,
                                          color:
                                              Color.fromARGB(255, 253, 200, 66),
                                        )
                                      : Icon(
                                          Icons.location_on,
                                          size: 40,
                                          color:
                                              Color.fromARGB(255, 230, 26, 26),
                                        ),
                        ),
                      ),
                    );
                  }
                }
              }
            }
       // }
         
        });
      } else {
        // setState(() {
        //   isLoading = false;
        // });
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // setState(() {
      //   isLoading = false;
      // });
      print('Error fetching marker positions: $e');
    } finally {
     
    }
  }

 double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Radius of the Earth in kilometers
  double dLat = (lat2 - lat1) * (pi / 180.0);
  double dLon = (lon2 - lon1) * (pi / 180.0);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180.0)) *
          cos(lat2 * (pi / 180.0)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c; // Distance in kilometers
}


  
 String? AutouserId='';
   

String? username='';
String?usermobile='';
DateTime _currentDateTime = DateTime.now(); // Initialize the currentDateTime
Future<void> createProfile(context,String adminId,String admindeviceToken,String adminname,String adminmobilno,String adminresourceId) async {

  
  
    try {

       String? deviceToken = await notificationServices.getDeviceToken();

      final SharedPreferences prefs =
                await SharedPreferences.getInstance();
              //  final objectId = prefs.getString('userobjectId');
                final userId = prefs.getString('userId');
            username=prefs.getString("username");
           usermobile=prefs.getString("usermobileno");
           
      final response = await http.post(
        Uri.parse(createProfileUrl(userId, adminDomain, adminSubDomain)), // Append objectId to the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno":usermobile,
          "business name":adminSubDomain,
          "name": username,
          "adminId":adminId,
          "adminresourceId":adminresourceId,
          "adminname":adminname,
           "adminmobileno":adminmobilno,
          "currentDate": "${DateFormat('dd/MM/yy').format(_currentDateTime)}",
          "currentTime":"${DateFormat('hh:mm a').format(_currentDateTime)}",
          "userdeviceToken":deviceToken,
          "admindeviceToken":admindeviceToken,
          "location":{
            "currentlat":position!.latitude,
            "currentlon":position!.longitude,
          },
          "appointment":"request",
        }),
      );

      if (response.statusCode == 200) {
       
        
       
   
        try {
          var responseData = jsonDecode(response.body);

         
     //   sendNotificationtoadmin(admindeviceToken ,username!);
          if (responseData['message'] == 'Resource Created Successfully') {
             sendNotificationtoadmin( username!,admindeviceToken,); 
          print('Response body: $responseData');
 snackbar_green(context, "Auto Booked Successfully ");
        
        // Successfully created the profile, handle the response accordingly
        print('User created successfully');
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const userhome(userhometomap: true,)),
            );
            var source = jsonDecode(responseData['source']);

   // Extract the required data
          String createdUserId = source['userId']['\$oid'];
          String createdProfileId = source['_id']['\$oid'];
          String createdName = source['name'];
          String createdMobileNo = source['mobileno'];
           String domain = source['domain'];
            String subdomain = source['subdomain'];

          // Store the extracted data in SharedPreferences
          await prefs.setString('createdUserId', createdUserId);
          await prefs.setString('createdProfileId', createdProfileId);
          await prefs.setString('createdName', createdName);
          await prefs.setString('createdMobileNo', createdMobileNo);

            await prefs.setString('adminDomain:', domain);
            await prefs.setString('adminSubDomain', subdomain);

            print('Profile created Successfully');
            print("subdomain$subdomain");
            print("domain:$domain");
          } else {
            print('Response message is not "Resource Created Successfully".');
          }
        } catch (e) {
          print('Error decoding response: $e');
        }
      } else {
        // Failed to create the profile, handle the error accordingly
        print('Failed to create user. Status code: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // Handle any other errors that might occur during the API call
      print('Error in create user API: $e');
    }
  }

Future<void> sendNotificationtoadmin(
String username,String admindeviceToken,
  ) async {
   print("sendNotificationtoadmin:$admindeviceToken") ;
     print("sendNotificationtoadmin name:$username") ;  
  // Your FCM server key
  String serverKey = 'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';
  
  // Firebase FCM endpoint
  final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  
  // Headers for authorization and content type
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };
  
  // Payload for the notification
  final Map<String, dynamic> notificationData = {
    'notification': {
      'title': "New Booking",
    'body': 'A new booking has been made for $username', // Include username in the notification body
    },
  //'to':"dd2pCRHKQHu_M1ru8Wsq1-:APA91bGhlWJOsiUauAe3CGyvDSEpalX_MUVjqbKlLhcRMXU1r3om0vhu_fBAx8HS23GCfWc0UOh1_I5brurrekvjsV-URqYQ2k1Y1Kr6Ts3qfloRM-sp5RViO-MTYX5t4W7o7TTR5uDA",
   'to': admindeviceToken, // Use deviceIds list to send notifications to multiple devices
  };
  
  // Send the notification via HTTP POST request
  final http.Response response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(notificationData),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification. Status code: ${response.statusCode}');
  }
}

Future<void> whereisauto() async {
  try {
    automarkers.clear(); // Clear existing markers
    userIdList.clear(); // Clear existing userIds
    adminresourceIdlist.clear(); // Clear existing admin resource IDs
    admindevicetokenList.clear(); // Clear existing admin device tokens

    final response = await http.get(Uri.parse('$base_url/eSearch?domain=$proDomain&subdomain=Auto&userId=${widget.adminuserid}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> sources = responseBody['source'];

      for (final dynamic source in sources) {
        final Map<String, dynamic> prodata = jsonDecode(source);

        // Check if the data contains necessary fields
        if (prodata.containsKey('currentlocation') &&
            prodata.containsKey('business name') &&
            prodata.containsKey('address') &&
            prodata.containsKey('about business') &&
            prodata.containsKey('gender')) {
          double? lat = prodata['currentlocation']?['currentlat']?.toDouble();
          double? lon = prodata['currentlocation']?['currentlon']?.toDouble();
          final String businessName = prodata['business name'].toString();
          final String name = prodata['name'].toString();
          final String address = prodata['address'].toString();
          String adminmobileno = prodata['mobileno'].toString();
          final String aboutBusiness = prodata['about business'].toString();
          final String gender = prodata['gender'].toString();
          String adminId = prodata['userId']['\$oid'].toString(); // Extracting userId
          userIdList.add(adminId); // Store userId in the list
          String adminresourceId = prodata['_id']['\$oid'].toString(); // Extracting userId
          adminresourceIdlist.add(adminresourceId);
          String admindevicetoken = prodata['deviceToken'] ?? ''; // Extracting userId
          admindevicetokenList.add(admindevicetoken); // Store userId in the list
          adminDomain = prodata['domain'] ?? ''; // Extracting userId
          adminSubDomain = prodata['subdomain'] ?? ''; // Extracting userId

          // Print each value one by one

          print("adminDomain: $adminDomain");
          
          print("adminSubDomain: $adminSubDomain");
          print("psition: $_currentPosition");
          print("Gender: $gender");
          print("Latitude: $lat");
          print("Longitude: $lon");
          print("Business Name: $businessName");
          print("Address: $address");
          print("About Business: $aboutBusiness");
          print("AutoUser IDs: $userIdList"); // Print userId
          print("Auto resourceIDs: $adminresourceIdlist"); // Print userId
          print("AutoUser device tokens: $admindevicetokenList"); // Print userId

          if (position != null) {
            print("position!.latitude: ${position!.latitude}");
            print("position!.longitude: ${position!.longitude}");
          }

          print("lat: $lat");
          print("lon: $lon");
          print("your Auto map response: $responseBody");

          if (lat != null && lon != null) {
            automarkers.add(
              Marker(
                point: LatLng(lat, lon),
                child: IconButton(
                  iconSize: 100,
                  onPressed: () {
                    _Auto(
                      context,
                      prodata['name'],
                      double.parse(prodata['feedback'] ?? "0"),
                      prodata['registrationno'],
                      prodata['gender'],
                      adminId, // Pass userId to the dialog
                      prodata['mobileno'],
                      () => createProfile(context, adminId, admindevicetoken, name, adminmobileno, adminresourceId), // Pass context argument
                    );
                  },
                  icon: Image.asset(
                    "assets/autohd.png",
                    height: 400,
                    width: 800,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            );
          }
        }
      }
    } else {
      throw Exception('Error fetching marker positions: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching marker positions: $e');
  }
}
NotificationServices notificationServices=NotificationServices();

Position? _currentPos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            widget.userhometomap
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const userhome(
                              userhometomap: false,
                            )),
                  )
                : Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChooseAppointmentscreen()),
                  );
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: widget.autoclick == true || widget.autoadmin == true
            ? Colors.yellow
            : Colors.yellow,
        title: Text(
          "Live Map",
          style: widget.autoclick == true || widget.autoadmin == true
              ? TextStyle(color: Colors.black)
              : TextStyle(color: Colors.black),
        ),
      ),
      body: position == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.yellow,
              ),
            )
          : widget.userhometomap!=true?      FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(position!.latitude, position!.longitude),
                interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=f08d823160a2416dbbf70d037a08ecc8',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(position!.latitude, position!.longitude),
                     child:  IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.location_on,
                          size: 30,
                          color: Color(0xffC92317),
                        ),
                      ),
                    ),
                  ],
                ),
                if (markers.isNotEmpty)
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 30,
                      size: const Size(40, 40),
                      markers: markers,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.yellow),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ):
           FlutterMap(
        options: MapOptions(
          center: LatLng(position!.latitude, position!.longitude),
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    minZoom: 3.0,
                    maxZoom: 18.0,
        ),
      children: [
          TileLayer(
            urlTemplate:  'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=f08d823160a2416dbbf70d037a08ecc8',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
                      markers: [
                        Marker(
                          point:
                              LatLng(position!.latitude, position!.longitude),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.location_on,
                              size: 30,
                              color: Color(0xffC92317),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (automarkers.isNotEmpty)
                MarkerLayer(
                  markers: automarkers,
                ),    
       
        ],
      )
    );
   
  }
}




_AutoshowMarkerInfoDialog(
  BuildContext context,
  String name,
  double feedback,
   String registrationno,
  String gender,
    String AutouserId, // Receive userId as parameter
    String mobileno, 
    final VoidCallback onpressedbook,
 
) {
    void _callNumber(String mobileno) async {
    final phoneNumber = 'tel:$mobileno';

    // Request permission to make phone calls
    var status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        await launch(phoneNumber);
      } catch (e) {
        print('Could not launch phone call: $e');
      }
    } else {
      print('Phone call permission denied');
    }
  }
  bool _isButtonDisabled = false;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      print("feeddddddddbaaccccckkkkk:$feedback");
      print("mobileeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee:$mobileno");
      print("autouseriddddd:$AutouserId");
      print("registrationnooooo:$registrationno");
      print("gender:$gender");
      print("name:::$name");
      // return
      //  AlertDialog(
      
      //   title: Row(
      //     children: [
      //       Text('$name',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
      //       Spacer(),
      //       Text(
      //             feedback.toString(),
      //             style: const TextStyle(
      //               color: Colors.black,
      //               fontSize: 13
      //             )),
                
      //             Icon(Icons.star,
                  
      //             color: Colors.amber,),
                  
      //     ],
      //   ),
      //   content: Column(
        
      //     mainAxisSize: MainAxisSize.min,
      //     // crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //         Divider(color: Colors.black,),
      //       // Display shop name
      //       Row(
      //         children: [
              
      //           //Text('Vehicle Number : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold), ),
      //               CircleAvatar(
      //                                 maxRadius: 15,
      //                                 backgroundColor: Color.fromARGB(255, 242, 226, 85),
      //                                 child: Image.asset(
      //                                                            'assets/autonumberplate.png',
      //                                                             width: MediaQuery.of(context).size.width * 0.05,
      //                                                            // height: MediaQuery.of(context).size.height * 0.16,
      //                                                            // fit: BoxFit.cover,
      //                                                           ),
      //                               ),
      //                                SizedBox(width: 5,),
      //            Text(registrationno,style: TextStyle(fontSize: 13,),),
                
      //         ],
      //       ),
      //       SizedBox(height: 5,),
      //        Row(
      //          children: [
      //           CircleAvatar(
      //                                 maxRadius: 15,
      //                                 backgroundColor: Color.fromARGB(255, 242, 226, 85),
      //                                 child: Icon(Icons.transgender)
      //                               ),
      //                                SizedBox(width: 5,),
      //           // Text('Gender                : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold), ),
      //              Text(gender,style: TextStyle(fontSize: 13,),),
                   
      //          ],
      //        ),
      //         SizedBox(height: 10,),
      //           Row(
      //             children: [
      //               ElevatedButton(
      //                 style: ElevatedButton.styleFrom(
      //                   backgroundColor: Colors.blue
      //                 ),
      //                 onPressed: (){
      //                     // Invoke the callback when the button is pressed
      //               onpressedbook();
      //               Navigator.of(context).pop();
      //                 }
      //               //              Navigator.pushReplacement(
      //               // context,
      //               // MaterialPageRoute(
      //               //     builder: (context) =>
      //               //     AdminHome(usermap:true ))); 
                    
                    
      //                         , child: Text("Book",style: TextStyle(color: Colors.white),)),
      //                         Spacer(),
      //                          CircleAvatar(
      //                               radius: 15,
      //                               backgroundColor: Colors.green,
      //                               child: IconButton(
      //                                   onPressed: () {
      //                                      _callNumber(
      //                                         mobileno);
      //                                   },
      //                                   icon: Icon(
      //                                     Icons.phone,
      //                                     size: 15,
      //                                     color: Colors.white,
      //                                   )),
      //                             ),
      //             ],
      //           ),
       
      //     ],
      //   ),
         
        
      // );
      return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Center(
                    child: CircleAvatar(
                                  maxRadius: 30,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset("assets/autohd.png",)),
                  ),
                Row(
          children: [
          gender=="Male"?CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/man.png")):CircleAvatar(
                backgroundColor: Colors.transparent,
              child: Image.asset("assets/woman.png")),
              SizedBox(width: 5,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.44,
              child: Text('$name',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)),
            Spacer(),
            Text(
                  feedback.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13
                  )),
                
                  Icon(Icons.star,
                  
                  color: Colors.amber,),
                  
          ],
        ),
         Column(
                                 children: [

                                  Row(
                                    children: [
                                      Spacer(),
                                      Text(mobileno, style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13
                  )),
                                      // IconButton(
                                      //  onPressed: () {
                                      //     _callNumber(
                                      //        mobileno);
                                      //  },
                                      //  icon: Icon(
                                      //    Icons.phone,
                                      //    size: 25,
                                      //    color: Colors.black,
                                      //  )),
                                      SizedBox(width: 5,),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                               _callNumber(
                                                 mobileno);
                                            },
                                            child: CircleAvatar(
                                              maxRadius:20,
                                              backgroundColor: Colors.green,
                                              child:
                                              Icon(Icons.phone_in_talk_outlined,color: Colors.white)),
                                              // Image.asset("assets/call.gif")),
                                          ),
                                         // Text("Call")
                                        ],
                                      )
                                    ],
                                  ),
                                   
                                     
                                 ],
                               ),
        // SizedBox(height: 10,),
                  Row(
                                children: [
                                
                                  //Text('Vehicle Number : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold), ),
                                      Image.asset(
                                                                 'assets/autonumberplate.png',
                                                                  width: MediaQuery.of(context).size.width * 0.05,
                                                                 // height: MediaQuery.of(context).size.height * 0.16,
                                                                 // fit: BoxFit.cover,
                                                                ),
                                 SizedBox(width: 5,),
                                   Text(registrationno,style: TextStyle(fontSize: 13,),),
            //                        Spacer(),
            //                        Row(
            //    children: [
            //     CircleAvatar(
            //                           maxRadius: 15,
            //                           backgroundColor: Color.fromARGB(255, 242, 226, 85),
            //                           child: Icon(Icons.transgender)
            //                         ),
            //                          SizedBox(width: 5,),

            //     // Text('Gender                : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold), ),
            //        Text(gender,style: TextStyle(fontSize: 13,),),
                   
            //    ],
            //  ),
                                  
                                ],
                              ) ,
                              Divider(color: Colors.black,),
                                Row(
                                 // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    
                       Column(
                      children: [
                        CircleAvatar(
                         // maxRadius: 15,
                          backgroundColor: Colors.red,
                          child: IconButton(
                            onPressed: (){
              
                    Navigator.of(context).pop();
                            }
                         , icon: Icon(Icons.cancel,color: Colors.white,)),
                        ),
                        Text("Cancel",style: TextStyle(fontSize: 13,color: Colors.red))
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        CircleAvatar(
                         // maxRadius: 15,
                          backgroundColor: Colors.green,
                          child: IconButton(
                            onPressed: (){
                    onpressedbook();
             
                    Navigator.of(context).pop();
            //                 Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => const userhome(userhometomap: true,)),
            // );
                            }
                         , icon: Icon(Icons.check_circle_outline,color: Colors.white,)),
                        ),
                        Text("Book",style: TextStyle(fontSize: 13,color: Colors.green))
                      ],
                    ),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue
                    //   ),
                    //   onPressed: (){
                    //       // Invoke the callback when the button is pressed
                    // onpressedbook();
                    // Navigator.of(context).pop();
                    //   }
                    // //              Navigator.pushReplacement(
                    // // context,
                    // // MaterialPageRoute(
                    // //     builder: (context) =>
                    // //     AdminHome(usermap:true ))); 
                    
                    
                    //           , child: Text("Book",style: TextStyle(color: Colors.white),)),
                              
                              
                  ],
                ),
              ],
            ),
            
          ),
        );
    },
  );
}


_Auto(
  BuildContext context,
  String name,
  double feedback,
   String registrationno,
  String gender,
    String AutouserId, // Receive userId as parameter
    String mobileno, 
    final VoidCallback onpressedbook,
 
) {
    void _callNumber(String mobileno) async {
    final phoneNumber = 'tel:$mobileno';

    // Request permission to make phone calls
    var status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        await launch(phoneNumber);
      } catch (e) {
        print('Could not launch phone call: $e');
      }
    } else {
      print('Phone call permission denied');
    }
  }
  bool _isButtonDisabled = false;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      print("feeddddddddbaaccccckkkkk:$feedback");
      print("mobileeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee:$mobileno");
      print("autouseriddddd:$AutouserId");
      print("registrationnooooo:$registrationno");
      print("gender:$gender");
      print("name:::$name");
      return
       AlertDialog(
      
        title: Row(
          children: [
            gender=="Male"?CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/man.png")):CircleAvatar(
                backgroundColor: Colors.transparent,
              child: Image.asset("assets/woman.png")),
              SizedBox(width: 5,),
            Text('$name',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
            Spacer(),
            Text(
                  feedback.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13
                  )),
                
                  Icon(Icons.star,
                  
                  color: Colors.amber,),
                  
          ],
        ),
        content: Column(
        
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Divider(color: Colors.black,),
            // Display shop name
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  //Text('Vehicle Number : ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold), ),
                      Image.asset(
                                                 'assets/autonumberplate.png',
                                                  width: MediaQuery.of(context).size.width * 0.05,
                                                 // height: MediaQuery.of(context).size.height * 0.16,
                                                 // fit: BoxFit.cover,
                                                ),
                                       SizedBox(width: 5,),
                   Text(registrationno,style: TextStyle(fontSize: 13,),),
                   SizedBox(width:60,),
                  Column(
                                        children: [
                                         
                                          GestureDetector(
                                            onTap: (){
                                               _callNumber(
                                                 mobileno);
                                            },
                                            child: CircleAvatar(
                                              maxRadius:20,
                                              backgroundColor: Colors.green,
                                              child: 
                                              
                                              //Image.asset("assets/call.gif")),
                                              Icon(Icons.phone_in_talk_outlined,color: Colors.white,)),
                                          ),
                                         // Text("Call",style: TextStyle(fontWeight: FontWeight.bold),)
                                        ],
                                      )
                                  
                ],
              ),
            ),
         
           
              SizedBox(height: 10,),
                Row(
                  children: [
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue
                    //   ),
                    //   onPressed: (){
                    //       // Invoke the callback when the button is pressed
                    // onpressedbook();
                    // Navigator.of(context).pop();
                    //   }
                    // //              Navigator.pushReplacement(
                    // // context,
                    // // MaterialPageRoute(
                    // //     builder: (context) =>
                    // //     AdminHome(usermap:true ))); 
                    
                    
                    //           , child: Text("Book",style: TextStyle(color: Colors.white),)),
                              // Spacer(),
                              //  CircleAvatar(
                              //       radius: 15,
                              //       backgroundColor: Colors.green,
                              //       child: IconButton(
                              //           onPressed: () {
                              //              _callNumber(
                              //                 mobileno);
                              //           },
                              //           icon: Icon(
                              //             Icons.phone,
                              //             size: 15,
                              //             color: Colors.white,
                              //           )),
                              //     ),
                  ],
                ),
       
          ],
        ),
         
        
      );
   
    },
  );
}

void _showMarkerInfoDialog1(
  BuildContext context,
  String businessName,
  String shopAddress,
  String name,
  String mobileno,
  String aboutBusiness,
  double feedback,
  String deviceToken,
  String id,
  String profiD,
  List<Map<String, dynamic>> Countdata,
  String gender,
  final VoidCallback onpressesbook,
  String shopname
) {
  print(id);
  int markerCount = Countdata.length;

  Future<void> sendNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Admintoken = prefs.getString('admintoken') ?? "";
    // Your FCM server key
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(Admintoken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': name,
        'body': "Your appointment has been booked !!"
      },
      "to": Admintoken,
    };

    // Send the notification via HTTP POST request
    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
    }
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final url =
  //     "https://broadcastmessage.mannit.co/mannit/eCreate?DateTime now = DateTime.now();domain=Appointment&subdomain=Saloon";

  DateTime now = DateTime.now();

   void submitButtonPressed(BuildContext context) async {
    try {
      // Call the createProfile function and wait for it to complete
      // await createProfile();
      onpressesbook();
      Navigator.of(context).pop();

      // Name.clear();
      // phoneno.clear();
      // Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
    }
    // }
  }

  void _callNumber(String mobileno) async {
    final phoneNumber = 'tel:$mobileno';

    // Request permission to make phone calls
    var status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        await launch(phoneNumber);
      } catch (e) {
        print('Could not launch phone call: $e');
      }
    } else {
      print('Phone call permission denied');
    }
  }

  void updateAPI(double rating) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('Domain');
    final SubDomain = prefs.getString('SubDomain');
    String? USERId = prefs.getString('userId');
    print('userId:$id');
    print('resouceId: $USERId');

    final apiUrl = Uri.parse(
        'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$USERId&resourceId=$id');
    // String apiUrl =
    //     'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}';

    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          "feedback": rating.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        print(response.body);
        print('API updated successfully');

        // You can handle the response here if needed
      } else {
        print('Failed to update API. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error updating API: $error');
      // Handle the error accordingly
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.transparent,
                      child: gender == "Male"
                          ? Image.asset(
                              "assets/mensaloon.jpg",
                            )
                          : gender == "Female"
                              ? Image.asset("assets/femalesaloon.jpg")
                              : Image.asset(
                                  "assets/unisaloon.jpg",
                                )),
                ),
                // Text("         "),
                Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Waiting ',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      Text(
                        '$markerCount',
                        //   Countdata.length.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.44,
                    child: Text(
                      shopname,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    )),
                Spacer(),
                Text(feedback.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 13)),
                Icon(
                  Icons.star,
                  size: 25,
                  color: Colors.amber,
                ),
              ],
            ),
            SizedBox(
              width: 5,
              height: 10,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    Text(mobileno,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13)),
                    SizedBox(
                      width: 5,
                      height: 5,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _callNumber(mobileno);
                          },
                          child: CircleAvatar(
                            maxRadius: 20,
                            backgroundColor: Colors.green,
                            child: IconButton(
                                onPressed: () {
                                  _callNumber(mobileno);
                                },
                                icon: Icon(
                                  Icons.phone_in_talk_outlined,
                                  color: Colors.white,
                                )),
                            // child: Image.asset("assets/call.gif")
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on),
                Text(" "),
                Text(
                  shopAddress,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.black,
            ),
            Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      // maxRadius: 15,
                      backgroundColor: Colors.red,
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.white,
                          )),
                    ),
                    Text("Cancel",
                        style: TextStyle(fontSize: 13, color: Colors.red))
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: IconButton(
                          onPressed: () {
                            submitButtonPressed(context);
                          },
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          )),
                    ),
                    Text("Book",
                        style: TextStyle(fontSize: 13, color: Colors.green))
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
