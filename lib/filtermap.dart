// ignore_for_file: deprecated_member_use, unused_import, unnecessary_cast, prefer_interpolation_to_compose_strings, unused_local_variable, unnecessary_string_interpolations, avoid_print, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, library_prefixes, unnecessary_import, file_names

import 'dart:convert';
import 'package:appointments/Categories/saloonprofile.dart';
import 'package:appointments/Provider/choosebusiness.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class filterMapscreen extends StatefulWidget {
  const filterMapscreen({super.key});

  @override
  State<filterMapscreen> createState() => _filterMapscreenState();
}

class _filterMapscreenState extends State<filterMapscreen> {
  final bool _mounted = false;
  final MapController mapController = MapController();
  List<Marker> markers = [];
  bool isLoading = false;
  bool noDataFound = false;
  Stream<Position>? _currentPosition;
  Position? position;
  List<bool> isSelected = [false, false, false, false, false];

  void _handleGenderSelection(String cat) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cat', cat);
      print('Category updated: $cat');
    } catch (e) {
      print('Error updating category: $e');
    }
  }
  DateTime _currentDateTime = DateTime.now(); // Initialize the currentDateTime
  NotificationServices notificationServices=NotificationServices();
Future<void> createProfile(context,String adminId,String admindeviceToken,String adminname,String adminmobilno,String adminresourceId) async {

  
  
    try {

       String? deviceToken = await notificationServices.getDeviceToken();

      final SharedPreferences prefs =
                await SharedPreferences.getInstance();
              //  final objectId = prefs.getString('userobjectId');
                final userId = prefs.getString('userId');
           String? username=prefs.getString("username");
       String ?   usermobile=prefs.getString("usermobileno");
         String ?   adminSubDomain=prefs.getString("cat");
            // String ?   usermobile=prefs.getString("usermobileno");
      final response = await http.post(
        Uri.parse(createProfileUrl(userId, proDomain, adminSubDomain)), // Append objectId to the URL
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
            //   Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => const userhome(userhometomap: true,)),
            // );
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

  Future<void> _fetchMarkerPositions() async {
    try {
      setState(() {
        isLoading = true;
        noDataFound = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String selectedGender = prefs.getString('selectedGender') ?? "";
      String cat = prefs.getString('cat') ?? "";

      String logoAssetPath =
          selectedGender == 'Male' ? "assets/mens.png" : "assets/womens.png";
      String apiUrl = '';

      if (cat == 'Saloon') {
        apiUrl =
            'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$cat&filtercount=3&f1_field=gender_S&f1_op=eq&f1_value=$selectedGender&f2_field=category_S&f2_op=eq&f2_value=Saloon&f3_field=Live_S&f3_op=eq&f3_value=true';
      } else if (cat == 'Clinic') {
        apiUrl =
            'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$cat&filtercount=2&f1_field=category_S&f1_op=eq&f1_value=Clinic&f2_field=Live_S&f2_op=eq&f2_value=true';
      } else if (cat == 'Pets') {
        apiUrl =
            'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$cat&filtercount=2&f1_field=category_S&f1_op=eq&f1_value=Pets&f2_field=Live_S&f2_op=eq&f2_value=true';
      } else if (cat == 'Auto') {
        apiUrl =
            'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$cat&filtercount=2&f1_field=business name_S&f1_op=eq&f1_value=$cat&f2_field=Live_S&f2_op=eq&f2_value=true';
      }else {
        throw Exception('Invalid category');
      }

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        final List<dynamic> sources = responseBody['source'];
        markers.clear(); // Clear existing markers
        if (sources.isEmpty) {
          setState(() {
            noDataFound = true;
          });
        } else {
          setState(() {
            noDataFound = false;
            for (final dynamic source in sources) {
              final Map<String, dynamic> prodata = jsonDecode(source);

              if (prodata.containsKey('Live') ) {
               double? lat = prodata['currentlocation']?['currentlat']?.toDouble();
            double? lon = prodata['currentlocation']?['currentlon']?.toDouble();
                final String businessName = prodata['business name'].toString();
                final String address = prodata['shop address'].toString();
                final String aboutBusiness =
                    prodata['about business'].toString();
                final String adminresourceId = prodata['_id']['\$oid'].toString();
                final String profiD = prodata['userId']['\$oid'].toString();
                final String gender = prodata['gender'].toString();
                double feedback = double.parse(prodata['feedback'] ?? "2.0");
                final String mobileno = prodata['mobileno'].toString();
                final String category = prodata['category'].toString();
                   final String adminId = prodata['adminId'].toString();
                    final String shop_name = prodata['shopname'].toString();
                     final String admindevicetoken = prodata['deviceToken'].toString();
                       final String adminname = prodata['name'].toString();
                           final String adminmobileno = prodata['mobileno'].toString();

                             prefs.setString('adminmobile', mobileno);
                 prefs.setString('adminname', adminname);
                
                prefs.setString('adminid', profiD);
                prefs.setString('business name', businessName);
                prefs.setString('id', adminresourceId);
                 prefs.setString('shopname', shop_name);
                prefs.setString('gender', gender);

                if (position != null) {
                  final userLat = position!.latitude;
                  final userLon = position!.longitude;
                  final distance = Distance().distance(
                    LatLng(userLat, userLon),
                    LatLng(lat!, lon!),
                  );
                  // Only add marker if it's within 2km
                  if (distance < 2000) {
                    markers.add(
                      Marker(
                        point: LatLng(lat!, lon!),
                        child: GestureDetector(
                            onTap: () {
                             
                              _AutoshowMarkerInfoDialog(
                          context,
                          prodata['name'],
                          double.parse(prodata['feedback'] ?? "0"),
                          prodata['registrationno'],
                          prodata['gender'],
                          adminId,
                          prodata['mobileno'],
                          () => createProfile(context, adminId, admindevicetoken, adminname, adminmobileno, adminresourceId),
                        );

                            },
                            child: cat == "Saloon" && gender == "Male"
                                ? Image.asset(
                                    "assets/mens.png",
                                    width: 50,
                                    height: 50,
                                  )
                                : cat == "Saloon" && gender == "Female"
                                    ? Image.asset(
                                        "assets/mens.png",
                                        width: 50,
                                        height: 50,
                                      )
                                    : cat == "Clinic"
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
                                        :cat == "Auto"
                                        ? Image.asset(
                                          //color: Colors.transparent,
                                          "assets/autohd.png",
                                          height: 70,
                                          width: 70,
                                        ): cat == "Pets"
                                            ? Icon(
                                                Icons.location_on,
                                                size: 40,
                                                color: Color.fromARGB(
                                                    255, 253, 200, 66),
                                              )
                                            : Icon(
                                                Icons.location_on,
                                                size: 40,
                                                color: Colors.black,
                                              )),
                      ),
                    );
                  }
                }
              }
            }
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching marker positions: $e');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String selectedGender = prefs.getString('selectedGender') ?? "";
      String cat = prefs.getString('cat') ?? "";
      setState(() {
        snackbar_red(context, 'No near by $cat');
        noDataFound = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startLocationUpdates() async {
    if (!_mounted) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position w) {
        setState(() => position = w);
      }).catchError((e) {
        debugPrint(e.toString() + "qwertyui");
        // snackbar_red(context, e.toString());
      });
    }
    _currentPosition = Stream.value(position!);
    try {
      const LocationSettings locationSettings =
          LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);
      _currentPosition =
          Geolocator.getPositionStream(locationSettings: locationSettings);
    } catch (e) {
      // snackbar_red(context, e.toString());
      print(e.toString() + "wertyuwertyuio");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      // return false;
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

  void handleChipSelection(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = (i == index);
      }

      switch (index) {
        case 0:
          markers.clear();
          break;
        case 1:
          markers.clear();

          break;
        case 2:
          markers.clear();

          break;
        case 3:
          markers.clear();

          break;
        case 4:
          markers.clear();

          break;
        case 5:
          markers.clear();

          break;
      }
    });
  }

  @override
  void initState() {
    _handleLocationPermission();
    _startLocationUpdates();
    // _fetchMarkerPositions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChooseBusiness()),
            );
          },
        ),
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Choice is Your's",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<Position>(
          stream: _currentPosition,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
            position = snapshot.data;
            return Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: LatLng(position!.latitude, position!.longitude),
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=f08d823160a2416dbbf70d037a08ecc8',
                      subdomains: const ['a', 'b', 'c'],
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
                              size: 40,
                              color: Color(0xffC92317),
                            ),
                          ),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: markers,
                    ),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SelectableChip(
                            txt: "CLINIC",
                            bordercolor: Colors.white,
                            selectedIcon: CupertinoIcons.bandage,
                            selectedTextColor: Colors.white,
                            isSelected: isSelected[0],
                            onTap: () async {
                              handleChipSelection(0);
                              _handleGenderSelection('Clinic');
                              await _fetchMarkerPositions();
                            },
                            selectedColor: Colors.blue,
                            selectedIconcolor: Colors.white,
                          ),
                          SelectableChip(
                            txt: "AUTO",
                            selectedIcon: CupertinoIcons.car_fill,
                            selectedTextColor: Colors.black,
                            isSelected: isSelected[1],
                            selectedColor: Colors.yellow,
                            selectedIconcolor: Colors.white,
                            bordercolor: Colors.black,
                            onTap: () async {
                              _handleGenderSelection('Auto');

                              handleChipSelection(1);
                              await _fetchMarkerPositions();
                            },
                          ),
                          SelectableChip(
                            selectedColor: Color.fromARGB(255, 240, 190, 64),
                            selectedIconcolor: Colors.white,
                            txt: "PETS",
                            bordercolor: Colors.white,
                            selectedIcon: CupertinoIcons.paw_solid,
                            selectedTextColor: Colors.white,
                            isSelected: isSelected[2],
                            onTap: () async {
                              _handleGenderSelection('Pets');
                              handleChipSelection(2);
                              await _fetchMarkerPositions();
                            },
                          ),
                          SelectableChip(
                            selectedColor: Colors.black,
                            txt: "SALOON",
                            bordercolor: Colors.white,
                            selectedIconcolor: Colors.white,
                            isSelected: isSelected[3],
                            onTap: () async {
                              _handleGenderSelection('Saloon');
                              handleChipSelection(3);
                              await _fetchMarkerPositions();
                            },
                            selectedIcon: CupertinoIcons.scissors,
                            selectedTextColor: Colors.white,
                          ),
                          SelectableChip(
                            selectedIconcolor: Colors.white,
                            selectedColor: Colors.amber,
                            txt: "TAXI",
                            isSelected: isSelected[4],
                            onTap: () async {
                              _handleGenderSelection('Taxi');

                              handleChipSelection(4);
                              await _fetchMarkerPositions();
                            },
                            selectedIcon: CupertinoIcons.car,
                            selectedTextColor: Colors.white,
                            bordercolor: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}

void _showMarkerInfoDialog(
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

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$name',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const Spacer(),
                Text(
                  feedback.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Image.asset(
                    "assets/profile.png",
                    height: 30,
                    width: 30,
                  ),
                ),
                Text(
                  businessName,
                  style: const TextStyle(color: Colors.black),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Image.asset(
                    "assets/gps.png",
                    height: 30,
                    width: 30,
                  ),
                ),
                Text(
                  shopAddress,
                  style: const TextStyle(color: Colors.black),
                )
              ],
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Salonprofile(
                    //       businessName: businessName,
                    //       shopAddress: shopAddress,
                    //       proname: name,
                    //       aboutbussines: aboutBusiness,
                    //       Devicetoke: deviceToken,
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 40,
                    width: 90,
                    child: const Center(
                      child: Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.green,
                child: IconButton(
                  onPressed: () {
                    _callNumber(mobileno);
                  },
                  icon: const Icon(
                    Icons.call,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void _showMarkerInfoDialogpets(
  BuildContext context,
  String businessName,
  String shopAddress,
  String name,
  String mobileno,
  String aboutBusiness,
  double feedback,
  String deviceToken,
  String id,
  String UserID,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
        print('userId:$id');
        print('resouceId: $UserID');

        final apiUrl = Uri.parse(
            'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$UserID&resourceId=$id');
        //https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}';

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

      return AlertDialog(
        backgroundColor: Colors.white,
        // backgroundColor: Color.fromARGB(255, 234, 170, 87),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$name',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const Spacer(),
                Text(
                  feedback.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Image.asset(
                    "assets/profile.png",
                    height: 30,
                    width: 30,
                  ),
                ),
                Text(
                  businessName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                ),
                Text(
                  shopAddress,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ],
        ),

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to profile screen or perform any other action
                  Navigator.of(context).pop();
                },
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => DoctorProfile(
                    //       businessName: businessName,
                    //       shopAddress: shopAddress,
                    //       proname: name,
                    //       aboutbussines: aboutBusiness,
                    //       Devicetoke: deviceToken,
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    height: 40,
                    width: 90,
                    child: const Center(
                      child: Text(
                        'View Profile',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.green,
                child: IconButton(
                  onPressed: () {
                    _callNumber(mobileno);
                  },
                  icon: const Icon(
                    Icons.call,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void _showMarkerInfoDialogclinic(
  BuildContext context,
  String businessName,
  String shopAddress,
  String name,
  String mobileno,
  String aboutBusiness,
  double feedback,
  String deviceToken,
  String id,
  String UserID,
) {
  TextEditingController Name = TextEditingController();
  TextEditingController phoneno = TextEditingController();

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
        'title': "Appointment Booked",
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

  Future<void> createProfile() async {
    try {
      print("goingggggggggggggggggggggggg");
      String? token = await _firebaseMessaging.getToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? USERId = prefs.getString('UseruserId');
      String selectdomain = prefs.getString('category') ?? "";
      print(selectdomain);
      print(USERId);
      // Get current date and time
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yy').format(now);
      String formattedTime = DateFormat('h.mm a').format(now);
      // String formattedTime = DateFormat('HH:mm a').format(now);
      final response = await http.post(
        Uri.parse(
            "https://broadcastmessage.mannit.co/mannit/eCreate?domain=Appointment&subdomain=Clinic&userId=$USERId"), // Append objectId to the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno": phoneno.text,
          "name": Name.text,
          "shopname": name,
          // "saloonId": userId,
          "DeviceToken": token,
          "business": selectdomain,
          "status": "true",
          "condition": "waiting",
          "currentTime": formattedTime,
          "currentDate": formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully created the profile, handle the response accordingly
        print('User created successfully');
        //  fetchData(widget.proname);
        snackbar_green(context, "Appoinment  Booked Successfully ");
        print(response.body);

        try {
          var responseData = jsonDecode(response.body);
          // print(_currentDateTime);
          print('Response body: $responseData');

          if (responseData['message'] == 'Resource Created Successfully') {
            var source = jsonDecode(responseData['source']);
            sendNotification();
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

  // "currentTime": "${DateFormat('hh.mm a').format(_currentDateTime)}",
  //         // "currentTime": "${DateFormat('HH:mm a').format(_currentDateTime)}",
  //         "currentDate": "${DateFormat('dd/MM/yy').format(_currentDateTime)}"
  void submitButtonPressed(BuildContext context) async {
    // Check if both fields are filled
    if (Name.text.trim().isEmpty || phoneno.text.trim().isEmpty) {
      // Show error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both name and mobile number.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        // Call the createProfile function and wait for it to complete
        await createProfile();

        // Ensure the dialog is dismissed after the asynchronous operation
        // Navigator.of(context, rootNavigator: true).pop();

        // Show success message
        print(Name.text + "  " + phoneno.text);
        Navigator.pop(context);
        // Navigator.of(context, rootNavigator: true).pop();
        // Clear text fields
        Name.clear();
        phoneno.clear();
      } catch (e) {
        // Handle errors if necessary
        print('Error: $e');
        // Navigator.of(context, rootNavigator: true);
        //     .pop(); // Ensure dialog is dismissed on
        // Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _showdialogue(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Name.clear();
          phoneno.clear();
          return AlertDialog(
            backgroundColor: Colors.blue,
            title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: Name,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(right: 10.0, left: 10.0),
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      hintText: "Enter Name",
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      )),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: phoneno,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      counterStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      contentPadding:
                          const EdgeInsets.only(right: 10.0, left: 10.0),
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      hintText: "Enter Mobile Number",
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.blue,
                      )),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () => submitButtonPressed(context),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          );
        });
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
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
        print('userId:$id');
        print('resouceId: $UserID');

        final apiUrl = Uri.parse(
            'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$UserID&resourceId=$id');
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

      return AlertDialog(
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    "assets/hos.png",
                  )),
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.44,
                    child: Text(
                      '$name',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    )),
                Spacer(),
                Text(feedback.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 13)),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ],
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
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _callNumber(mobileno);
                          },
                          child: CircleAvatar(
                              maxRadius: 20,
                              backgroundColor: Colors.black,
                              child: Image.asset("assets/call.gif")),
                        ),
                        Text("Call")
                      ],
                    )
                  ],
                ),
              ],
            ),
            // SizedBox(height: 10,),
            Row(
              children: [
                // Image.asset(
                //   'assets/autonumberplate.png',
                //   width: MediaQuery.of(context).size.width * 0.05,
                //   // height: MediaQuery.of(context).size.height * 0.16,
                //   // fit: BoxFit.cover,
                // ),
                SizedBox(
                  width: 5,
                ),
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
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      // maxRadius: 15,
                      backgroundColor: Colors.green,
                      child: IconButton(
                          onPressed: () {
                            _showdialogue(context);
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

class SelectableChip extends StatelessWidget {
  final String txt;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData selectedIcon;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color selectedIconcolor;
  final Color bordercolor;

  SelectableChip({
    required this.txt,
    required this.isSelected,
    required this.onTap,
    required this.selectedIcon,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.selectedIconcolor,
    required this.bordercolor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 35,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.blueGrey.shade100,
              border: Border.all(
                color: isSelected ? bordercolor : Colors.white,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Icon(
                    selectedIcon,
                    color: isSelected ? selectedTextColor : Colors.teal,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "   $txt   ",
                    style: TextStyle(
                      color: isSelected
                          ? selectedTextColor
                          : Colors.teal, // Modify this line
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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

