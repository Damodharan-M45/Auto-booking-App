// ignore_for_file: deprecated_member_use, unused_import, unnecessary_cast, prefer_interpolation_to_compose_strings, unused_local_variable, unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'package:appointments/Categories/saloonprofile.dart';
import 'package:appointments/Home.dart';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
class Mapscreen extends StatefulWidget {
 
  const Mapscreen( {Key? key, required this. autoclick,required this.autoadmin,required this.AutouserId}) : super(key: key);
 final bool autoclick;
 final bool autoadmin;
 final String? AutouserId;
  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  List<String> userIdList = []; // List to store userIds
  
   List<String> admindevicetokenList = [];// List to store admindevicetokenList
   late DateTime _currentDateTime; // Initialize _currentDateTime
 final String SubAuto="Auto";
    TextEditingController name = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  final bool _mounted = false;
  final MapController mapController = MapController();


    List<LatLng> polylinePoints = []; // List to store polyline points

  Stream<Position>? _currentPosition;
  Position? position;
 String? Domain='';
  String? SubDomain='';
  String? userId='';
  
  
String? username='';
String?usermobile='';
 usernamestored() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  username=  await prefs.getString('username');
    print(" stored user name:$username");
  }
Future<void> createProfile(context,String adminId,String admindeviceToken) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
     // userId = prefs.getString('userId');
     userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
    // Accept objectId as a parameter
    try {

       String? deviceToken = await notificationServices.getDeviceToken();

      final SharedPreferences prefs =
                await SharedPreferences.getInstance();
              //  final objectId = prefs.getString('userobjectId');
                final userId = prefs.getString('userId');
            username=prefs.getString("username");
            usermobile=prefs.getString("usermobileno");
             
      final response = await http.post(
        Uri.parse(createProfileUrl(userId, Domain, SubDomain)), // Append objectId to the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno":usermobile,
          "name": username,
          "adminId":adminId,
          "currentDate": "${DateFormat('dd/MM/yy').format(_currentDateTime)}",
          "userdeviceToken":deviceToken,
          "admindeviceToken":admindeviceToken,
          "location":{
            "currentlat":latitude,
            "currentlon":longitude
          }
        }),
      );

      if (response.statusCode == 200) {
         sendNotificationtoadmin( username!,admindeviceToken,); 
        // Successfully created the profile, handle the response accordingly
        print('User created successfully');
         
     //   sendNotificationtoadmin(admindeviceToken ,username!);
        snackbar_green(context, "Appoinment  Booked Successfully ");
        print(response.body);
        try {
          var responseData = jsonDecode(response.body);

          print('Response body: $responseData');

          if (responseData['message'] == 'Resource Created Successfully') {
            var source = jsonDecode(responseData['source']);

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

  // final Url =
  //     'https://broadcastmessage.mannit.co/mannit/eSearch?domain=appointment&subdomain=category&filtercount=1&f1_field=currentDate_S&f1_op=eq&f1_value=29/03/24';

void _showdialogue(BuildContext context, String adminId,String   admindevicetoken, ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          name.clear();
          phoneno.clear();
          return AlertDialog(
            backgroundColor: widget.autoclick?Colors.yellow:Colors.black,
            title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // _AutofetchMarkerPositions();
                },
              )
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
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
                        color: Colors.black,
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
                        color: Colors.black,
                      )),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.autoclick?Colors.green:Colors.white
                  ),
                  onPressed: () async {
                    // Check if both fields are filled
                    if (name.text.trim().isEmpty ||
                        phoneno.text.trim().isEmpty) {
                      // Show error message if any field is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please fill in both name and mobile number.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Both fields are filled, proceed to signup API

                      // Call the signup API function
                      //await Signup_api(context, userId,  admindevicetoken, );
                      
                      createProfile( context,  adminId, admindevicetoken,);
                    
                      print(name.text + "  " + phoneno.text);
                      Navigator.of(context).pop();
                      // Navigator.of(context).popUntil((route) => route.isCurrent); // Close all dialog boxes
                    }
                  },
                  child:widget.autoclick? const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ):const Text(
                    'Submit',
                    style: TextStyle(color: Colors.black),
                  )
                ),
              ],
            ),
          );
        });
  }
 String? AutouserId='';
    getShareduserId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
    }
 
 // Declare global variables for latitude and longitude
  double? latitude;
  double? longitude;
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
          // Print the current location in the console
    _currentPosition!.listen((Position? newPosition) {
       // Update global variables with new latitude and longitude values
        
      if (newPosition != null) {
        setState(() {
          latitude = newPosition.latitude;
          longitude = newPosition.longitude;
        });
        print('Current location in startupdate: ${latitude}, ${longitude}');
      } else {
        print('Current location is null');
      }
    
    });
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
  
Future<void> sendNotificationtoadmin(
String username,String admindeviceToken,
  ) async {
   print("sendNotificationtoadmin:$admindeviceToken") ;
     print("sendNotificationtoadmin name:$username") ;
       // Prepare notification data
    // String title = eventDetails['title'];
    // String body = eventDetails['description'];

    
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

NotificationServices notificationServices=NotificationServices();

double? lat;
              double? lon;
LatLng? destinationPoint; // Define destination point variable

String? Name;
 Future<void> _AutoAdminfetchMarker() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Domain = prefs.getString('domain');
      final SubDomain = prefs.getString('subdomain');
      String? adminname = prefs.getString('admin name');

      final response = await http.get(Uri.parse(
          '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&userId=${widget.AutouserId}'
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];
print("user marker respose from admin:${responseBody}");
        setState(() {
          markers.clear(); // Clear existing markers

          for (final dynamic source in sources) {
            final Map<String, dynamic> prodata = jsonDecode(source);

            if (prodata.containsKey('location')) {
               lat = prodata['location']?['currentlat'];
               lon = prodata['location']?['currentlon'];
                Name = prodata['name'];



              if (lat != null && lon != null) {
                markers.add(
                  Marker(
                    point: LatLng(lat!, lon!),
                    child:  
                    IconButton(
                      icon: Icon(Icons.person, color: Colors.yellow, size: 40),
                      onPressed: () => _showMarkerDetails(
                       // prodata
                       lat!,
                       lon!,
                       Name!
                        ),
                    ),
                  ),
                );
              }
            }
          }
        });
      } else {
        throw Exception('${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching marker positions: $e');
    }
  }

 
 Future<String> _getAddressFromLatLng(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&addressdetails=1'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] ?? 'No address available';
    } else {
      throw Exception('Failed to fetch address');
    }
  }
  


void _showMarkerDetails(double? lat,double?lon,String name) async {
  print("Debug: _showMarkerDetails function called");
  String address = await _getAddressFromLatLng(
     lat!, lon!);
  print("Debug: Address fetched from _getAddressFromLatLng: $address");
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      print("Debug: showModalBottomSheet builder called");
      return Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Name: $name",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            
            SizedBox(height: 10),
            Text(
              "Address: $address",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    },
  );
}
   bool _isLoading = false;
Position? _currentPos;
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPos = position;
          // Update other UI elements or variables as needed
        });
      }

      print(
          'Latitude: ${_currentPos!.latitude}, Longitude: ${_currentPos!.longitude}');
    } catch (e) {
      // Handle errors here
      print('Error getting location: $e');
    }
  }

  
  List<Marker> markers = [];
  String? profileOid;
   String? resourceId;
    String? userDeviceToken;


Future<void> fetchProfileData() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    Domain = prefs.getString('domain');
    SubDomain = prefs.getString('subdomain');

    // Print fetched values for debugging
    print('Fetching profile data with userId: $userId, Domain: $Domain, SubDomain: $SubDomain');

    final response = await http.get(
      Uri.parse(profileRead_url(userId, Domain, SubDomain)),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Profile data response: ${response.body}");

      if (data.containsKey('source') && data['source'] is List) {
        var sourceList = data['source'] as List;

        for (var profileJson in sourceList) {
          var profileData = jsonDecode(profileJson);

          // Check if the userId matches the current user's userId
          if (profileData['userId']['\$oid'] == userId) {
            // Extracting values into variables
            profileOid = profileData['_id']['\$oid'];
            resourceId = profileData['userId']['\$oid']; // Extracting the 'oid' from the 'userId' map
            userDeviceToken = profileData['userdeviceToken'] ?? '';

            // Print extracted values for debugging
            print('profileOid: $profileOid');
            print('resourceId: $resourceId');
            print('userDeviceToken: $userDeviceToken');

            // You can add further processing or storage of these values as needed

            // Since we found the matching profile, we can break out of the loop
            break;
          }
        }
      } else {
        print('Source key not found or not a list in the response');
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

 
    Future<void> liveLocationUpdate() async {
    print("poiddddd:$profileOid");
    print("userIdddd:$userId");

    // Check if the switch is turned on
  
      try {
        
         String? deviceToken = await notificationServices.getDeviceToken();
        print("live updating.....");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        
        Domain = prefs.getString('domain');
        SubDomain = prefs.getString('subdomain');
        print("profile oid:$resourceId");

        final response = await http.put(
          Uri.parse(Live_Url(Domain, SubDomain, userId, profileOid)),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'location': {
              'currentlat': _currentPos?.latitude,
              'currentlon': _currentPos?.longitude
            },
            "userdeviceToken": deviceToken,

          }),
        );

        if (response.statusCode == 200) {
          print('Live location updated successfully');
          print(response.body);
        } else {
          print(
              'Failed to update live location. Status code: ${response.statusCode}');
          print(response.body);
        }
      } catch (e) {
        print('Error updating live location: $e');
      }
 
  }

//   late Timer _locationUpdateTimer;
// // Example of how to call liveLocationUpdate when the switch is turned on
//   void startLocationUpdateTimer() {
//     _locationUpdateTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      
//         _getCurrentPosition().then((value) {
//           liveLocationUpdate();
//           print(
//               'Updated location: [${_currentPos?.latitude}, ${_currentPos?.longitude}]');
//         });
      
//     });
//   }

  @override
  void initState() {
        super.initState();
        usernamestored();
        print("?????????????????????????????????${widget.autoadmin}");
   _currentDateTime = DateTime.now(); // Initialize _currentDateTime with current time
   widget.autoclick==true?SubAuto:"";
   widget.autoclick==true? fetchProfileData():print("not Auto");
      //widget.autoclick==true? startLocationUpdateTimer():print("not Auto");

   //widget.autoclick==true? _AutofetchMarkerPositions():print("not Auto");
  widget.autoadmin==true?_AutoAdminfetchMarker():print("no users");

    //   notificationServices.requestNotificationPermisions();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
     notificationServices.isRefreshToken();
    notificationServices.getDeviceToken().then((value) {
    print(value);
      });
     _handleLocationPermission();
     //_startLocationUpdates();

  }
  //   @override
  // void dispose() {
  //   _disposed = true;
  //   _positionStreamSubscription?.cancel();
  //   super.dispose();
  // }

 bool isLoading = false; // Track loading state
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
        Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Autoadmin()),
            ) ;
          },
        ),
        backgroundColor: widget.autoclick==true||widget.autoadmin==true?Colors.yellow: Colors.black,
        title:  Text(
          "Live Map",
          style: widget.autoclick==true||widget.autoadmin==true?TextStyle(color: Colors.black):TextStyle(color: Colors.white)
        ),
      ),
      body: FutureBuilder<Position>(
        future: Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.yellow,
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
                      //f08d823160a2416dbbf70d037a08ecc8
                      urlTemplate:
                        // 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // urlTemplate:
                           'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=f08d823160a2416dbbf70d037a08ecc8',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      
          markers: [  Marker(
              point: LatLng(position!.latitude, position!.longitude),
              child:  IconButton(
                icon: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red, // Red color for current location marker
                ),
                onPressed: () {},
              ),
            ),
       
            if (lat!=null&&lon!=null) // Add this condition to check if destinationPoint is not null
              Marker(
                point: LatLng(lat!, lon!),
                child: 
              
                GestureDetector(
                  onTap: (){
                     _showMarkerDetails(
                       // prodata
                       lat!,
                       lon!,
                       Name!
                        );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                 
                    child: Center(
                      child: Icon(Icons.location_history,
                      size: 30,
                        color: Colors.white, // Yellow color for destination marker
                      ),
                    ),
                  ),
                )
              ),
                      ]
                    ),
                   
            
                       
                  ],
                
                      
                        
                        
                
                ),
              ],
            );
          }),
    );
  }
}


_AutoshowMarkerInfoDialog(
  BuildContext context,
  String name,
  
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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
      
        title: Center(child: Text('$name',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
        content: Column(
        
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display shop name
            Row(
              children: [
                Text('Vehicle Number : ',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold), ),
                 Text(registrationno),
                
              ],
            ),
             Row(
               children: [
                 Text('Gender                : ',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold), ),
                   Text(gender),
                   
               ],
             ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow
                      ),
                      onPressed: (){
                          // Invoke the callback when the button is pressed
                    onpressedbook();
                    Navigator.of(context).pop();
                      }
                    //              Navigator.pushReplacement(
                    // context,
                    // MaterialPageRoute(
                    //     builder: (context) =>
                    //     AdminHome(usermap:true ))); 
                    
                    
                              , child: Text("Book",style: TextStyle(color: Colors.black),)),
                              Spacer(),
                               CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.green,
                                    child: IconButton(
                                        onPressed: () {
                                           _callNumber(
                                              mobileno);
                                        },
                                        icon: Icon(
                                          Icons.phone,
                                          size: 15,
                                          color: Colors.white,
                                        )),
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





