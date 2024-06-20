
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/autouser/usermap.dart';
import 'package:appointments/autouser/userreport.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
class userhome extends StatefulWidget {
 final bool userhometomap;
  const userhome( {Key? key,required this.userhometomap}) : super(key: key);

  @override
  State<userhome> createState() => _userhomeState();
}

class _userhomeState extends State<userhome> {
  
 String? Domain='';
  String? SubDomain='';
  String? userId='';
  
  
String? userName='';
String?usermobile='';


 logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? userlogin = prefs.getBool('userlogin');
           // bool? adminlogin = prefs.getBool('adminlogin');

      bool? usersignup = prefs.getBool('usersignup');
           // bool? adminsignup = prefs.getBool('adminsignup');

      bool? register = prefs.getBool('register');
      if (userlogin != null) {
        await prefs.remove('userlogin');
      }
  
      if (usersignup != null) {
        await prefs.remove('usersignup');
      }
  
    } catch (e) {
      print(e);
    }
  }

 usernamestored() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  userName=  await prefs.getString('username');
    print(" stored user name:$userName");
  }
    getShareduserId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      userName=prefs.getString("username");

      print("stored user name in userhome:$userName");
      print(userId);
      print(Domain);
      print(SubDomain);

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

  
    Future<void> liveLocationUpdate() async {
 

    // Check if the switch is turned on
  
      try {
          // await prefs.setString('createdUserId', createdUserId);
          // await prefs.setString('createdProfileId', createdProfileId);
          // await prefs.setString('createdName', createdName);
          // await prefs.setString('createdMobileNo', createdMobileNo);
         String? deviceToken = await notificationServices.getDeviceToken();
       
        final SharedPreferences prefs = await SharedPreferences.getInstance();
         String? profileobjectId=prefs.getString('createdProfileId');
       Domain = proDomain;
       //prefs.getString('adminDomain');
    SubDomain = "Auto";
    //prefs.getString('adminSubDomain');
   String? userresourceId= prefs.getString('userresourceId');
    String? userId= prefs.getString('userId');
         String? userid = prefs.getString('createdUserId');
      print("user live updating.....");
   print("user home poiddddd:$userresourceId");
    print("user home userIdddd:$userId");
    print("user domain:$Domain");
    print("user subdomain:$SubDomain");
        final response = await http.put(
          Uri.parse(Live_Url(Domain, SubDomain, userId, userresourceId)),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'location': {
              'currentlat': _currentPos?.latitude,
              'currentlon': _currentPos?.longitude
            },
            "userdeviceToken": deviceToken,
           // "update":"updating...."

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

  Timer ?_locationUpdateTimer;
// Example of how to call liveLocationUpdate when the switch is turned on
  void startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      
        _getCurrentPosition().then((value) {
          liveLocationUpdate();
          print(
              'Updated location: [${_currentPos?.latitude}, ${_currentPos?.longitude}]');
        });
      
    });
  }
 Map<String, dynamic>? providerdata;
 String? mobileno='';
  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
  
    String?  domain ="Appointment";

    // prefs.getString('domain');
    String?  subdomain = "Auto";
    //prefs.getString('subdomain');
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
         //   profileOid = firstProfileData['_id']['\$oid'];
            mobileno = firstProfileData['mobileno'];
            userName = firstProfileData['name'];
           
          //  resouceId = firstProfileData['userId']['\$oid'];
         
            print('User ID: $userId');
            print('Mobile Number: $mobileno');
           
         
            setState(() {
              providerdata = {
                'name': userName,
                'mobileno': mobileno,
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

 List<Map<String, dynamic>> bookeddata=[];
String? adminoId;
String? adminmobileno;
String? adminusername;
String? admindeviceToken;
String? userdeviceToken;
String? admincurrentDate;
String? appointmentStatus; 
String? adminname;
String? adminresourceoid;
String? adminresourceuserid;
List<Map<String, String>> bookingIds = [];
Future<void> autofetchautobookedData() async {
  try {
      setState(() {
     isLoading=true;
   });

    print("Fetching booking data...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
      String?Domain =
      "Appointment"; 
    //prefs.getString('adminDomain');
     String? SubDomain =
    // "Auto";
      prefs.getString('AutoSubDomain');
      
    String?  userid = prefs.getString('userId');
    print("Domain: $Domain");
    print("Subdomain: $SubDomain");
    print("User ID: $userid");
          // Get the current date
      DateTime currentDate = DateTime.now();
 String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
          print("current date:$formattedDate");
    final response = await http.get(
      Uri.parse(
        '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$userid&filtercount=2&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=appointment_S&f2_op=ne&f2_value=dropped'
      ),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Booked profile data: ${response.body}");
      if (data.containsKey('source') && data['source'] is List) {
        var sourceList = data['source'] as List;

       

        if (sourceList.isNotEmpty) {
          List<Map<String, dynamic>> tempList = [];
          for (var profileData in sourceList) {
            var profile = jsonDecode(profileData);
 String oid = profile['_id']['\$oid'];
            String userid = profile['userId']['\$oid'];
 adminresourceoid=profile['adminresourceId'];
 adminresourceuserid=profile['adminId'];
            // Store user ID and OID in session
            await prefs.setString('booking_userId', userid);
            await prefs.setString('booking_oid', oid);

                await prefs.setString('userresourceId', oid);
      
           

            // Store user ID and OID in variables
            bookingIds.add({'userid': userid, 'oid': oid});


            tempList.add({
              'adminname': profile['adminname'],
              'name': profile['name'],
              'adminmobileno': profile['adminmobileno'],
              'admindeviceToken': profile['admindeviceToken'],
              'userdeviceToken': profile['userdeviceToken'],
              'currentDate': profile['currentDate'],
              'appointmentStatus': profile['appointment'],
              'domain': profile['domain'],
              'subdomain': profile['subdomain'],
              "oid":profile['_id']['\$oid'],
              "userid":profile['userId']['\$oid'],
              "adminresourceId":profile['adminresourceId'],
              "adminuserId":profile['adminId'],
               "currentTime":profile['currentTime'],
               "business":profile['business name'],
               "appointment":profile["appointment"]
            });
          }
          setState(() {
            bookeddata = tempList;
           // isLoading=false;
          });
        } else {
            setState(() => bookeddata = []);
          print('Profile data not found in the response');
        }
      } else {
         setState(() => bookeddata = []);
        print('Source key not found or not a list in the response');
      }
    } else {
        setState(() => bookeddata = []);
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
      setState(() => bookeddata = []);
    print('An error occurred: $e');
  }
  finally {
      setState(() => isLoading = false);
    }
}
  List<ReportContainer> reportContainers = [];
 Future<void> saloonfetchbookedData() async {
  try {
   setState(() {
     isLoading=true;
   });

    print("Fetching saloon booking data...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
      String?Domain =
      "Appointment"; 
    //prefs.getString('adminDomain');
     String? SubDomain =
    // "Auto";
      prefs.getString('SaloonSubDomain');
      
    String?  userid = prefs.getString('userId');
    print("Domain: $Domain");
    print("Subdomain: $SubDomain");
    print("User ID: $userid");
          // Get the current date
      DateTime currentDate = DateTime.now();
 String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
          print("current date:$formattedDate");
    final response = await http.get(
      Uri.parse(
        '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$userid&filtercount=2&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=appointment_S&f2_op=ne&f2_value=completed'
      ),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Booked profile data: ${response.body}");
      if (data.containsKey('source') && data['source'] is List) {
        var sourceList = data['source'] as List;

       

        if (sourceList.isNotEmpty) {
          List<Map<String, dynamic>> tempList = [];
          for (var profileData in sourceList) {
            var profile = jsonDecode(profileData);
 String oid = profile['_id']['\$oid'];
            String userid = profile['userId']['\$oid'];
 adminresourceoid=profile['adminresourceId'];
 adminresourceuserid=profile['adminId'];
  String? shoplocation=profile['location'].toString();
            // Store user ID and OID in session
            await prefs.setString('booking_userId', userid);
            await prefs.setString('booking_oid', oid);

                await prefs.setString('userresourceId', oid);
      
         print("shoplocation:$shoplocation");

            // Store user ID and OID in variables
            bookingIds.add({'userid': userid, 'oid': oid});


            tempList.add({
              'adminname': profile['adminname'],
              'name': profile['name'],
              'adminmobileno': profile['adminmobileno'],
              'admindeviceToken': profile['admindeviceToken'],
              'userdeviceToken': profile['userdeviceToken'],
              'currentDate': profile['currentDate'],
              'appointmentStatus': profile['appointment'],
              'domain': profile['domain'],
              'subdomain': profile['subdomain'],
              "oid":profile['_id']['\$oid'],
              "userid":profile['userId']['\$oid'],
              "adminresourceId":profile['adminresourceId'],
              "adminuserId":profile['adminId'],
               "currentTime":profile['currentTime'],
               "business":profile['business name'],
               "appointment":profile["appointment"],
               "gender":profile["gender"],
               "shoplat":profile['shoplocation']?['shoplat']??'',
                 "shoplon":profile['shoplocation']?['shoplon']??'',
            });
          }
          setState(() {
            bookeddata = tempList;
            //isLoading=false;
          });
        } else {
           setState(() => bookeddata = []);
          print('Profile data not found in the response');
        }
      } else {
             setState(() => bookeddata = []);
        print('Source key not found or not a list in the response');
      }
    } else {
           setState(() => bookeddata = []);
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
         setState(() => bookeddata = []);
    print('An error occurred: $e');
  }
  finally {
      setState(() => isLoading = false);
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
 String? username;
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }
 bool _ratingPopupShown = false;
 
Future<void> _ratingshowAlertDialog(
      BuildContext context, String? title, String? body) async {
    void updateAPI(double rating) async {
      print("ratinggggggggggggggggg    updatedddddddddddddddddddddddddddddddddddddddddddddd");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final domain = proDomain;
      //prefs.getString('adminDomain') ?? ''; // Corrected variable name
      final subDomain = prefs.getString('adminSubDomain') ?? ''; // Corrected variable name
       String adminobjectId = prefs.getString("booking_oid")??'';
      String adminuserId = prefs.getString('booking_userId') ?? '';
      print("adminDomain:$domain");
       print("adminSubDomain:$subDomain");
      print("admin oid:$adminobjectId");
      print("admin userid:$adminuserId");


  // Fetch existing ratings and calculate the new average
  final List<double> ratings = prefs.getStringList('ratings')?.map((r) => double.parse(r)).toList() ?? [];
  ratings.add(rating);
  double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

  // Store updated ratings list
  prefs.setStringList('ratings', ratings.map((r) => r.toString()).toList());


      final apiUrl = Uri.parse(
          '$base_url/eUpdate?domain=$domain&subdomain=$subDomain&userId=$adminresourceuserid&resourceId=$adminresourceoid');
      try {
        // Sending a PUT request
        final response = await http.put(
          apiUrl,
          body: jsonEncode({
            "feedback":  averageRating.toStringAsFixed(1), // Ensure one decimal place
            "Live":"true"
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        // Check if the request was successful (status code 200)
        if (response.statusCode == 200) {
          print(response.body);
          print('ratingggggggg updated successfully:${averageRating.toStringAsFixed(1)}');
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>   userhome(userhometomap: false,),
            ));
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            title ?? "Notification",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                body ?? "You have received a notification.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please rate your experience with us",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  itemSize: 30,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print('Rating: $rating'); // Print the rating value
                    updateAPI(rating);
                  },
                ),
              ),
            ],
          ),
          actions: [
            FittedBox(
              child: Container(
                height: 40,
                width: 60,
                decoration: const BoxDecoration(color: Colors.green),
                child: TextButton(
                  child: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                 autofetchautobookedData();
                      setState(() {
                      _ratingPopupShown = true;
                    });
                  },
                ),
              ),
            ),
          ],
        );},
        );
      }

  bool _disposed = false;
  
 
void _handleNotification(String? title, String? body) {
    if (title == "Thank you" && body == "Give me your rating please...........") {
      if (mounted && !_ratingPopupShown) {
        _ratingshowAlertDialog(context, title, body);
      }
    } 
}
void _handleNotificationsaloon(String? title, String? body) {
    if (title == "Thank you" && body == "Please visit again!") {
      if (mounted && !_ratingPopupShown) {
        _ratingshowAlertDialog(context, title, body);
      }
    } 
}

  late StreamSubscription<RemoteMessage> _messageStreamSubscription;

  Timer?pagerefresh;
  void autorefreshmethod() {
   
    pagerefresh = Timer.periodic(Duration(seconds: 10), (timer) {
     autofetchautobookedData();
   
    });
  }
   void saloonrefreshmethod() {
   
    pagerefresh = Timer.periodic(Duration(seconds: 10), (timer) {
    
     saloonfetchbookedData();
    });
  }
  bool? fromwhichmap;
// Future<void> pagerefreshmethod() async {
   
//     pagerefresh = Timer.periodic(Duration(seconds: 3), (timer) {
      
//       if (autostate) {
        
//         autofetchautobookedData();
//       } else if (saloonstate) {
//         saloonfetchbookedData();
//       }
//     });
//   }
  bool autostate=false;
  bool saloonstate=false;
  @override
  void initState() {
  
      _loadUsername();
   startLocationUpdateTimer();
    print("widget.userhometomap${widget.userhometomap}");
    print("fromwhichmap:$fromwhichmap");
//widget.userhometomap==true?autofetchautobookedData:saloonfetchbookedData;
// saloonfetchbookedData();
//       autofetchautobookedData();
      //widget.userhometomap?fetchbookedData:print("maptohome user........................");
    super.initState();
        getShareduserId();
      
        //fetchProfileData();
      
      
        usernamestored();
        print("username:$userName");
    _handleLocationPermission();
   
   
 
    _messageStreamSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (_disposed) {
        return; // Bail out if widget is disposed
      }
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _handleNotification(
            message.notification!.title, message.notification!.body);
             _handleNotificationsaloon(
            message.notification!.title, message.notification!.body);
      }
     
    });
   
}

//   @override
//   void dispose() {
//     pagerefresh!.cancel();
//     _disposed = true;
//     _messageStreamSubscription.cancel();
//     super.dispose();
// }
List<bool> isSelected = [false, false, false, false,false];
void handleChipSelection(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = (i == index);
      }

      switch (index) {
        case 0:
          reportContainers.clear();
          break;
        case 1:
          reportContainers.clear();
          break;
        case 2:
          reportContainers.clear();
          break;
        case 3:
          reportContainers.clear();
          //  markers.clear();

          break;
        case 4:
          reportContainers.clear();
          // markers.clear();

          break;
        case 5:
          reportContainers.clear();
          //markers.clear();

          break;
      }
    });
  }

  void _handleGenderSelection(String cat) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cat', cat);
      print('Category updated: $cat');
    } catch (e) {
      print('Error updating category: $e');
    }
  }
  @override
  void dispose() {
    _disposed = true;
    _messageStreamSubscription.cancel();
    _locationUpdateTimer!.cancel();
   // pagerefresh!.cancel();
    super.dispose();
  }
 bool isLoading = false; // Track loading state
  @override
  Widget build(BuildContext context) {
    return username  !=null?Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
      leading: Padding( padding: const EdgeInsets.only(
                 left: 10,),
          child: GestureDetector(
            onTap: (){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  ChooseAppointmentscreen()));
            },
            child: Icon(Icons.arrow_back_ios,color: Colors.white,),
          )),
         actions: [
          IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => userReport(

            ),
          ),
        ).then((value) async {
               // await fetchbookedData();
                     
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => userhome(userhometomap: false,

            ),
          ));
                });
        
      },
      icon: const Icon(
        Icons.history,
        color: Colors.white,
      )
    ),
     
         ],
        backgroundColor: Colors.teal,
        title:  
       Text(
          username!,
        //  providerdata!["name"],
          style: TextStyle(color: Colors.white)
        ),
      ),
   body:
      Column(
      children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // SelectableChip(
                //   txt: "CLINIC",
                //   bordercolor: Colors.white,
                //   selectedIcon: CupertinoIcons.bandage,
                //   selectedTextColor: Colors.white,
                //   isSelected: isSelected[0],
                //   onTap: () async {
                //     handleChipSelection(0);
                //     _handleGenderSelection('Clinic');
                //     // await _fetchMarkerPositions();
                //   },
                //   selectedColor: Colors.blue,
                //   selectedIconcolor: Colors.white,
                // ),
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
setState(() {
 // autorefreshmethod();
  reportContainers.clear();
});
                    handleChipSelection(1);
                  await autofetchautobookedData();
                  },
                ),
                // SelectableChip(
                //   selectedColor: Color.fromARGB(255, 240, 190, 64),
                //   selectedIconcolor: Colors.white,
                //   txt: "PETS",
                //   bordercolor: Colors.white,
                //   selectedIcon: CupertinoIcons.paw_solid,
                //   selectedTextColor: Colors.white,
                //   isSelected: isSelected[2],
                //   onTap: () async {
                //     _handleGenderSelection('Pets');
                //     handleChipSelection(2);
                //     //  await _fetchMarkerPositions();
                //   },
                // ),
                SelectableChip(
                  selectedColor: Colors.black,
                  txt: "SALOON",
                  bordercolor: Colors.white,
                  selectedIconcolor: Colors.white,
                  isSelected: isSelected[3],
                  onTap: () async {
                    _handleGenderSelection('Saloon');
                    setState(() {
                      //saloonrefreshmethod();
  reportContainers.clear();
});
                    handleChipSelection(3);
                    await saloonfetchbookedData();
                    ;
                  },
                  selectedIcon: CupertinoIcons.scissors,
                  selectedTextColor: Colors.white,
                ),
                // SelectableChip(
                //   selectedIconcolor: Colors.white,
                //   selectedColor: Colors.amber,
                //   txt: "TAXI",
                //   isSelected: isSelected[4],
                //   onTap: () async {
                //     _handleGenderSelection('Taxi');

                //     handleChipSelection(4);
                //     // await _fetchMarkerPositions();
                //   },
                //   selectedIcon: CupertinoIcons.car,
                //   selectedTextColor: Colors.white,
                //   bordercolor: Colors.white,
                // )
              ],
           ),
),
      //  Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //    children: [
      //      CircleAvatar(
      //       maxRadius: 20,
      //       backgroundColor: Colors.transparent,
      //       child: GestureDetector
      //       (
      //         onTap: (){
      //             setState(() {
      //                           autostate = true;
      //                           saloonstate = false;
      //                         });
      //           autofetchautobookedData();
      //         },
      //         child: Image.asset("assets/autohd.png"))),
      //         SizedBox(width: 10,),
      //           CircleAvatar(
      //   maxRadius: 20,
      //   child: GestureDetector
      //   (
      //     onTap: (){
      //         setState(() {
      //                           autostate = false;
      //                           saloonstate = true;
      //                         });
      //       saloonfetchbookedData();
      //     },
      //     child: Image.asset("assets/saloonmap.jpg"))),
      //    ],
      //  ),


        // Column(
        //   children: [
        //     IconButton(onPressed: (){
        //     Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => userhome(userhometomap: false,),
        //   ));
        //     }, icon: Icon(Icons.refresh)),
        //     Text("Refresh")
        //   ],
        // ),
         
        SizedBox(height: 20,),
        
//   if(isLoading)
// Center(child: SizedBox(height :500,child: Center(child: CircularProgressIndicator(color: Colors.yellow,))))
// else
// bookeddata.isNotEmpty?
//         Expanded(
          
//          child: 
//         //  bookeddata.isNotEmpty
//         //       ? 
//               ListView.builder(
//                   itemCount: bookeddata.length,
//                   itemBuilder: (context, index) {
//                    // final bookedData = bookeddata[index];
//                       final bookedData = bookeddata[index];
//                             final serialNumber = index + 1;

//                             void onCreatedCallback() {
//                               print("mobile:${bookedData['adminmobileno']}");
//                               print(
//                                   'resouceId: ${bookedData['oid'].toString()??"no oid"}');
//                               print(
//                                   'userId: ${bookedData['userid'].toString()?? '--'}');
//                             }
//                     return 
                    
//                     userbooked(
                   
//                      // oid:bookedData['_id']["\$oid"] ?? '',
//                               num: '$serialNumber',
//                               username:username!,
//                               adminuserid:bookedData['adminuserId'] ?? '',
//                               adminuresourceid:bookedData['adminresourceId'] ?? '',
//                               name: bookedData['adminname'] ?? '',
//                               business: bookedData['business'] ?? '',
//                               Date: bookedData['currentDate'] ?? '--',
//                                 Time: bookedData['currentTime'] ?? '--',
//                              // toogle: true,
//                              userId:bookedData['userid'].toString()??"----",
//                               // bookedData.containsKey('userId')
//                               //    ? bookedData['userId']['\$oid'].toString()
//                               //     : '--',
//                               oncall: () {
//                                 _callNumber(bookedData['adminmobileno'] ?? "");
//                               },
//                               resouceId: bookedData['oid'].toString()??'--',
//                               // bookedData.containsKey('_id')
//                               //     ? bookedData['_id']['\$oid'].toString()
//                               //     : '--',
//                              onCreated: onCreatedCallback,
//                               onpressdelete: true, 
//                               bookedData: bookeddata,
//                               // index: index, 
//                               admideviceToken: bookedData['admindeviceToken'] ?? '',
//                               appointment:bookedData['appointment']??'',
//                               gender:bookedData['gender']??"",
                              
//                     );
                    

//                   },
//                 )
//             //  : 
             
//         //       Center(child: Text('Not booked yet',style: TextStyle(color: Colors.grey,fontSize: 26),)
//         // )
//         ):  SizedBox(
//           height: 500,
//           child: Center(child: Text('Not booked yet',style: TextStyle(color: Colors.grey,fontSize: 26),)
//           ),
//         )

        Expanded(
          
         child:  isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.teal,))
        : bookeddata.isNotEmpty
              ? 
              ListView.builder(
                  itemCount: bookeddata.length,
                  itemBuilder: (context, index) {
                   // final bookedData = bookeddata[index];
                      final bookedData = bookeddata[index];
                            final serialNumber = index + 1;

                            void onCreatedCallback() {
                              print("mobile:${bookedData['adminmobileno']}");
                              print(
                                  'resouceId: ${bookedData['oid'].toString()??"no oid"}');
                              print(
                                  'userId: ${bookedData['userid'].toString()?? '--'}');
                            }
                    return 
                    
                    userbooked(
                   
                     // oid:bookedData['_id']["\$oid"] ?? '',
                              num: '$serialNumber',
                              username:username!,
                              adminuserid:bookedData['adminuserId'] ?? '',
                              adminuresourceid:bookedData['adminresourceId'] ?? '',
                              name: bookedData['adminname'] ?? '',
                              business: bookedData['business'] ?? '',
                              Date: bookedData['currentDate'] ?? '--',
                                Time: bookedData['currentTime'] ?? '--',
                             // toogle: true,
                             userId:bookedData['userid'].toString()??"----",
                              // bookedData.containsKey('userId')
                              //    ? bookedData['userId']['\$oid'].toString()
                              //     : '--',
                              oncall: () {
                                _callNumber(bookedData['adminmobileno'] ?? "");
                              },
                              resouceId: bookedData['oid'].toString()??'--',
                              // bookedData.containsKey('_id')
                              //     ? bookedData['_id']['\$oid'].toString()
                              //     : '--',
                             onCreated: onCreatedCallback,
                              onpressdelete: true, 
                              bookedData: bookeddata,
                              // index: index, 
                              admideviceToken: bookedData['admindeviceToken'] ?? '',
                              appointment:bookedData['appointment']??'',
                              gender:bookedData['gender']??"",
                               shoplat:bookedData['shoplat']??"",
                                shoplon:bookedData['shoplon']??"",
                              
                    );
                    

                  },
                )
             : 
             
              Center(child: Text('Not booked yet',style: TextStyle(color: Colors.grey,fontSize: 26),)
        )
        )
      ],
    )
    ): 
    Center(
                  child:CircularProgressIndicator(color: Colors.blue,) );
                
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
  

class userbooked extends StatefulWidget {
  final String Time;
  final String num;
  final String name;
  final String adminuserid;
  final String adminuresourceid;
  final String Date;
   final String shoplat;
    final String shoplon;
final String business;
  final VoidCallback oncall;
 final VoidCallback? onCreated;
  final bool onpressdelete;
  // final bool toogle;
  final String resouceId;
  final String userId;
  final String username;
  final String admideviceToken;
   final String appointment;
final List<Map<String, dynamic>> bookedData;
final String gender;
  const userbooked({
    Key? key,
    required this.adminuresourceid,
      required this.adminuserid,
       required this.business,
       required this.Time,
        required this.num,
        required this.shoplat,
        required this.shoplon,
          required this.gender,
    required this.onpressdelete,
    required this.name,
    required this.appointment,
   
   required this.bookedData,
    required this.userId,
     required this.resouceId,
     this.onCreated,
    required this.oncall, 
    required this.username,
   required this.admideviceToken, required this.Date
  }) : super(key: key);

  @override
  State<userbooked> createState() => _userbookedState();
}


class _userbookedState extends State<userbooked> {
 void _openMapApp() async {
    // final String currentLat = position!.latitude.toString();
    // final String currentLon = position!.longitude.toString();
    final String shopLat = widget.shoplat.toString();
    final String shopLon = widget.shoplon.toString();
    print("shop latttttttttttttttttttttttttttttttt${widget.shoplat}");
    print("shop lannnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn${widget.shoplon}");
    final String googleMapsUrl =
        'https://www.google.com/maps?q=$shopLat,$shopLon&destination=$shopLat,$shopLon';
    if (Platform.isAndroid) {
      await launch(googleMapsUrl, forceSafariVC: false);
    } else {
      await launch(googleMapsUrl, universalLinksOnly: false);
      throw 'Could not launch map app';
    }
  }
  void fetchData() async {
   

    try {
      salonData.clear();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String businessname = prefs.getString('business name') ?? "";
      final Domain = prefs.getString('domain');
      final SubDomain = widget.business;
      print(businessname);
      // Get the current date
      DateTime currentDate = DateTime.now();
      // Format the date according to your API URL format (assuming dd/MM/yy)
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
          print("current date:$formattedDate");
      final fetch =     
                   
      //  'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=business name_S&f2_op=eq&f2_value=$businessname&f3_field=status_S&f3_op=eq&f3_value=true';
         '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&filtercount=2&f1_field=appointment_S&f1_op=ne&f1_value=completed&f2_field=currentDate_S&f2_op=eq&f2_value=$formattedDate';

         //'$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=business name_S&f2_op=eq&f2_value=$businessname&f3_field=status_S&f3_op=eq&f3_value=true';
      final response = await http.get(Uri.parse(fetch));
      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
    
         print("timeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee:${widget.Time}");
        // Parse the JSON response
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

  bool _switchValue = false;

  bool _isProcessing = false;
  List<Map<String, dynamic>> salonData = [];

Future<void> _cancelAppointment() async {

  print("deletingggggg......");
  print("widget.business:${widget.business}");
  // Get shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? domain = prefs.getString('domain');
  final String? subDomain = widget.business;
  //prefs.getString('subdomain');
  final String? adminName =  widget.username;

  // Log necessary values
  print(domain);
  print(subDomain);
  print('userId: ${widget.userId}');
  print('resouceId: ${widget.resouceId}');
  print('admindeicetokennnn: ${widget.admideviceToken}');
  print('adminName: $adminName');

  

  String admindeviceToken = widget.admideviceToken;

  // Construct delete URL
  final String deleteUrl = '$base_url/eDelete?domain=$domain&subdomain=Saloon&userId=${widget.userId}&resourceId=${widget.resouceId}';

  // Perform the delete request
  var response = await http.delete(Uri.parse(deleteUrl));

  // Check the response status
  if (response.statusCode == 200) {
     updateadminstatus();
     cancelsendNotificationtouser(widget.admideviceToken, widget.username);
    print(response);
    print('Appointment canceled successfully');
    snackbar_green(context, "Appointment canceled successfully");
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>   userhome(userhometomap:false),
            ));
      //fetchData();
           
  } else {
    // Log error if the cancellation fails
    print('Failed to cancel appointment. Status code: ${response.statusCode}');
  }
    // Call update API if switch is turned on
}
updateadminstatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? domain = prefs.getString('domain');
  final String? subdomain = prefs.getString('subdomain');
  
 // final String base_url = 'https://example.com'; // Replace with your base URL

  print('adminuserId...........................:${widget.adminuserid}');
  print('adminresouceId...........................: ${widget.adminuresourceid}');
print("domain:$domain");
print("subdomain:$subdomain");
  final url = Uri.parse(
    '$base_url/eUpdate?domain=$domain&subdomain=Auto&userId=${widget.adminuserid}&resourceId=${widget.adminuresourceid}'
  );

  try {
    final response = await http.put(
      url,
      body: jsonEncode({"bookingstatus": "false","Live":"true"}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('admin profile bookingstatus Update successfully');
      print(response.body);
    } else {
      print('admin booking status Update failed');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
Future<void> cancelsendNotificationtouser(
String userdeviceToken,String username
  ) async {
    
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
    'body': 'The booking has been cancelled by $username', // Include username in the notification body
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
bool _isConfirmed = false;
  @override
  Widget build(BuildContext context) {
    print("gendeerrrrrrrrrrr:${widget.gender}");

    if (widget.onCreated != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCreated!();
      });
    }

    
  Color containerColor = _isConfirmed ? const Color.fromRGBO(165, 214, 167, 1) : const Color.fromRGBO(227, 242, 253, 1); // Set container color based on confirmation status
    return Stack(
      clipBehavior: Clip.none, children: [
        
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Container(
          height: 140,
          width: 380,
          decoration: 
          // widget.appointment=="confirm"?  BoxDecoration(
          //   border:  Border(left: BorderSide(color: widget.business=="Auto"?Colors.yellow:Colors.teal,width: 10),
          //  // right: BorderSide(color: Colors.yellow, width: 7)
          //   ),
          //   color: Colors.lightGreen, // Use containerColor
          //   borderRadius: BorderRadius.circular(10),
          // ):
          BoxDecoration(
            border:  Border(left: BorderSide(color: widget.business=="Auto"?Colors.yellow:Colors.black,width: 10),
           // right: BorderSide(color: Colors.yellow, width: 7)
            ),
            color: widget.business=="Auto"?Color.fromARGB(255, 248, 243, 201):   const Color.fromARGB(255, 223, 214, 214), // Use containerColor
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
                                const SizedBox(height: 20),
              const SizedBox(width: 5),
              Row(
                children: [
                    Padding(padding: EdgeInsets.only(left:10)),
           widget.business=="Auto"?     CircleAvatar(
                        backgroundColor:Colors.transparent,
                        maxRadius: 15,
                          child: Image.asset(
                            "assets/autohd.png",
                            // width: MediaQuery.of(context).size.width * 0.40,
                            // height: MediaQuery.of(context).size.height * 0.16,
                           // fit: BoxFit.cover,
                          ),
                        ): CircleAvatar(
                        backgroundColor:Colors.transparent,
                        maxRadius: 15,
                          child:
                          
                          widget.gender=="Male"? Image.asset(
                            "assets/mensaloon.png",
                          ):widget.gender=="Female"?Image.asset(
                            "assets/femalesaloon.png",
                          ):Image.asset(
                            "assets/unisaloon.png",
                          )
                        ),
                   const SizedBox(width: 5),
                  SizedBox(
                width: MediaQuery.of(context).size.width * 0.60,
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
                   Text(  widget.Date,
                        style: const TextStyle(
                          color: Colors.black,
                          //fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    
                 ],
               ),
                   
                ],
              ),
                
             
             Row(
              children: [
                SizedBox(width: 20,),
                 Column(
                   children: [
                     Text(
                            widget.Time,
                        style: TextStyle(
                          color: Colors.teal,
                         // fontWeight: FontWeight.bold,
                          fontSize: 20
                          
                        ),
                      ),
                widget.appointment=="confirm"?      Row(
                   children: [
                     CircleAvatar(
                      maxRadius: 15,
                                   backgroundColor: Colors.green,
                             
                                   child: Icon(
                             Icons.check_circle_outline,
                                    // size: 60.0,
                             color: Colors.white,
                                   ),
                                 ),
            SizedBox(width: 2,),
                     Text(
                               "Booked",
                            style: TextStyle(
                              color: Colors.green,
                             // fontWeight: FontWeight.bold,
                              fontSize: 16
                              
                            ),
                          ),
                   ],
                 ):SizedBox(),

                   ],
                 ),
             //widget.business=="Auto"?   
             Spacer()
             ,
            //  :
            //    
                 //Padding(padding: EdgeInsets.only(left:112)), 
                 
              Column(
                children: [
                  CircleAvatar(
                         backgroundColor:Colors.white,
                    child: 
                                 IconButton(
                onPressed: widget.oncall,
                icon: const Icon(Icons.phone_in_talk_outlined, color: Colors.green),
              ),
                  ),
                  Text("Call",style: TextStyle(color: Color.fromARGB(255, 7, 152, 9),fontWeight: FontWeight.bold,))
                ],
              ),
           widget.business!="Auto"?    SizedBox(width: 13,):SizedBox(),
             widget.business!="Auto"? Column(
                  children: [
                    CircleAvatar(
                      // maxRadius: 15,
                      backgroundColor: Colors.white,
                      child: IconButton(
                          onPressed: () {
                            _openMapApp();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.my_location,
                            color: Colors.blue,
                          )),
                    ),
                    Text("Track",
                        style: TextStyle( color: Colors.blue,fontWeight: FontWeight.bold)),
                  ],
                ):SizedBox(),
        SizedBox(width: 10,),
        
           widget.appointment=="waiting"?

            Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                        
                  child: 
                 Image.asset("assets/waiting.png",height: 25,color:Colors.black,)
                ),
                 Text("Waiting",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,))
              ],
            ):widget.business!="Auto"? Padding(
              padding: const EdgeInsets.only(right:10),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                          
                    child: 
                    Icon(Icons.cut_outlined,color: Colors.blue[900],)
                  ),
                  Text(
                'Process',
                style: TextStyle(
                 // fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                ),
              ),
                        
                ],
              ),
            ):SizedBox(),
        widget.appointment!="process"?
          IconButton(
         onPressed: () {
            print("delete");
            DeletedialogBox(context, 'Are you sure you want to cancel the appointment for ${widget.name}?', () async {
            
         _cancelAppointment();
        
        
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
        
        ):SizedBox(),
   widget.business=="Auto"?   //SizedBox(width: 10,)
        IconButton(
           onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>   userMapscreen(autoclick: false, autoadmin: false, AutouserId: '',userhometomap:true,adminuserid:widget.adminuserid),
            ));
          },
          icon:
          Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
        Icons.my_location,
               // size: 60.0,
        color: Colors.blueAccent,
              ),
            ),
            Text(
              'Track',
              style: TextStyle(
               // fontSize: 13.0,
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
        
        ):SizedBox(),
              ],
             )
        
            ],
          ),
          
        ),
      ),
    ]);
  }
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