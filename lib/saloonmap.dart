import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appointments/Provider/Reportscreen.dart';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/autouser/userhome.dart';
import 'package:appointments/property/utlis.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class saloonMapscreen extends StatefulWidget {
  const saloonMapscreen({super.key});

  @override
  State<saloonMapscreen> createState() => _saloonMapscreenState();
}

class _saloonMapscreenState extends State<saloonMapscreen> {
  final bool _mounted = false;
  final MapController mapController = MapController();
  List<Marker> markers = [];
  String? _adminToken;
  Stream<Position>? _currentPosition;
  Timer? _timer;
  List<LatLng> polylineCoordinates = [];
  bool _markersFetched = false;
  Future<void> _initSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.getString('selectedGender');
    await prefs.getString('SubDomain');
    //await _fetchMarkerPositions();
    fetchDataCount();
  }

  DateTime now = DateTime.now();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> createProfile(String profiD,String admindeviceToken,String adminresourceId) async {
    try {
      print("goingggggggggggggggggggggggg");
      String? token = await _firebaseMessaging.getToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usermobileno = prefs.getString('usermobileno') ?? "";
      String? adminmobileno = prefs.getString('adminmobile') ?? "";
        String? adminname = prefs.getString('adminname') ?? "";
      String? storedName = prefs.getString('username');
      String? userId = prefs.getString('userId');
      String? shopname = prefs.getString('shopname');
      String SubDomain = prefs.getString('SubDomain') ?? "";
      String businessName = prefs.getString('business name') ?? "";
      String Gender = prefs.getString('gender') ?? "";
       String Domain = prefs.getString('domain') ?? "";
          String userlat = prefs.getString('userlat') ?? "";
             String userlon = prefs.getString('userlon') ?? "";

      print(userId);
      print(Domain);
      print(SubDomain);
      String formattedTime = DateFormat('h:mm a').format(now);
      print(formattedTime);
      String formattedDate = DateFormat('dd/MM/yy').format(now);

      final response = await http.post(
        Uri.parse(
            "https://broadcastmessage.mannit.co/mannit/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$userId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "mobileno": phoneno.text,
           "name": storedName,
          "mobileno": usermobileno,
          "adminname":adminname,
          "adminmobileno":adminmobileno,
          "shopname": shopname,
     "shoplocation":{
            "shoplat":userlat.toString(),
            "shoplon":userlon.toString()
           },
          "business name": businessName,
          "DeviceToken": token,
        "userdeviceToken":token,
          "admindeviceToken":admindeviceToken,
          "gender": Gender,
         // "status": "true",
          "appointment":"waiting",
          "adminId": profiD,
           "adminresourceId":adminresourceId,
          "currentDate": formattedDate,
           "currentTime": formattedTime,
          
          
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
            sendNotification(storedName!);
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

   sendNotification(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Admintoken = prefs.getString('admindeviceToken') ?? "";
    String businessName = prefs.getString('business name') ?? "";
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
      'title': "New Booking",
    'body': 'A new booking has been made for $name', // Include username in the notification body
    },
  //'to':"dd2pCRHKQHu_M1ru8Wsq1-:APA91bGhlWJOsiUauAe3CGyvDSEpalX_MUVjqbKlLhcRMXU1r3om0vhu_fBAx8HS23GCfWc0UOh1_I5brurrekvjsV-URqYQ2k1Y1Kr6Ts3qfloRM-sp5RViO-MTYX5t4W7o7TTR5uDA",
   'to': Admintoken, // Use deviceIds list to send notifications to multiple devices
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

  bool _initialFetchDone = false;
  Position? position;
  bool isLoading = false;
//markers fetching api
  Future<void> _saloonfetchMarkerPositions() async {
    // if (_initialFetchDone) return;
    try {
     
  
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
          ? "assets/mensaloon.png"
          : selectedGender == 'Female'
              ? "assets/femalesaloon.png"
              : "assets/unisaloon.png";
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
            if (prodata.containsKey('location')) {
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
                final String admindeviceToken = prodata['deviceToken'].toString();
                final String gender = prodata['gender'].toString();
                   final String adminname = prodata['name'].toString();
                double feedback = double.parse(prodata['feedback'] ?? "2.0");
                final String mobileno = prodata['mobileno'].toString();
                final String shopname = prodata['shopname'].toString();
                  final String userlat = prodata['location']['lat'].toString();
                  final String userlon = prodata['location']['lon'].toString();

                print(admindeviceToken);
                print(profiD);
                print(id);
                print("Location lat:$lat");
                  print("Location lon:$lon");
                print(id);
                prefs.setString('adminmobile', mobileno);
                 prefs.setString('adminname', adminname);
                  prefs.setString('admindeviceToken', admindeviceToken);
                
                prefs.setString('adminid', profiD);
                   prefs.setString('userlat', userlat);
                   prefs.setString('userlon', userlon);
                prefs.setString('business name', businessName);
                prefs.setString('id', id);
                 prefs.setString('shopname', shopname);
                prefs.setString('gender', gender);
                  prefs.setString('SaloonSubDomain', businessName);
                //final admindeviceToken = prefs.setString('admindeviceToken', admindeviceToken);
                if (position != null) {
                  LatLng shopLatLng = LatLng(lat, lon);
                  final userLat = position!.latitude;
                  final userLon = position!.longitude;
                  final distance = Distance().distance(
                    LatLng(userLat, userLon),
                    LatLng(lat!, lon!),
                  );
   
                 if (distance < 2000) {
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
                                prodata['DeviceToken']??'',
                                prodata['userId']['\$oid'],
                                prodata['_id']['\$oid'],
                                Countdata,
                                prodata['gender'],
                                () => createProfile(profiD,admindeviceToken,id),
                                  prodata['shopname'],
                                  prodata['location']?['lon'],
                                prodata['location']?['lat'],
                              );
                            
                             }
                          },
                          child: businesstype == "Saloon"
                              ? CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      maxRadius: 50,
                                      child: Image.asset(
                                        logoAssetPath,
                                        width: 60,
                                        height: 60,
                                      )),
                                )
                              // ? Image.asset(
                              //     logoAssetPath,
                              //     width: 50,
                              //     height: 50,
                              //   )
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
   }
         
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
      // setState(() {
      //   _initialFetchDone = true;
      // });
      //  _initialFetchDone = true; // Mark initial fetch as done
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
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=appointment_S&f2_op=eq&f2_value=waiting&f3_field=adminId_S&f3_op=eq&f3_value=$adminId';
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

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _startLocationUpdates();
    _initSharedPreferences();
    const duration = Duration(seconds: 3);
    _timer = Timer.periodic(duration, (Timer t) {
      _saloonfetchMarkerPositions();
    });

    // Fetch markers immediately after initializing the widget
    _saloonfetchMarkerPositions();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    super.dispose();
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
                  builder: (context) => const ChooseAppointmentscreen()),
            );
          },
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Live Map",
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
            // WidgetsBinding.instance?.addPostFrameCallback((_) {
            //   //if (mounted) {
            //   // Check if the widget is still mounted
            //   _fetchMarkerPositions();
            //   //   }
            // });
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
                      Center(
                        child: const CircularProgressIndicator(
                          // Color Orange_color = const Color(0xfff26522);
                          color: Color(0xfff26522),
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
  String shopname,
  double lon,
  double lat
) {
  print(id);
  int markerCount = Countdata.length;


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
 
  DateTime now = DateTime.now();

  void submitButtonPressed(BuildContext context) async {
    try {
      // Call the createProfile function and wait for it to complete
      // await createProfile();
      onpressesbook();
       Navigator.pop(context);

    } catch (e) {
      print('Error: $e');
    }
    // }
  }
void _openMapApp() async {
    // final String currentLat = position!.latitude.toString();
    // final String currentLon = position!.longitude.toString();
    final String shopLat = lat.toString();
    final String shopLon = lon.toString();
    print(lat);
    print(lon);
    final String googleMapsUrl =
        'https://www.google.com/maps?q=$shopLat,$shopLon&destination=$shopLat,$shopLon';
    if (Platform.isAndroid) {
      await launch(googleMapsUrl, forceSafariVC: false);
    } else {
      await launch(googleMapsUrl, universalLinksOnly: false);
      throw 'Could not launch map app';
    }
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
                              "assets/mensaloon.png",
                            )
                          : gender == "Female"
                              ? Image.asset("assets/femalesaloon.png")
                              : Image.asset(
                                  "assets/unisaloon.png",
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
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // Column(
              //     children: [
              //       CircleAvatar(
              //         // maxRadius: 15,
              //         backgroundColor: Colors.blue,
              //         child: IconButton(
              //             onPressed: () {
              //               _openMapApp();
              //               Navigator.of(context).pop();
              //             },
              //             icon: Icon(
              //               Icons.location_searching_sharp,
              //               color: Colors.white,
              //             )),
              //       ),
              //       Text("Track",
              //           style: TextStyle(fontSize: 13, color: Colors.blue)),
              //     ],
              //   ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: IconButton(
                          onPressed: () async {
                         saloonmap(String saloonmap ) async {   
                          SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setBool('saloonmap',true);}
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