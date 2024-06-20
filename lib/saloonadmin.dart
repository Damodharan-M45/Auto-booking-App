// ignore_for_file: prefer_const_literals_to_create_immutables, library_private_types_in_public_api, non_constant_identifier_names, avoid_print, unused_import, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:appointments/Auto/auto_report.dart';
import 'package:appointments/Editprofile.dart';
import 'package:appointments/Provider/Drawer.dart';
import 'package:appointments/Provider/Reportscreen.dart';
import 'package:appointments/Provider/choosebusiness.dart';
import 'package:appointments/Provider/feedback.dart';
import 'package:appointments/Push_notification.dart';
import 'package:appointments/Regesterscreen/commonScreen.dart';
import 'package:appointments/notify/notification.dart';
import 'package:flutter/widgets.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:appointments/property/utlis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SalonBookscreen extends StatefulWidget {
  const SalonBookscreen({super.key});

  @override
  State<SalonBookscreen> createState() => _SalonBookscreenState();
}

class _SalonBookscreenState extends State<SalonBookscreen> {
  String? userId;
  String? Domain;
  String? SubDomain;
  String? mobileno;
  String? name;
  String? bussinessname;
  String? shopadress;
  String? proname;
  String? resouceId;
  String? aboutbussines;
  String? profileOid;
  String? oid;
  String? DeviceToken;
  String? business_name;

  String? gender;
  Map<String, dynamic>? providerdata;
  bool _switchValue = false;

  Color PetsColor = Color.fromARGB(255, 253, 200, 66);
  Future<void> liveLocationUpdate(bool isLive) async {
    try {
      print("Live updating: isLive = $isLive");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? profileOid = prefs.getString('profileOid');
      String? userId = prefs.getString('userId');
      String? domain = prefs.getString('domain');
      String? subDomain = prefs.getString('subdomain');
      print(
          "User details: userId = $userId, profileOid = $profileOid, domain = $domain, subDomain = $subDomain");
      if (userId == null ||
          profileOid == null ||
          domain == null ||
          subDomain == null) {
        print('Missing user details in SharedPreferences');
        return;
      }

      final response = await http.put(
        Uri.parse(
            "https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$domain&subdomain=$subDomain&userId=$userId&resourceId=$profileOid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Live": isLive ? "true" : "false"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _switchValue = isLive;
        });
        print(
            'Live location turned ${isLive ? "on" : "off"} updated successfully');
        print("Response: ${response.body}");
        // Save the state in SharedPreferences
        await prefs.setBool('isLive', isLive);
      } else {
        print(
            'Failed to update live location. Status code: ${response.statusCode}');
        print("Response: ${response.body}");
      }
    } catch (e) {
      print('Error updating live location: $e');
    }
  }

  Future<void> sendNotificationToUser(String message) async {
    print("hiii");
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'Dear Shop Owners', message, platformChannelSpecifics);
  }

  Future<void> setSharedUserId(
      String userId, String profileOid, String domain, String subDomain) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('profileOid', profileOid);
    await prefs.setString('Domain', domain);
    await prefs.setString('SubDomain', subDomain);
    print(
        "Shared preferences set: userId=$userId, profileOid=$profileOid, Domain=$domain, SubDomain=$subDomain");
  }

  Future<void> ShopNotification() async {
    // Your FCM server key
    print(DeviceToken);
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(DeviceToken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': "Dear Shop Owners",
        'body':
            "Please be reminded that the shop will be closing today at 9'O clock . Kindly ensure all necessary preparations are made to close the shop in an orderly manner. Thank you for your cooperation."
      },
      // 'to':
      //     "frt-Usw7T3mOo6L2hx9jVg:APA91bGEorZU1CUCKmz4EVf1QllCigixOXFBNc2GUw-cl-OfOlc60THxb7dbOi4AWLVA74s5y6jRAXTUTorPzRUGP3ahp7Nvy3LSsF1Ddu8PL-tSUy1-aJ2Hwv3U7zvGxcBhhmHuznEy"
      'to': DeviceToken,
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

  Future<void> _initializeLiveLocation() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLive = prefs.getBool('isLive');
      print("Initializing live location: isLive = $isLive");

      if (isLive == null || !isLive) {
        setState(() {
          _switchValue = false;
        });
        await prefs.setBool('isLive', false);
      } else {
        print("Live location already active.");
        print("Live location not active, turning on...");
        await liveLocationUpdate(true);
        setState(() {
          _switchValue = true;
        });
      }

      // Schedule a notification for 15:30
      final DateTime now = DateTime.now();
      final DateTime notificationTime =
          DateTime(now.year, now.month, now.day, 12, 00);
      if (now.hour < 12 || (now.hour == 12 && now.minute < 00)) {
        final Duration duration = notificationTime.difference(now);
        Timer(duration, () {
          sendNotificationToUser(
              "Please be reminded that the shop will be closing today at 9'O Clock. Kindly ensure all necessary preparations are made to close the shop in an orderly manner. Thank you for your cooperation.");
        });
      }
    } catch (e) {
      print('Error initializing live location: $e');
    }
  }

  String? feedback;
  String? shop_name;
  Color saloncolor1 = Color.fromARGB(255, 90, 239, 31);
  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Live', true);
      userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      print(Domain);
      print(SubDomain);
      final response = await http.get(
        Uri.parse(profileRead_url(userId, Domain, SubDomain)),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // print("profile data is :${response.body}");
        if (data.containsKey('source') && data['source'] is List) {
          var sourceList = data['source'] as List;
          // Assuming you only need the first profile
          if (sourceList.isNotEmpty) {
            var firstProfileData = jsonDecode(sourceList.first);
            profileOid = firstProfileData['_id']['\$oid'];
            mobileno = firstProfileData['mobileno'];
            name = firstProfileData['name'];
            bussinessname = firstProfileData['business name'];
            shopadress = firstProfileData['shop address'];
            gender = firstProfileData['gender'];
            aboutbussines =
                firstProfileData['about business'] ?? 'Default Name';
            feedback = firstProfileData['feedback'];
            resouceId = firstProfileData['userId']['\$oid'];
            DeviceToken = firstProfileData['DeviceToken'];
            business_name = firstProfileData['business name'];
             shop_name = firstProfileData['shopname'];
            // Add more variables as needed
            // Print or use the variables as needed
            print('User ID: $userId');
            print(DeviceToken);
            print(gender);
            print(business_name);
            print('Mobile Number: $mobileno');
            print('Profile URL: $aboutbussines');
            print('Name: $bussinessname');
            print('Category: $profileOid');
            // Print or use more variables as needed'
            // prefs.setString('clientRole', clientRole ?? 'defaultRole');
            prefs.setString('business name', bussinessname ?? "");
            prefs.setString('profileOid', profileOid ?? "");
            print(bussinessname);
            print(profileOid);

            setState(() {
              providerdata = {
                'name': name,
                'mobileno': mobileno,
                "business name": bussinessname,
                "about business": aboutbussines,
                "shop address": shopadress,
                "feedback": feedback
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
  Future<void> RefreshData() async {
    try {
      if (!mounted) return;
      setState(() {
        salonData.clear();
      });
      salonData.clear();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String businessname = prefs.getString('business name') ?? "";
      String selectdomain = prefs.getString('business_name') ?? "";

      print(businessname);
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Format the date according to your API URL format (assuming dd/MM/yy)
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
      print(formattedDate);
      final fetch =
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$selectdomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=shopname_S&f2_op=eq&f2_value=$businessname&f3_field=status_S&f3_op=eq&f3_value=true';
      final response = await http.get(Uri.parse(fetch));
      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        salonData.clear();
        // Parse the JSON response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        // Check if the response data is in the expected format
        if (responseBody.containsKey('message') &&
            responseBody['message'] == 'Successfully Searched' &&
            responseBody.containsKey('source')) {
          List<dynamic> sources = responseBody['source'];
          // Check if there are entries for the specified shopname and today's date
          if (sources.isNotEmpty) {
            setState(() {
              // salonData.clear();
              // Update salonData with the parsed source data
              salonData = List<Map<String, dynamic>>.from(
                  sources.map((source) => jsonDecode(source)));
            });
          } else {
            // Print a message if no entries are found for the specified criteria
            print('No entries found for shopname and today\'s date.');
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

  Future<void> fetchData() async {
    try {
     // if (!mounted) return;
      // setState(() {
      //   salonData.clear();
      // });
      //salonData.clear();
    
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String businessname = prefs.getString('business name') ?? "";
      String userId = prefs.getString('userId') ?? "";
       String domain = prefs.getString('domain') ?? "";
        String subdomain = prefs.getString('subdomain') ?? "";

      print(businessname);
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Format the date according to your API URL format (assuming dd/MM/yy)
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
      print(formattedDate);
      final fetch =
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$domain&subdomain=$subdomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=adminId_S&f2_op=eq&f2_value=$userId&f3_field=appointment_S&f3_op=ne&f3_value=completed';
      //'https://broadcastmessage.mannit.co/mannit/eSearch?domain=Appointment&subdomain=$selectdomain&filtercount=4&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=shopname_S&f2_op=eq&f2_value=$businessname&f3_field=status_S&f3_op=eq&f3_value=true&f4_field=condition_S&f4_op=ne&f3_value=completed';
      final response = await http.get(Uri.parse(fetch));
      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        salonData.clear();
        // Parse the JSON response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        // Check if the response data is in the expected format
        if (responseBody.containsKey('message') &&
            responseBody['message'] == 'Successfully Searched' &&
            responseBody.containsKey('source')) {
          List<dynamic> sources = responseBody['source'];
          // Check if there are entries for the specified shopname and today's date
          if (sources.isNotEmpty) {
            setState(() {
              // salonData.clear();
              // Update salonData with the parsed source data
              salonData = List<Map<String, dynamic>>.from(
                  sources.map((source) => jsonDecode(source)));
            });
          } else {
            // Print a message if no entries are found for the specified criteria
            print('No entries found for shopname and today\'s date.');
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

  Future<void> Update() async {
    try {
      String? deviceToken = await notificationServices.getDeviceToken();
      print("updating........................");
      //final SharedPreferences prefs = await SharedPreferences.getInstance();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? profileOid = prefs.getString('profileOid');
      print("profile oid:$profileOid");
      print(userId);
      print(profileOid);
      final response = await http.put(
        Uri.parse(
            "https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$userId&resourceId=$profileOid"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "DeviceToken": deviceToken,
        }),
      );

      if (response.statusCode == 200) {
        print(' updated successfully');
        print(response.body);
      } else {
        print('Failed to update . Status code: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error updating: $e');
    }
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


  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to turn on the live location ?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Customize the button color
                    textStyle: TextStyle(
                        color: Colors.white), // Customize the text color
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Perform the action (turn on the toggle) here
                    setState(() {
                      _switchValue = true;
                    });
                    liveLocationUpdate(true);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Customize the button color
                    textStyle: TextStyle(
                        color: Colors.white), // Customize the text color
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutconform(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!!'),
          content:
              Text('Are you sure you want to turn off the live location ?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Customize the button color
                    textStyle: TextStyle(
                        color: Colors.white), // Customize the text color
                  ),
                ),
                SizedBox(width: 6),
                FittedBox(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Perform the action (turn on the toggle) here

                      Navigator.of(context).pop();
                      await logout();
                      await updatelogAPI();
                    },
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Customize the button color
                      textStyle: TextStyle(
                          color: Colors.white), // Customize the text color
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

  Future<void> updatelogAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("offline........................");
    String? profileOid = prefs.getString('profileOid');
    print("profile oid:$profileOid");
    print(userId);
    print(profileOid);
    final apiUrl = Uri.parse(
        "https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$userId&resourceId=$profileOid");

    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({"Live": "false"}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        print(response.body);
        print('API updated successfully');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Commonscreen(),
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

   Timer?timer;
  void startTimer() {
    const duration = Duration(seconds: 30); // Adjusted to minutes for clarity
    timer = Timer.periodic(duration, (Timer t) {
      print("timmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmming");
      fetchData();
    });
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

  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    fetchProfileData();
    // fetchData();
    fetchData();
    Update();
    startTimer();

    final DateTime now = DateTime.now();
    final DateTime notificationTime =
        DateTime(now.year, now.month, now.day, 15, 30);
    if (now.hour < 15 || (now.hour == 15 && now.minute < 30)) {
      final Duration duration = notificationTime.difference(now);
      Timer(duration, () {
        ShopNotification();
        sendNotificationToUser(
            "Please be reminded that the shop will be closing today at 9'O Clock. Kindly ensure all necessary preparations are made to close the shop in an orderly manner. Thank you for your cooperation.");
      });
    }

    // Get user details from shared preferences
    Future<void> _initializeSession() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        name = prefs.getString('name');
        mobileno = prefs.getString('mobileno');
        bussinessname = prefs.getString('business name');
        shopadress = prefs.getString('shop address');
        aboutbussines = prefs.getString('about business');
        profileOid = prefs.getString('profileOid');
        business_name = prefs.getString('business_name');
        gender = prefs.getString('gender');
      });
    }

    _initializeLiveLocation();
    notificationServices.requestNotificationPermisions();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isRefreshToken();
    notificationServices.getDeviceToken().then((value) {
      print(value);
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(gender);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: providerdata == null
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                backgroundColor: business_name == "Clinic"
                    ? Colors.blue
                    : business_name == "Pets"
                        ? PetsColor
                        : Colors.black,
                title: Text(
                  shop_name ?? "",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(),
                            ));
                      },
                      icon: Icon(Icons.edit_sharp)),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminReport(
                                busname: business_name ?? "",
                               // category: category ?? '',
                              ),
                            ));
                      },
                      icon: const Icon(
                        Icons.history,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {
                        _logoutconform(context);
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      )),
                ],
              ),
        body: providerdata == null
            ? const Center(child: CircularProgressIndicator())
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
                            color: business_name == "Clinic"
                                ? Colors.blue
                                : business_name == "Pets"
                                    ? Color(0xFFA91D3A)
                                    : Colors.black,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.only(left: 0)),
                          business_name == "Clinic"
                              ? CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset(
                                    "assets/hos.png",
                                    // width: MediaQuery.of(context).size.width *
                                    //     0.35,
                                    // height: MediaQuery.of(context).size.height *
                                    //     0.17,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : business_name == "Pets"
                                  ? ClipOval(
                                      child: Image.asset(
                                        "assets/dog.png",
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CircleAvatar(
                                      maxRadius: 40,
                                      backgroundColor: Colors.transparent,
                                      child: gender == "Male"
                                          ? Image.asset(
                                              "assets/mensaloon.jpg",
                                            )
                                          : gender == "Female"
                                              ? Image.asset(
                                                  "assets/femalesaloon.jpg",
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.32,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.20,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  "assets/unisaloon.jpg",
                                                )),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    business_name == "Saloon"
                                        ? SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(
                                            height: 10,
                                          ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: business_name == "Clinic"
                                              ? Colors.blue
                                              : business_name == "saloon"
                                                  ? Colors.black
                                                  : business_name == "Pets"
                                                      ? Colors
                                                          .orangeAccent.shade400
                                                      : Colors.black,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ),
                                        business_name == "Saloon"
                                            ? SizedBox(
                                                width: 5,
                                              )
                                            : business_name == "Pets"
                                                ? SizedBox(
                                                    width: 5,
                                                  )
                                                : SizedBox(),
                                        business_name == "Clinic"
                                            ? Text(
                                                " Dr.",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                ),
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.41,
                                          child: Text(
                                            providerdata!['name'] ?? "",
                                            style: business_name == "Clinic"
                                                ? TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  )
                                                : business_name == "Pets"
                                                    ? TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFFA91D3A),
                                                      )
                                                    : TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFFA91D3A),
                                                      ),
                                          ),
                                        ),
                                        Text(
                                          providerdata!['feedback'] ?? "0.0",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: business_name == "Clinic"
                                              ? Colors.blue
                                              : business_name == "saloon"
                                                  ? Colors.black
                                                  : business_name == "Pets"
                                                      ? Colors
                                                          .orangeAccent.shade400
                                                      : Colors.black,
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.48,
                                          child: Text(
                                            providerdata!['shop address'] ?? "",
                                            style: business_name == "Clinic"
                                                ? TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.black,
                                                  )
                                                : business_name == "Pets"
                                                    ? TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFFA91D3A),
                                                      )
                                                    : TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFFA91D3A),
                                                      ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 0,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor:
                                                business_name == "Clinic"
                                                    ? Colors.blue
                                                    : business_name == "saloon"
                                                        ? Colors.black
                                                        : business_name == "Pets"
                                                            ? Colors
                                                                .orangeAccent
                                                                .shade400
                                                            : Colors.black,
                                            child: Icon(
                                              Icons.call,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text("  "),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.286,
                                            child: Text(
                                              providerdata!['mobileno'] ?? "",
                                              style: business_name == "Clinic"
                                                  ? TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                    )
                                                  : business_name == "Pets"
                                                      ? TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                          color:
                                                              Color(0xFFA91D3A),
                                                        )
                                                      : TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                          color:
                                                              Color(0xFFA91D3A),
                                                        ),
                                            ),
                                          ),
                                          Text(_switchValue ? "LIVE" : "REST",
                                              style: TextStyle(
                                                  color: _switchValue
                                                      ? Colors.green
                                                      : Colors.red)),
                                          SizedBox(width: 1),
                                          Transform.scale(
                                            scale: 0.8,
                                            child: CupertinoSwitch(
                                              value: _switchValue,
                                              trackColor: Colors.red,
                                              activeColor: Colors.green,
                                              onChanged: (value) {
                                                if (value) {
                                                  // Show confirmation dialog before turning on the toggle
                                                  _showConfirmationDialog(
                                                      context);
                                                } else {
                                                  // Admin turned off the toggle directly
                                                  liveLocationUpdate(value);
                                                  setState(() {
                                                    _switchValue = value;
                                                  });
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                      //  await RefreshData();
                        await fetchData();
                      await fetchProfileData();
                     
                      },
                      icon: Icon(
                        Icons.refresh_outlined,
                        size: 24,
                        color: Colors.black,
                      )),
                  Text(
                    "Refresh",
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Expanded(
                    child: salonData.isEmpty
                        ? Center(
                            child: Text(
                              'No Appointments available',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                // color: category == "Clinic"
                                //     ? Colors.grey.shade800
                                //     : Color(0xFFA91D3A),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: salonData.length,
                            itemBuilder: (context, index) {
                                if (index >= salonData.length) {
                              return SizedBox.shrink(); // Safeguard against invalid index access
                            }
                              final salon = salonData[index];
                              final serialNumber = index + 1;
                              void onCreatedCallback() {
                                print(
                                    'resouceId: ${salon.containsKey('_id') ? salon['_id']['\$oid'].toString() : '--'}');
                                print(
                                    'userId: ${salon.containsKey('userId') ? salon['userId']['\$oid'].toString() : '--'}');
                              }

                              return SaloonAppoint(
                                Time: salon['currentTime'] ?? '--',
                                num: '$serialNumber',
                                name: salon['name'] ?? '',
                                condition: salon['condition'] ?? '',
                                Date: salon['currentDate'] ?? '--',
                                //Time:
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
                                index: index,
                                DeviceToken: salon["DeviceToken"] ?? "",
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

class SaloonAppoint extends StatefulWidget {
  final String num;
  final String Time;
  final String name;
  final String condition;
  final String Date;
  final int index;
  final VoidCallback oncall;
  final VoidCallback? onCreated;
  final bool onpressdelete;
  final bool toogle;
  final String resouceId;
  final String DeviceToken;
  final String userId;
  final List<Map<String, dynamic>> salonData;
  const SaloonAppoint({
    Key? key,
    required this.num,
    required this.onpressdelete,
    required this.name,
    required this.condition,
    required this.Date,
    required this.toogle,
    required this.index,
    required this.salonData,
    required this.userId,
    required this.resouceId,
    this.onCreated,
    required this.oncall,
    required this.DeviceToken,
    required this.Time,
  }) : super(key: key);

  @override
  State<SaloonAppoint> createState() => _SaloonAppointState();
}

class _SaloonAppointState extends State<SaloonAppoint> {
  void fetchData() async {
    try {
      salonData.clear();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String businessname = prefs.getString('business name') ?? "";
      String selectdomain = prefs.getString('category') ?? "";
      print("hiiiiiiiiiiiiiii");
      print(businessname);
      // Get the current date
      DateTime currentDate = DateTime.now();
      // Format the date according to your API URL format (assuming dd/MM/yy)
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
      final fetch =
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$selectdomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=shopname_S&f2_op=eq&f2_value=$businessname&f3_field=status_S&f3_op=eq&f3_value=true';
      final response = await http.get(Uri.parse(fetch));
      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        salonData.clear();
        // Parse the JSON response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        // Check if the response data is in the expected format
        if (responseBody.containsKey('message') &&
            responseBody['message'] == 'Successfully Searched' &&
            responseBody.containsKey('source')) {
          List<dynamic> sources = responseBody['source'];
          // Check if there are entries for the specified shopname and today's date
          if (sources.isNotEmpty) {
            setState(() {
              // Update salonData with the parsed source data
              salonData = List<Map<String, dynamic>>.from(
                  sources.map((source) => jsonDecode(source)));
            });
          } else {
            // Print a message if no entries are found for the specified criteria
            print('No entries found for shopname and today\'s date.');
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
  String? userId;
  String? Domain;
  String? SubDomain;
  String? mobileno;
  String? name;
  String? bussinessname;
  String? shopadress;
  String? proname;
  String? resouceId;
  String? aboutbussines;
  String? profileOid;
  String? oid;
  String? DeviceToken;
  String? businessname;
  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      final response = await http.get(
        Uri.parse(profileRead_url(userId, Domain, SubDomain)),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("profile data is :${response.body}");
        if (data.containsKey('source') && data['source'] is List) {
          var sourceList = data['source'] as List;

          // Assuming you only need the first profile
          if (sourceList.isNotEmpty) {
            var firstProfileData = jsonDecode(sourceList.first);
            profileOid = firstProfileData['_id']['\$oid'];
            mobileno = firstProfileData['mobileno'];
            name = firstProfileData['name'];
            bussinessname = firstProfileData['business name'];
            shopadress = firstProfileData['shop address'];
            aboutbussines =
                firstProfileData['about business'] ?? 'Default Name';
            resouceId = firstProfileData['userId']['\$oid'];
            DeviceToken = firstProfileData['DeviceToken'];
            businessname = firstProfileData['business name'];

            // Add more variables as needed

            // Print or use the variables as needed
            print('User ID: $userId');
            print(DeviceToken);
            print(businessname);
            print('Mobile Number: $mobileno');
            print('Profile URL: $aboutbussines');
            print('Name: $bussinessname');
            print('Category: $profileOid');

            // Print or use more variables as needed'
            // prefs.setString('clientRole', clientRole ?? 'defaultRole');
            prefs.setString('business name', bussinessname ?? "");

            print(bussinessname);
            print(profileOid);
         
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
 
  dialogBoxtoogle(BuildContext context) {
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
                  Icons.warning,
                  size: 60.0,
                  color: Colors.red,
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
                  "Are you sure you want to cancel appointment for ${widget.name}?",
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
                      
                        Navigator.of(context).pop();
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
                        _cancelAppointment();
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
  }

  Compltedbox(BuildContext context) {
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
                  Icons.check_circle_outline_outlined,
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
                  "Are you sure you want to Complete ?",
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
                        Navigator.of(context).pop();
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
  }

  dialogBox(BuildContext context) {
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
                  Icons.add_task_rounded,
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
                  "Are you sure you want to start Process?",
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
                        //updateAPIprocess();
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
  }

  Future<void> _cancelAppointment() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Domain = prefs.getString('domain');
      final SubDomain = prefs.getString('subdomain');
      String selectdomain = prefs.getString('category') ?? "";
      print('userId:${widget.userId}');
      print('resouceId: ${widget.resouceId}');

      final deleteUrl =
          'https://broadcastmessage.mannit.co/mannit/eDelete?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}';
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        print(response);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SalonBookscreen(),
            ));
        setState(() async {
          await sendNotification3();
          widget.salonData.removeWhere(
            (salon) =>
                salon['_id']['\$oid'] == widget.resouceId &&
                salon['userId']['\$oid'] == widget.userId,
          );
        });

        // Remove the deleted appointment from the list

        print('Appointment canceled successfully');

        snackbar_green(context, "Appointment canceled successfully");
      } else {
        print(
            'Failed to cancel appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error canceling appointment: $e');
    }
  }

  void confirmupdateAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('domain');
    final SubDomain = prefs.getString('subdomain');
   // String selectdomain = prefs.getString('category') ?? "";
    print('userId:${widget.userId}');
    print('resouceId: ${widget.resouceId}');

    final apiUrl = Uri.parse(
        'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          "appointment": "waiting",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // sendNotification1();
          print(response.body);
        print('confirm API updated successfully');
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const SalonBookscreen(),
        //     ));
        // You can handle the response here if needed
      //   _saveConfirmationState(true,false);
          // setState(() {
          //                                   iswaiting = true;
          //                                 });
      } else {
        print('Failed to update API. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error updating API: $error');
      // Handle the error accordingly
    }
  }
 void waitingupdateAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('domain');
    final SubDomain = prefs.getString('subdomain');
   // String selectdomain = prefs.getString('category') ?? "";
    print('userId:${widget.userId}');
    print('resouceId: ${widget.resouceId}');

    final apiUrl = Uri.parse(
        'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          "appointment": "process",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // sendNotification1();
        print(response.body);
        print('waiting API updated successfully');
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const SalonBookscreen(),
        //     ));
        // You can handle the response here if needed
        //  _saveConfirmationState(true,false);
        //   setState(() {
        //                                     iswaiting = true;
        //                                   });
      } else {
        print('Failed to update API. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error updating API: $error');
      // Handle the error accordingly
    }
  }
   void completeupdateAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('domain');
    final SubDomain = prefs.getString('subdomain');
   // String selectdomain = prefs.getString('category') ?? "";
    print('userId:${widget.userId}');
    print('resouceId: ${widget.resouceId}');

    final apiUrl = Uri.parse(
        'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          "appointment": "completed",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // sendNotification1();
         sendNotification1();
           print(response.body);
        print('completed API updated successfully');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SalonBookscreen(),
            ));
        // You can handle the response here if needed
        //  _saveConfirmationState(true,false);
        //   setState(() {
        //                                     iswaiting = true;
        //                                   });
      } else {
        print('Failed to update API. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (error) {
      print('Error updating API: $error');
      // Handle the error accordingly
    }
  }
  void updateAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Domain = prefs.getString('Domain');
    final SubDomain = prefs.getString('SubDomain');
    String selectdomain = prefs.getString('category') ?? "";
    print('userId:${widget.userId}');
    print('resouceId: ${widget.resouceId}');

    final apiUrl = Uri.parse(
        'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$selectdomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
    try {
      // Sending a GET request
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          "status": "false",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        sendNotification1();
        print(response);
        print('API updated successfully');
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const SalonBookscreen(),
        //     ));
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

  Future<void> sendNotification1() async {
    // Your FCM server key
    print(widget.DeviceToken);
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(widget.DeviceToken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': "Thank you",
        'body': "Please visit again!"
      },
      // 'to':
      //     "frt-Usw7T3mOo6L2hx9jVg:APA91bGEorZU1CUCKmz4EVf1QllCigixOXFBNc2GUw-cl-OfOlc60THxb7dbOi4AWLVA74s5y6jRAXTUTorPzRUGP3ahp7Nvy3LSsF1Ddu8PL-tSUy1-aJ2Hwv3U7zvGxcBhhmHuznEy"
      'to': widget.DeviceToken,
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

  Future<void> sendNotification3() async {
    // Your FCM server key
    print(widget.DeviceToken);
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(widget.DeviceToken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': "Appointment canceled",
        'body': "Please visit again..........."
      },
      // 'to':
      //     "frt-Usw7T3mOo6L2hx9jVg:APA91bGEorZU1CUCKmz4EVf1QllCigixOXFBNc2GUw-cl-OfOlc60THxb7dbOi4AWLVA74s5y6jRAXTUTorPzRUGP3ahp7Nvy3LSsF1Ddu8PL-tSUy1-aJ2Hwv3U7zvGxcBhhmHuznEy"
      'to': widget.DeviceToken,
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

  Future<void> sendNotification() async {
    // Your FCM server key
    print(widget.DeviceToken);
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(widget.DeviceToken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': "Appointment Booked",
        'body': "Next you..........."
      },
      // 'to':
      //     "frt-Usw7T3mOo6L2hx9jVg:APA91bGEorZU1CUCKmz4EVf1QllCigixOXFBNc2GUw-cl-OfOlc60THxb7dbOi4AWLVA74s5y6jRAXTUTorPzRUGP3ahp7Nvy3LSsF1Ddu8PL-tSUy1-aJ2Hwv3U7zvGxcBhhmHuznEy"
      'to': widget.DeviceToken,
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

  Future<void> _toggleSwitch(bool value) async {
    setState(() {
      _isProcessing = true;
    });

    // Call update API if switch is turned on
    if (value) {
      print('userId:${widget.userId}');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String Domain = prefs.getString('domain') ?? "";
       String SubDomain = prefs.getString('subdomain') ?? "";
      print('resouceId: ${widget.resouceId}');
      final url = Uri.parse(
          'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}');
      final response = await http.put(
        url,
        body: jsonEncode({
          "condition": "completed",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        updateAPI();
  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SalonBookscreen(),
            ));
        print('Update successful');
        setState(() {
          _switchValue = value;
        });
      } else {
        // Update failed

        print(response.body);
        print('Update failed');
      }
    }
  }

 bool _closebuttonPressed = false;


bool iswaiting = false;
bool _isConfirmed = false;

bool _notificationSent = false;
  Future<void> sendNotificationforuser() async {
    // Check if notification has already been sent
    if (_notificationSent) {
      print('Notification already sent, skipping...');
      return;
    }

    // Your FCM server key
    print(widget.DeviceToken);
    String serverKey =
        'AAAAN3mVF7s:APA91bGTJoeNSZiJIonKS1SSOh1akIFgiZYB86OL_Gf6-oHCapj_5Cn5Be1ydwddhPb5SkiMcg0e2PFmCldPAoS9Zn3kUOGeOhkUNrbRnIrKVz4MegOjj7DG2gZEzZ61wg9DmCKVnNtG';

    // Firebase FCM endpoint
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Headers for authorization and content type
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    print(widget.DeviceToken);
    // Payload for the notification
    final Map<String, dynamic> notificationData = {
      'notification': {
        'title': "Appointment Booked",
        'body': "Next you..........."
      },
      'to': widget.DeviceToken,
    };

    // Send the notification via HTTP POST request
    final http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
      // Set the flag to true after sending the notification
      _notificationSent = true;
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
    }
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


  @override
  void initState() {
    _loadConfirmationState();
    fetchProfileData();
    super.initState();
    // Get user details from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        userId = prefs.getString('userId');
        Domain = prefs.getString('Domain');
        SubDomain = prefs.getString('SubDomain');
        mobileno = prefs.getString('mobileno');
        name = prefs.getString('name');
        bussinessname = prefs.getString('business name');
        shopadress = prefs.getString('shop address');
        aboutbussines = prefs.getString('about business');
        resouceId = prefs.getString('profileOid');
        DeviceToken = prefs.getString('DeviceToken');
        businessname = prefs.getString('businessname');
      });
    });
  }

  Widget build(BuildContext context) {
    _switchValue = widget.condition == "completed";
    Color containerColor = Colors.red;
    if (widget.condition == "process") {
      containerColor = Colors.yellow;

      //  containerColor = const Color.fromARGB(255, 12, 227, 23);
    } else if (widget.index == 0) {
      sendNotificationforuser();

      // containerColor = const Color.fromARGB(255, 12, 227, 23);
    } else {
      containerColor = Colors.redAccent;
    }
    // if (widget.onCreated != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     widget.onCreated!();
    //   });
    // }

    return Padding(
      padding: const EdgeInsets.only(
     left: 10, right: 10, bottom: 10
      ),
      child: Container(
        height: 140,
        width: 380,
        decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                  color: businessname == "Clinic" ? Colors.blue : Colors.black,
                  width: 7)),
          color: businessname == "Clinic" ? Colors.blue : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            
             const SizedBox(height: 20),
          const SizedBox(width: 5),
            Row(
              children: [
                   Padding(padding: EdgeInsets.only(left:10)),
           
                Icon(
                  Icons.person_pin,size: 30,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.61,
                  child: Text(
                  widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      widget.Date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                     Text(
                  widget.Time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                  ],
                ),
                 
              ],
            ),
           
            // SizedBox(
            //   height: 10,
            // ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  Padding(padding: EdgeInsets.only(left:10)), 
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () {
                          dialogBoxtoogle(context);
                        },
                        icon: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                    Text(
                      "Cancel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  ],
                ),
            SizedBox(width: 10,),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: widget.oncall,
                        icon: const Icon(Icons.phone_in_talk_outlined,
                            color: Colors.green),
                      ),
                    ),
                    
                    Text(
                      "Call",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                      SizedBox(width: 160,),
            
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
                                          "Are you sure you want to complete the process for ${widget.name}?",
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
                                                completeupdateAPI();
                                                setState(() {
                                                  _closebuttonPressed = true; // Set the flag to true
                                                });
                                                //closedbooking();
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
                            Icons.cut_outlined,
                            color: Colors.blue[900],
                          ),
                        ),
                        Text(
                          'Process',
                          style: TextStyle(
                            color: Colors.white,
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
                                    "Are you sure you want to start the procees for ${widget.name}?",
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
                                          _saveConfirmationState(true);
                                          waitingupdateAPI();
                                          setState(() {
                                            _isConfirmed = true;
                                          });
                                        
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
                          child:
                            Image.asset("assets/waiting.png",color: Colors.black,height: 25,),
                        ),
                        Text(
                          'Waiting',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),   
              ],
            )
          ],
        ),
      ),
    );
  }
}