
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appointments/Auto/auto_report.dart';
import 'package:appointments/Mapscreen.dart';
import 'package:appointments/Provider/Reportscreen.dart';
import 'package:appointments/Regesterscreen/commonScreen.dart';
import 'package:appointments/autouser/userhome.dart';
import 'package:appointments/editprofile.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Autoadmin extends StatefulWidget {
  const Autoadmin({super.key});

  @override
  State<Autoadmin> createState() => _AutoadminState();
}

class _AutoadminState extends State<Autoadmin> {
 bool _showAutoMarkers = false;
  String? userId;
   String? adminId;
  String? Domain;
  String? SubDomain;
  String? mobileno;
  String? name;
  String? bussinessname;
  String? adress;
  String? proname;
  String? resouceId;
  String? aboutbussines;
  String? feedback;
  String? profileOid;
  String? oid;
  Map<String, dynamic>? providerdata;
    bool _switchValue = false;
     Position? _currentPosition;
  bool? live;
  String? registrationno;
  live_shared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_switchValue == true) {
      await prefs.setBool('live', true);
      live = prefs.getBool('live');
      print(live);
    } else {
      await prefs.remove('live');
      live = prefs.getBool('live');
      print(live);
    }
  }
    shared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    live = prefs.getBool('live');

    _switchValue = live == null ? false : true;
  }
 Future _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          // Update other UI elements or variables as needed
        });
      }

      print(
          'Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}');
    } catch (e) {
      // Handle errors here
      print('Error getting location: $e');
    }
  }

 
  Future<void> _handleLocation() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.provisional) {
    } else {
      // Handle case when user denies location permission
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  Uint8List? bintoimg;

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
  String? Live;
  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
  
    String?  domain = prefs.getString('domain');
    String?  subdomain = prefs.getString('subdomain');
    String?  userid=prefs.getString('userId');
    print("domainnnnnnnnnnoooo:$domain");
    print("subdomainnnnnnn0000:$subdomain");
    print("userIddddddddd0000:$userid");
      final response = await http.get(
        Uri.parse(
          '$base_url/eSearch?domain=$domain&subdomain=$subdomain&userId=$userid'
        //  profileRead_url(userid, domain, subdomain)
          ),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("admin profile data is :${response.body}");
        if (data.containsKey('source') && data['source'] is List) {
          var sourceList = data['source'] as List;

          // Assuming you only need the first profile
          if (sourceList.isNotEmpty) {
            var firstProfileData = jsonDecode(sourceList.first);
//9887634354
            profileOid = firstProfileData['_id']['\$oid'];
            mobileno = firstProfileData['mobileno'];
            name = firstProfileData['name'];
            bussinessname = firstProfileData['business name'];
            adress = firstProfileData['address'];
             feedback = firstProfileData['feedback'];
            aboutbussines =
                firstProfileData['about business'] ?? 'Default Name';
            resouceId = firstProfileData['userId']['\$oid'];
            registrationno=firstProfileData['registrationno']?? 'No Registration no';
             Live=firstProfileData['Live']?? 'No live';


            // Add more variables as needed

            // Print or use the variables as needed
            print('User ID: $userId');
            print('Mobile Number: $mobileno');
            print('Profile URL: $aboutbussines');
            print('Name: $bussinessname');
            print('Category: $profileOid');
            print('registrationno: $registrationno');
            print("feedback:$feedback");

            // Print or use more variables as needed'
            // prefs.setString('clientRole', clientRole ?? 'defaultRole');
            prefs.setString('business name', bussinessname ?? "");
             prefs.setString('admin name', name ?? "");

            print(bussinessname);
            print(profileOid);

            setState(() {
              providerdata = {
                'name': name,
                'mobileno': mobileno,
                'registrationno':registrationno,
                "business name": bussinessname,
                "about business": aboutbussines,
                "address": adress,
                "feedback":feedback
              };
            });
          } else {
            print('Profile data not found in the response');
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
   Timer?_locationUpdateTimer;
  NotificationServices notificationServices=NotificationServices();
 Future<void> liveLocationUpdate() async {
    print(" admin poiddddd:$profileOid");
    print(" admin userIdddd:$resouceId");

    try {
      String? deviceToken = await notificationServices.getDeviceToken();
      print("admin live updating.....");
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      print("profile oid:$resouceId");

      final response = await http.put(
        Uri.parse(Live_Url(Domain, SubDomain, resouceId, profileOid)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentlocation': {
            'currentlat': _switchValue ? _currentPosition?.latitude : 0.0,
            'currentlon': _switchValue ? _currentPosition?.longitude : 0.0,
          },
       
          "deviceToken": deviceToken,
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
  Future<void> liveenable() async {
      print(" liveeeeeeeeeeeeeeeeeeeee enabledddddddddddddddddddd");
    print(" admin poiddddd:$profileOid");
    print(" admin userIdddd:$resouceId");

    try {
      String? deviceToken = await notificationServices.getDeviceToken();
      print("admin live updating.....");
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      print("profile oid:$resouceId");

      final response = await http.put(
        Uri.parse(Live_Url(Domain, SubDomain, resouceId, profileOid)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        "Live":"true"
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
  Future<void> disableliveLocationUpdate() async {

    print("lacation offfffffffffffff");
    print("poiddddd:$profileOid");
    print("userIdddd:$resouceId");

    // Check if the switch is turned on
   
      try {
        
         String? deviceToken = await notificationServices.getDeviceToken();
        print("live updating.....");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        // resouceId = await prefs.getString('profileobjectId');

        Domain = prefs.getString('domain');
        SubDomain = prefs.getString('subdomain');
        print("profile oid:$resouceId");

        final response = await http.put(
          Uri.parse(Live_Url(Domain, SubDomain, resouceId, profileOid)),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
           "Live":"false",
            "deviceToken": deviceToken,

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

  void startLocationUpdateTimer() {
    _locationUpdateTimer?.cancel(); // Cancel any existing timer
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_switchValue) {
        _getCurrentPosition().then((value) {
          liveLocationUpdate();
          print(
              'Updated location: [${_currentPosition?.latitude}, ${_currentPosition?.longitude}]');
        });
      }
    });
  }
  void stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
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

//6544892894
  List<Map<String, dynamic>> salonData = [];
  Future<void> fetchData() async {
    try {

      print("appointments:");
         salonData.clear();
       final SharedPreferences prefs = await SharedPreferences.getInstance();
        Domain = prefs.getString('domain');
        SubDomain = prefs.getString('subdomain');
        String businessname = prefs.getString('business name') ?? "";
        adminId=prefs.getString('adminId') ?? "";
         userId=prefs.getString('userId') ?? "";
      print("userIdddd:$userId");
       print(Domain);
 print(SubDomain);
      print(businessname);
      // Get the current date
      DateTime currentDate = DateTime.now();
      // Format the date according to your API URL format (assuming dd/MM/yy)
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
           print("current date:$formattedDate");
      final fetch =
         //'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=2&f1_field=adminId_S&f1_op=eq&f1_value=$userId&f2_field=currentDate_S&f2_op=eq&f2_value=$formattedDate';

          '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=adminId_S&f1_op=eq&f1_value=$userId&f2_field=currentDate_S&f2_op=eq&f2_value=$formattedDate&f3_field=appointment_S&f3_op=ne&f3_value=dropped';

      final response = await http.get(Uri.parse(fetch));
      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
      
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        // Check if the response data is in the expected format
        if (responseBody.containsKey('message') &&
            responseBody['message'] == 'Successfully Searched' &&
            responseBody.containsKey('source')) {
          List<dynamic> sources = responseBody['source'];
          // Check if there are entries for the specified shop name and today's date
          if (sources.isNotEmpty) {
            setState(() {
              // Update salonData with the parsed source data
              salonData = List<Map<String, dynamic>>.from(
                  sources.map((source) => jsonDecode(source)));
            });
          } else {
            // Print a message if no entries are found for the specified criteria
            print('No entries found for shop name and today\'s date.');
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
  
Future<void> showLogoutAlertDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('Confirm Logout'),
            ],
          ),
        content: Text(
            'Logging out will disable location tracking.',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        actions: <Widget>[
           Row(
             children: [
               TextButton(
                style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.red)),
                child: Text('Cancel',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                         ),
                         Spacer(),
                          TextButton(
                style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.green)),
                child: Text('Ok',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  logout();
         disableliveLocationUpdate();
             stopLocationUpdateTimer();
                  Navigator.of(context).pop();
                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Commonscreen(),
          ),
        );
                },
                         ),
                         
             ],
           ),
          
        ],
      );
    },
  );
}
 logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //bool? userlogin = prefs.getBool('userlogin');
            bool? adminlogin = prefs.getBool('adminlogin');

     // bool? usersignup = prefs.getBool('usersignup');
            bool? adminsignup = prefs.getBool('adminsignup');

      bool? register = prefs.getBool('register');
      // if (userlogin != null) {
      //   await prefs.remove('userlogin');
      // }
       if (adminlogin != null) {
        await prefs.remove('adminlogin');
      }
      // if (usersignup != null) {
      //   await prefs.remove('usersignup');
      // }
       if (adminsignup != null) {
        await prefs.remove('adminsignup');
      }
      if (register != null) {
        await prefs.remove('register');
      }
    } catch (e) {
      print(e);
    }
  }

Future<void> showLiveenabletAlertDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('Confirm Logoutoilhjkghhhhhhhhhhhj'),
            ],
          ),
        content: Text(
            'Logging out will disable location tracking.',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        actions: <Widget>[
           Row(
             children: [
               TextButton(
                style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.red)),
                child: Text('Cancel',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                         ),
                         Spacer(),
                          TextButton(
                style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.green)),
                child: Text('Ok',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  logout();
         disableliveLocationUpdate();
             stopLocationUpdateTimer();
                  Navigator.of(context).pop();
                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Commonscreen(),
          ),
        );
                },
                         ),
                         
             ],
           ),
          
        ],
      );
    },
  );
}
 Timer?pagerefresh;
  void pagerefreshmethod() {
   
    pagerefresh = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchProfileData();
      fetchData();
    });
  }
  @override
  void initState() {
 pagerefreshmethod();
    super.initState();
       fetchProfileData();
     //  Live=="true"?  _switchValue:print("livvvvvve    fallllseeee");
    fetchData();

  //  _handleLocationPermission();
  
  //startLocationUpdateTimer();
    if (live != null && live!) {
      _getCurrentPosition().then((value) => startLocationUpdateTimer());
    }
    _getCurrentPosition().then((value) {
  setState(() {
      _switchValue = _currentPosition != null;
      });
    });
  }
Future<void> _initializeLocationState() async {
    if (live != null && live!) {
      Position? position = await _getCurrentPosition();
      if (position != null) {
        setState(() {
          _switchValue = true;
        });
        liveLocationUpdate();
        startLocationUpdateTimer();
        liveenable();
      }
    } else {
      Position? position = await _getCurrentPosition();
      setState(() {
        _switchValue = position != null;
      });
    }
  }
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    pagerefresh?.cancel();
    super.dispose();
     
  }
  Future<bool> _onWillPop() async {
    return await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Exit App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Do you want to exit the app?',style: TextStyle(color: Colors.black,fontSize: 16),),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
          
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                  onPressed:() => Navigator.of(context).pop(false), 
                child: Text('No',style: TextStyle(fontSize: 13,color: Colors.white),)),
           
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                  onPressed:() => SystemNavigator.pop(), 
                child: Text('Yes',style: TextStyle(fontSize: 13,color: Colors.white),))
                
              ],
            ),
          ],
        ),
      ),
    ) ??
    false;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: providerdata == null
            ?null
         
          :  AppBar(
        automaticallyImplyLeading: false, // Hide the back arrow
        backgroundColor: Colors.yellow,
        title: Text(
      providerdata!['business name'] ?? "",
      style: const TextStyle(
        color: Colors.black, 
        fontWeight: FontWeight.bold
      ),
        ),
        centerTitle: true,
        actions: [
      
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfile()
            ),
          ).then((value) async {
                  await fetchData();
                  });
        },
        icon: const Icon(
          Icons.edit,
          color: Colors.black,
        )
      ),
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminReport(
                busname: bussinessname ?? ""
              ),
            ),
          ).then((value) async {
                  await fetchData();
                  });
        },
        icon: const Icon(
          Icons.history,
          color: Colors.black,
        )
      ),
       IconButton(
        onPressed: ()async {
             await showLogoutAlertDialog(context);
          //  await logout();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => Commonscreen(),
          //   ),
          //  );
        },
        icon: const Icon(
          Icons.logout,
          color: Colors.black,
        )
      )
        ],
      ),
      
        body: providerdata == null
            ? const Center(child: CircularProgressIndicator(color: Colors.yellow,))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 5,
                      right: 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left:10)),
                          
                        CircleAvatar(
                          backgroundColor:Colors.transparent,
                          maxRadius: 35,
                            child: Image.asset(
                              "assets/autohd.png",
                              // width: MediaQuery.of(context).size.width * 0.40,
                              // height: MediaQuery.of(context).size.height * 0.16,
                             // fit: BoxFit.cover,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  Row(
                                    children: [
                                        CircleAvatar(
                                        maxRadius: 15,
                                        backgroundColor: Color.fromARGB(255, 242, 226, 85),
                                        child: 
                                         Icon(Icons.person,color: Colors.black,
                                        )
                                        // Image.asset(
                                        //                            'assets/autonumberplate.png',
                                        //                             width: MediaQuery.of(context).size.width * 0.05,
                                        //                            // height: MediaQuery.of(context).size.height * 0.16,
                                        //                            // fit: BoxFit.cover,
                                        //                           ),
                                      ),
                                   SizedBox(width: 5,),  
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.38,
                                        child: Text(
                                          //"VIJAYA RAGAVAN"  ,                            
                                          providerdata!['name'] ?? "",
                                          
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                        
                                      ),
                                      
                                         Text(
                                                                            
                                              providerdata!['feedback'] ?? "",
                                              
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black,
                                              ),  ),
                                                Icon(Icons.star,
                                                               
                                                               color: Colors.amber,),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        maxRadius: 15,
                                        backgroundColor: Color.fromARGB(255, 242, 226, 85),
                                        child: 
                                        Icon(Icons.location_on,color: Colors.black,
                                        )
                                        // Image.asset(
                                        //                            'assets/autonumberplate.png',
                                        //                             width: MediaQuery.of(context).size.width * 0.05,
                                        //                            // height: MediaQuery.of(context).size.height * 0.16,
                                        //                            // fit: BoxFit.cover,
                                        //                           ),
                                      ),
                                   SizedBox(width: 5,),  
                                      SizedBox(
                                         width: MediaQuery.of(context).size.width * 0.45,
                                        child: Text(
                                        // "no 210b, anna street kosavanpalayam thirunuinravur, thiruvallur-602024",
                                         providerdata!['address'] ?? "",
                                          style: const TextStyle(fontWeight: FontWeight.w400,
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        maxRadius: 15,
                                        backgroundColor: Color.fromARGB(255, 242, 226, 85),
                                        child: Image.asset(
                                                                   'assets/autonumberplate.png',
                                                                    width: MediaQuery.of(context).size.width * 0.05,
                                                                   // height: MediaQuery.of(context).size.height * 0.16,
                                                                   // fit: BoxFit.cover,
                                                                  ),
                                      ),
                                   SizedBox(width: 5,),  
                                      SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.26,
                                        child: Text(
                                        // "jhghj kjhkjh khjkh hjhjjjjk ",
                                         providerdata!['registrationno'] ?? "",
                                          style: const TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                        ),
                                      ), 
                        
                                      Transform.scale(
                        scale: 0.8,
                        child:Row(
                          children: [
                              Text(_switchValue ? "LIVE" : "REST", style: TextStyle(color: _switchValue ? Colors.green : Colors.red)),
                SizedBox(width: 1), // Space between text and switch
                            CupertinoSwitch(
                                  value: _switchValue,
                                  trackColor: Colors.red,
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    setState(() {
                                    
                                      _switchValue = value;
                                      if (_switchValue) {
                                      _getCurrentPosition().then((_) {
                        liveLocationUpdate();
                        startLocationUpdateTimer();
                        liveenable();
                      });
                                      //  _getCurrentPosition().then((value) => liveLocationUpdate());
                                      //  startLocationUpdateTimer();
                                      //   liveenable();
      
                                      } else {
                                        
                                     disableliveLocationUpdate();
                                      }
                                      live_shared();
                                    });
                                  },
                                ),
                          ],
                        )
      
                      ),
                                    ],
                                  ),
                   
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(onPressed: (){
                        fetchProfileData();
                          fetchData();
      //  Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => SalonBookscreen(),
      //           ));
      
                      }, icon: Icon(Icons.refresh)),
                      Text("Refresh")
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
      
      
                  Expanded(
                    child: salonData.isEmpty
                        ? const Center(
                            child: Text('No Appointments available',
                            style: TextStyle(color: Colors.grey,fontSize: 20),),
                          )
                        : ListView.builder(
                            itemCount: salonData.length,
                            itemBuilder: (context, index) {
                              final salon = salonData[index];
                              final serialNumber = index + 1;
      
                              void onCreatedCallback() {
                                print(
                                    'resouceId: ${salon.containsKey('_id') ? salon['_id']['\$oid'].toString() : '--'}');
                                print(
                                    'userId: ${salon.containsKey('userId') ? salon['userId']['\$oid'].toString() : '--'}');
                              }
      
                              return AutoAppointments(
                                 currentTime:salon['currentTime'] ?? '',
                                business:salon['business'] ?? '',
                                date:salon['currentDate'] ?? '',
                                adminresourceid:profileOid??'',
                                adminuserid:resouceId??'',
                                oid:salon['_id']["\$oid"] ?? '',
                                num: '$serialNumber',
                                name: salon['name'] ?? '',
                                userlat: salon['location'] ['currentlat']?? '',
                                userlon: salon['location'] ["currentlon"]?? '',
                                condition: salon['condition'] ?? '',
                                Date: salon['currentDate'] ?? '--',
                                toogle: true,
                                userId: salon.containsKey('userId')
                                    ? salon['userId']['\$oid'].toString()
                                    : '--',
                                oncall: () {
                                  _callNumber(salon['mobileno'] ?? "");
                                },
                                resouceId: salon.containsKey('_id')
                                    ? salon['_id']['\$oid'].toString()
                                    : '--',
                                onCreated: onCreatedCallback,
                                onpressdelete: true,
                                salonData: salonData,
                                index: index, userdeviceToken: salon['userdeviceToken'] ?? '',
                                
                              );
                            },
                          ),
                  ),
                ],
              ),
      
      ),
    );
  }
}

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({super.key});

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController phoneno = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
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
            controller: name,
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(right: 10.0, left: 10.0),
                fillColor: Colors.white,
                focusColor: Colors.white,
                filled: true,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                errorBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
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
                contentPadding: const EdgeInsets.only(right: 10.0, left: 10.0),
                fillColor: Colors.white,
                focusColor: Colors.white,
                filled: true,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                errorBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1.5, color: Colors.white),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    name.dispose();
    phoneno.dispose();
    super.dispose();
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

class AutoAppointments extends StatefulWidget {
    final String adminresourceid;
      final String adminuserid;
        final String currentTime;

  final String num;
  final String date;
  final String name;
  final String condition;
  final String Date;
  final int index;
  final VoidCallback oncall;
  final VoidCallback? onCreated;
  final bool onpressdelete;
  final bool toogle;
  final String resouceId;
  final String userId;
   final double userlat;
    final double userlon;
    final String oid;
    final String userdeviceToken;
    final String business;
  final List<Map<String, dynamic>> salonData;
  const AutoAppointments({
    Key? key,
    required this.adminresourceid,
     required this.adminuserid,
     required this.userlat,
     required this.userlon,
      required this.num,
       required this.currentTime,
    required this.onpressdelete,
    required this.name,
    required this.condition,
    required this.Date,
    required this.toogle,
    required this.index,
    required this.salonData,
    required this.userId,
    required this.resouceId,
     required this.business,
    this.onCreated,
    required this.oncall, required this.oid,
    required this.userdeviceToken, required this.date
  }) : super(key: key);

  @override
  State<AutoAppointments> createState() => _AutoAppointmentsState();
}

class _AutoAppointmentsState extends State<AutoAppointments> {


  bool _switchValue = false;

  bool _isProcessing = false;
  List<Map<String, dynamic>> salonData = [];
  Future<void> _cancelAppointment() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Domain = prefs.getString('domain');
      final SubDomain = prefs.getString('subdomain');
      String?  adminname = prefs.getString('admin name');
      print('userId:${widget.userId}');
      print('resouceId: ${widget.resouceId}');
     
      String userdeviceToken=widget.userdeviceToken;
      

      final deleteUrl =
                  
           //'https://broadcastmessage.mannit.co/mannit/eDelete?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}';

         '$base_url/eDelete?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}';
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        print(response);
    
        setState(() {
          widget.salonData.removeWhere(
            (salon) =>
                salon['_id']['\$oid'] == widget.resouceId &&
                salon['userId']['\$oid'] == widget.userId,
          );
        });
cancelsendNotificationtouser(userdeviceToken,adminname!);
  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Autoadmin(),
            ));   snackbar_green(context, "Appointment canceled successfully");
        // Remove the deleted appointment from the list

        print('Appointment canceled successfully');

     
        // Optionally, you can remove the item from the UI or update the UI accordingly
      } else {
        print(
            'Failed to cancel appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error canceling appointment: $e');
    }
  }
Future<void> cancelsendNotificationtouser(
String userdeviceToken,String adminname
  ) async {
       // Prepare notification data
    // String title = eventDetails['title'];
    // String body = eventDetails['description'];
print("Cancel notification auto by owner:$userdeviceToken");
    
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
      'title': "Booking Cancellation",
    'body': 'Your booking has been cancelled by $adminname', // Include username in the notification body
    },
  // 'to':"dd2pCRHKQHu_M1ru8Wsq1-:APA91bGhlWJOsiUauAe3CGyvDSEpalX_MUVjqbKlLhcRMXU1r3om0vhu_fBAx8HS23GCfWc0UOh1_I5brurrekvjsV-URqYQ2k1Y1Kr6Ts3qfloRM-sp5RViO-MTYX5t4W7o7TTR5uDA",
    'to': userdeviceToken, // Use deviceIds list to send notifications to multiple devices
  };
  
  // Send the notification via HTTP POST request
  final http.Response response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(notificationData),
  );

  if (response.statusCode == 200) {
    print('Cancellation Notification sent successfully');
  } else {
    print('Failed to send cancellation notification. Status code: ${response.statusCode}');
  }
}
Future<void> confirmsendNotificationtouser(
String userdeviceToken,String adminname
  ) async {
      print("confirmation notification:$userdeviceToken");
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
      'title': "Booking Confirmation",
    'body': 'Your booking has been confirmed by $adminname', // Include username in the notification body
     
    },
  // 'to':"dd2pCRHKQHu_M1ru8Wsq1-:APA91bGhlWJOsiUauAe3CGyvDSEpalX_MUVjqbKlLhcRMXU1r3om0vhu_fBAx8HS23GCfWc0UOh1_I5brurrekvjsV-URqYQ2k1Y1Kr6Ts3qfloRM-sp5RViO-MTYX5t4W7o7TTR5uDA",
    'to': userdeviceToken, // Use deviceIds list to send notifications to multiple devices
  };
  
  // Send the notification via HTTP POST request
  final http.Response response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(notificationData),
  );

  if (response.statusCode == 200) {
    print('Confirm Notification sent successfully');
  } else {
    print('Failed to send confirm notification. Status code: ${response.statusCode}');
  }
}
Future<void> sendNotification1() async {
    // Your FCM server key
    print(widget.userdeviceToken);
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(widget.userdeviceToken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': "Thank you",
        'body': "Give me your rating please..........."
      },
      // 'to':
      //     "frt-Usw7T3mOo6L2hx9jVg:APA91bGEorZU1CUCKmz4EVf1QllCigixOXFBNc2GUw-cl-OfOlc60THxb7dbOi4AWLVA74s5y6jRAXTUTorPzRUGP3ahp7Nvy3LSsF1Ddu8PL-tSUy1-aJ2Hwv3U7zvGxcBhhmHuznEy"
      'to': widget.userdeviceToken,
      //'registration_ids': deviceTokens, // Use deviceIds list to send notifications to multiple devices
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
  void closedbooking() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('domain');
    final SubDomain = prefs.getString('subdomain');
    print('userId:${widget.userId}');
    print('resouceId: ${widget.resouceId}');

    final apiUrl = Uri.parse(
       '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
  
    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          "appointment": "dropped",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
              sendNotification1();
              dropbookinstatus();
        if (mounted){      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Autoadmin(),
            ));}
        snackbar_green(context, "User dropped safe....");
  
        print(response);
        print('API updated successfully');
       
      } else {
        print('Failed to update API. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error updating API: $error');
      // Handle the error accordingly
    }
  }

  Future<void> _toggleSwitch(bool value) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('domain');
    final SubDomain = prefs.getString('subdomain');
   String? adminname = prefs.getString('admin name');
    String userdeviceToken=widget.userdeviceToken;
    setState(() {
      _isProcessing = true;
    });

    // Call update API if switch is turned on
    if (value) {
      print('userId:${widget.userId}');
      print('resouceId: ${widget.resouceId}');
      final url = Uri.parse(
          
          //'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');

           '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
      final response = await http.put(
        url,
        body: jsonEncode({
          "appointment":"confirm",
         
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
      
        confirmsendNotificationtouser(userdeviceToken,adminname!);
        print(response.body);
      
        print('Update successful');
        _saveConfirmationState(true);
       setState(() {
          _isConfirmed = true;
        });
      } else {
        // Update failed

        print(response.body);
        print('Update failed');
      }
    }
       // Call update API if switch is turned on
    if (value) {
      print('adminuserId:${widget.adminuserid}');
      print('adminresouceId: ${widget.adminresourceid}');
      final url = Uri.parse(
          
          //'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');

           '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.adminuserid}&resourceId=${widget.adminresourceid}');
      final response = await http.put(
        url,
        body: jsonEncode({
          "bookingstatus":"true",
          "Live":"false"
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
      //  confirmsendNotificationtouser(userdeviceToken,adminname!);
        print(response.body);
      
        print('admin profile bookingstatus Update successfully');
      setState(() {
          _isConfirmed = true;
        }); 
      } else {
        print('Update failed');
      }
    }
  }

  dropbookinstatus() async {
    print('adminuserId:${widget.adminuserid}');
      print('adminresouceId: ${widget.adminresourceid}');
              final SharedPreferences prefs = await SharedPreferences.getInstance();

       final Domain = prefs.getString('domain');
    final SubDomain = prefs.getString('subdomain');
      final url = Uri.parse(
          
          //'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');

           '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.adminuserid}&resourceId=${widget.adminresourceid}');
      final response = await http.put(
        url,
        body: jsonEncode({
          "bookingstatus":"false",
          "Live":"true"
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
      //  confirmsendNotificationtouser(userdeviceToken,adminname!);
        print(response.body);
      
        print('admin profile bookingstatus Update successfully');
       
      } else {
        print('Update failed');
      }
  }

  void _openMapApp() async {
    // final String currentLat = position!.latitude.toString();
    // final String currentLon = position!.longitude.toString();
    final String shopLat = widget.userlat.toString();
    final String shopLon = widget.userlon.toString();
    print(widget.userlat);
    print(widget.userlon);
    final String googleMapsUrl =
        'https://www.google.com/maps?q=$shopLat,$shopLon';
    if (Platform.isAndroid) {
      await launch(googleMapsUrl, forceSafariVC: false);
    } else {
      await launch(googleMapsUrl, universalLinksOnly: false);
      throw 'Could not launch map app';
    }
  }
  @override
  void initState() {
    super.initState();
    _loadConfirmationState();
  }

  Future<void> _loadConfirmationState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConfirmed = prefs.getBool('isConfirmed_${widget.resouceId}_${widget.userId}') ?? false;
    });
  }

  Future<void> _saveConfirmationState(bool isConfirmed) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isConfirmed_${widget.resouceId}_${widget.userId}', isConfirmed);
  }

  void dispose(){
      // Cancel any ongoing operations here, if necessary
    super.dispose();
  }
    bool _closebuttonPressed = false;

bool _isConfirmed = false;
  @override
  Widget build(BuildContext context) {
  
  Color containerColor = _isConfirmed ? const Color.fromRGBO(165, 214, 167, 1) : const Color.fromRGBO(227, 242, 253, 1); // Set container color based on confirmation status
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
        height: 140,
        width: 380,
        decoration: BoxDecoration(
          border: const Border(left: BorderSide(color: Colors.yellow, width: 7),
         // right: BorderSide(color: Colors.yellow, width: 7)
          ),
          color: Colors.yellow, // Use containerColor
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            
               const SizedBox(height: 20),
            const SizedBox(width: 5),
            Row(
              children: [
                  Padding(padding: EdgeInsets.only(left:10)),
             
                   
                    Icon(Icons.person_pin,size: 30,),
                 const SizedBox(width: 5),
                SizedBox(
              width: MediaQuery.of(context).size.width * 0.61,
              child: Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
             Column(
               children: [
                 Text(
                      widget.date,
                      style: const TextStyle(
                        color: Colors.black,
                        //fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                widget.currentTime,
                  style: const TextStyle(
                    color: Colors.black,
                   // fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
               ],
             ),
                 
              ],
            ),
              
           
           Row(
            children: [
             
               //Padding(padding: EdgeInsets.only(left:10)), 
                       IconButton(
        onPressed: () {
          print("delete");
          DeletedialogBox(context, 'Are you sure you want to cancel the appointment for ${widget.name}?', () async {
      String msgoid = widget.oid;
      _cancelAppointment();
      dropbookinstatus();
      //closedbooking();
      //fetchData(); 
      Navigator.of(context).pop(); // Close the dialog
          }).show();
        },
        icon: 
        // const Icon(
        //   Icons.cancel,
        //   color: Colors.red,
        // )
        Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
      
            child: Icon(
      Icons.cancel,
             // size: 60.0,
      color: Colors.red,
            ),
          ),
          Text(
            'Cancel',
            style: TextStyle(
             // fontSize: 13.0,
      color: Colors.red,
      fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      
      ),
       const SizedBox(width: 7),
            Column(
              children: [
                CircleAvatar(
                       backgroundColor:Colors.white,
                  child: IconButton(
                             
                    onPressed: widget.oncall,
                    icon: const Icon(Icons.phone_in_talk_outlined, color: Color.fromARGB(255, 7, 152, 9)),
                  ),
                ),
                Text("Call",style: TextStyle(color: Color.fromARGB(255, 7, 152, 9),fontWeight: FontWeight.bold,))
              ],
            ),
          
      SizedBox(width: 10,),
         
    //  SizedBox(width: 2,),
      

   //   SizedBox(width: 5,),
      IconButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>  Mapscreen(autoclick: false,autoadmin: true,AutouserId:widget.userId),
          //   ));
          _openMapApp();
        },
        icon: 
        
        Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
      
            child: Icon(
                  Icons.track_changes,
             // size: 60.0,
                  color: Colors.blue,
            ),
          ),
          Text(
            'Track',
            style: TextStyle(
             // fontSize: 13.0,
      color: Colors.blue,
      fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      ),  
      SizedBox(width:80,),
//  _isConfirmed? IconButton(
//         onPressed: _closebuttonPressed?null: () {
      
//             showDialog(
        
//       context: context,
//       builder: (BuildContext context) {
       
//          return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.check_circle_outline,
//                  size: 60.0,
//                   color: Colors.green,
//                 ),
//                 SizedBox(height: 20.0),
//                 Text(
//                   "Confirmation",
//                   style: TextStyle(
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 Text(
//                 "Are you sure you want to drop ${widget.name}?",
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 20.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop(); // Close the dialog
//                       },
//                     ),
                      
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: Text(
//                         'Confirm',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed:(){
//                           setState(() {
//                   _closebuttonPressed = true; // Set the flag to true
//                 });
//             closedbooking();
//                 Navigator.of(context).pop();
//                       } ,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       });
//         },
//         icon: const 
//         // Icon(
//         //   Icons.pin_drop,
//         //   color: Colors.green,
//         // )
//         Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white,
//             child: Icon(
//       Icons.pin_drop,
//              // size: 60.0,
//       color: Colors.green,
//             ),
//           ),
//           Text(
//             'Drop',
//             style: TextStyle(
//              // fontSize: 13.0,
//       color: Colors.green,
//       fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ), 
//       ):
//        IconButton(
//         onPressed: () {
//        showDialog(
        
//       context: context,
//       builder: (BuildContext context) {
       
//          return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.check_circle_outline,
//                  size: 60.0,
//                   color: Colors.green,
//                 ),
//                 SizedBox(height: 20.0),
//                 Text(
//                   "Confirmation",
//                   style: TextStyle(
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 10.0),
//                 Text(
//                 "Are you sure you want to confirm the booking for ${widget.name}?",
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 20.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop(); // Close the dialog
//                       },
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: Text(
//                         'Confirm',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed:(){
//                          setState(() {
//                               _isConfirmed = true;
//                             });
//                _toggleSwitch(true);
//                 Navigator.of(context).pop();
//                       } ,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//           );
//         },
//         icon:
//         //  const Icon(
//         //   Icons.check_circle_outline,
//         //   color: Colors.yellowAccent,
//         // )
//          Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white,
//             child: Icon(
//       Icons.check_circle_outline,
//              // size: 60.0,
//       color: Colors.black,
//             ),
//           ),
          
//           Text(
//             'Confirm',
//             style: TextStyle(
//              // fontSize: 13.0,
//       color: Colors.black,
//       fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       ),



      if (_isConfirmed)
                 IconButton(
                    onPressed: _closebuttonPressed
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
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
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 60.0,
                                          color: Colors.green,
                                        ),
                                        SizedBox(height: 20.0),
                                        Text(
                                          "Confirmation",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          "Are you sure you want to drop ${widget.name}?",
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 20.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                              ),
                                              child: Text(
                                                'Confirm',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _closebuttonPressed = true; // Set the flag to true
                                                });
                                                closedbooking();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Drop',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                 else
                 IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
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
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 60.0,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 20.0),
                                  Text(
                                    "Confirmation",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    "Are you sure you want to confirm the booking for ${widget.name}?",
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: Text(
                                          'Confirm',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmed = true;
                                          });
                                          _toggleSwitch(true);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),   
      ],
           
           ),
        
           
           ],
        ),
        
      ),
    );
  }
}

