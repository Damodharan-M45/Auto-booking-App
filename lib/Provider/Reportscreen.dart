// ignore_for_file: avoid_print, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/Push_notification.dart';
import 'package:appointments/autouser/userreport.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:appointments/saloonhistory.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {

  const ReportScreen({super.key, });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? proname;

  List<Map<String, dynamic>> dataList = [];
  String originalProname = '';
  bool _disposed = false;
  List<Map<String, dynamic>> salonData = [];
  Future<String?> _fetchDataFromAPI() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SubDomain = prefs.getString('SubDomain') ?? '';
      final Domain = prefs.getString('domain') ?? '';
        final userId = prefs.getString('userId') ?? '';
      print("0000000000000000000000000000000000000000000000000000");
      List<Map<String, dynamic>> currentSalonAppointments = salonData
          .where((appointment) => appointment['shopname'] == proname)
          .toList();
      // Store the original proname value
      //String? originalProname = widget.proname;
      print(originalProname);
      final response = await http.get(Uri.parse(
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$userId&filtercount=1&f1_field=business name_S&f1_op=eq&f1_value=$SubDomain'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];
        List<Map<String, dynamic>> tempDataList = [];

        for (final dynamic source in sources) {
          final Map<String, dynamic> prodata = jsonDecode(source);
          // Check if the data contains necessary fields
          if (prodata.containsKey('location') &&
              prodata.containsKey('business name') &&
              prodata.containsKey('shop address') &&
              prodata.containsKey('about business') &&
              prodata.containsKey('mobileno') &&
              prodata.containsKey('name') &&
              prodata.containsKey('business type') &&
              prodata.containsKey('_id') &&
              prodata.containsKey('category') &&
              prodata.containsKey('userId')) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('objectId', prodata['_id']['\$oid']);
            prefs.setString('userId', prodata['userId']['\$oid']);
            tempDataList.add({
              'gender': prodata['gender'],
              'latitude': prodata['location']?['lat'],
              'longitude': prodata['location']?['lon'],
              'businessName': prodata['business name'],
              'address': prodata['shop address'],
              'aboutBusiness': prodata['about business'],
              'id': prodata['_id']['\$oid'], // Accessing ObjectId as a string
              'mobileNo': prodata['mobileno'],
              'name': prodata['name'],
              'businessType': prodata['business type'],
              'domain': prodata['domain'],
              'subdomain': prodata['subdomain'],
              'shopname': prodata['shopname'],
              'userId': prodata['userId']
                  ['\$oid'], // Accessing userId as a string
            });
          }
        }
        print("business name: ${tempDataList.map((e) => e['business name']).toList()}");
        print("dataaaaaaaaaaaaaaaaaaaaaaaaaaa:$tempDataList");

        for (var data in tempDataList) {
          print("business name: ${data['business name']}");
        }

        // Store the first category value in the cat variable
        String? business_name =
            tempDataList.isNotEmpty ? tempDataList.first['business name'] : null;
        print("business name: $business_name");

        setState(() {
          dataList = tempDataList;
        });
        return business_name;
      } else {
        throw Exception('${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userName = prefs.getString('userName');
    final String? phoneNumber = prefs.getString('phoneNumber');
    final String? objectId = prefs.getString('objectId');
    final String? shop_name = prefs.getString('shop_name');
    final seledomain = prefs.getString('category') ?? '';
    print(shop_name);
    return {
      'User Name': userName ?? 'N/A',
      'Phone Number': phoneNumber ?? 'N/A',
      'Object ID': objectId ?? 'N/A',
      'shopname': shop_name ?? "N/A"
    };
  }

  List<ReportContainer> reportContainers = [];
  Future<void> fetchReportData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? USERId = prefs.getString('userId');
      final SubDomain = prefs.getString('SubDomain') ?? '';
       final Domain = prefs.getString('domain') ?? '';
      final gender = prefs.getString('gender') ?? '';
      print("gggggggggggggggggggggggggggggggggg:$USERId");
      // List<Map<String, dynamic>> currentSalonAppointments = salonData
      //     .where((appointment) => appointment['shopname'] == proname)
      //     .toList();
      // Store the original proname value
      String logoAssetPath = gender == 'Male'
          ? "assets/mensaloon.jpg"
          : gender == 'Female'
              ? "assets/femalesaloon.jpg"
              : "assets/unisaloon.jpg";
      
      print(Domain);
      print(SubDomain);
      print("jiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
       DateTime currentDate = DateTime.now();
      String formattedDate =
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
          print("current date:$formattedDate");
      String url =
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$USERId&filtercount=2&f1_field=appointment_S&f1_op=ne&f1_value=completed&f2_field=currentDate_S&f2_op=ne&f2_value=$formattedDate';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];
        setState(() {
          reportContainers.clear();
        });

        print(responseBody);
        for (final dynamic source in sources) {
          final Map<String, dynamic> itemData = jsonDecode(source);
          final String name = itemData['shopname'] ?? 'N/A';
          final String date = itemData['currentDate'] ?? 'N/A';
          final String time = itemData['currentTime'] ?? 'N/A';
          final String condition = itemData['condition'] ?? 'N/A';
          final String business = itemData['business name'] ?? 'N/A';
          final String resouceId = itemData['_id']['\$oid'] ?? '';
          final String userId = itemData['userId']['\$oid'] ?? '';
          final String mobileno = itemData['mobileno'] ?? 'N/A';
          final String gender = itemData['gender'] ?? 'N/A';

          reportContainers.add(
            ReportContainer(
              mobileno: mobileno,
              name: name,
              Date: date,
              time: time,
              business: business,
              image: business == "Clinic"
                  ? "assets/hos.png"
                  : business == "Pets"
                      ? "assets/dog.png"
                      : business == "Saloon"
                          ? logoAssetPath
                          : "assets/hos.png",
              index: 100,
              userId: userId,
              resouceId: resouceId,
              condition: condition,
              reportContainers: reportContainers,
              gender: gender,
            ),
          );
        }
      } else {
        throw Exception('Failed to load report data (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching report data: $e');
    }
  }

  String? userId;
  String? Domain;
  String? SubDomain;
  String? mobileno;
  String? name;
  String? bussinessname;
  String? shopadress;
  String? resouceId;
  String? aboutbussines;
  String? profileOid;
  String? oid;
  String? DeviceToken;
  String? category;
  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('UseruserId');
      Domain = prefs.getString('Domain');
      SubDomain = prefs.getString('SubDomain');
      final seledomain = prefs.getString('category') ?? '';
      final response = await http.get(
        Uri.parse(profileRead_url(userId, Domain, seledomain)),
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
            bussinessname = firstProfileData['shopname'];
            shopadress = firstProfileData['shop address'];
            aboutbussines =
                firstProfileData['about business'] ?? 'Default Name';
            resouceId = firstProfileData['userId']['\$oid'];
            DeviceToken = firstProfileData['DeviceToken'];
            category = firstProfileData['category'];

            // prefs.setString('clientRole', clientRole ?? 'defaultRole');
            prefs.setString('business name', bussinessname ?? "");

            // print(bussinessname);
            // print(profileOid);

            setState(() {});
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

  void _handleNotification(String? title, String? body) {
    if (title == "Thank you" && body == "Please visit again...........") {
      if (!_dialogShown) {
        _showAlertDialog(context, title, body);
        _dialogShown = true;
      }
    } else {
      if (mounted) {
        null;
      }
    }
  }

  void _showAlertDialog(
      BuildContext context, String? title, String? body) async {
    void updateAPI(double rating) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String selectdomain = prefs.getString('category') ?? "";
      final domain = prefs.getString('Domain') ?? '';
      // final subDomain = prefs.getString('SubDomain') ?? '';
      // String upobjectId = prefs.getString('objectId') ?? '';
      String upuserId = prefs.getString('userId') ?? '';
      String? Id = prefs.getString('id') ?? "";
      print(upuserId);
      print(Id);
      print("eeeeeeeeeee:$selectdomain");
      // print(upobjectId);
      final apiUrl = Uri.parse(
          'https://broadcastmessage.mannit.co/mannit/eUpdate?domain=$domain&subdomain=$selectdomain&userId=$upuserId&resourceId=$Id');

      try {
        // Sending a PUT request
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
                    size: 13,
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
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getSessionValues(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? USERId = prefs.getString('userId');
    bool? isLogin = prefs.getBool('login');
    String? domain = prefs.getString('domain');
    String? subDomain = prefs.getString('SubDomain');

    print("User ID: $USERId");
    print("Is Login: $isLogin");
    print("Domain: $domain");
    print("SubDomain: $subDomain");
  }

  late Timer timer;
  bool _dialogShown = false;
  NotificationServices notificationServices = NotificationServices();
  late StreamSubscription<RemoteMessage> _messageStreamSubscription;
  String? cat;
  @override
  void initState() {
    getSessionValues(context);
    // _fetchDataFromAPI();
    // _fetchDataFromAPI().then((value) {
    //   setState(() {
    //     cat = value;
    //   });
    // });
    const duration = Duration(seconds: 30);
    timer = Timer.periodic(duration, (Timer t) {
      print("timmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmming");
      fetchReportData();
    });
    _getData();
    fetchReportData();
    fetchProfileData();
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
      }
    });
    notificationServices.requestNotificationPermisions();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isRefreshToken();
    notificationServices.getDeviceToken().then((value) {
      print(value);
    });
    // Request notification permissions
    // Initialize firebaseMessaging
    final firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _handleNotification(
            message.notification!.title, message.notification!.body);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations here
    _messageStreamSubscription
        .cancel(); // Assuming _messageStreamSubscription is a StreamSubscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        // backgroundColor: cat == "Clinic"
        //     ? Colors.blue
        //     : cat == "Pets"
        //         ? Color.fromARGB(255, 253, 200, 66)
        //         : Colors.black,
        title: const Text(
          "Report",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChooseAppointmentscreen()));
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Userhistory()));
              },
              icon: Icon(
                Icons.history,
                color: Colors.white,
              ))
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              IconButton(
                  onPressed: () {
                    fetchReportData();
                  },
                  icon: Icon(
                    Icons.refresh,
                    size: 30,
                  )),
              GestureDetector(
                child: Text("Refresh"),
                onTap: () {
                  fetchReportData();
                },
              ),
              SizedBox(
                height: 20,
              ),
              reportContainers.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: reportContainers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return reportContainers[index];
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                      'No Reports available',
                      style: TextStyle(
                        fontSize: 17,
                        color: cat == "Clinic"
                            ? Colors.blue
                            : cat == "Pets"
                                ? Colors.teal
                                : Colors.black,
                      ),
                    )),
            ],
          )),
    );
  }
}

class ReportContainer extends StatefulWidget {
  final String mobileno;
  final String name;
  final String Date;
  final String image;
  final int index;
  final List<ReportContainer> reportContainers;
  final String userId;
  final String resouceId;
  final String condition;
  final String time;
  final String business;
  final String gender;
  //final String condition;
  const ReportContainer({
    super.key,
    required this.name,
    required this.Date,
    required this.time,
    required this.image,
    required this.business,
    required this.index,
    required this.userId,
    required this.resouceId,
    required this.condition,
    required this.reportContainers,
    required this.mobileno,
    required this.gender,
  });

  @override
  State<ReportContainer> createState() => _ReportContainerState();
}

class _ReportContainerState extends State<ReportContainer> {
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
                  "Are you sure you want to cancel your appointment?",
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

  Future<void> _cancelAppointment() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Domain = prefs.getString('domain');
      final SubDomain = prefs.getString('SubDomain');
     // String selectdomain = prefs.getString('category') ?? "";
      print('userId:${widget.userId}');
      print('resouceId: ${widget.resouceId}');
      print(SubDomain);

      final deleteUrl =
          'https://broadcastmessage.mannit.co/mannit/eDelete?domain=$Domain&subdomain=$SubDomain&userId=${widget.userId}&resourceId=${widget.resouceId}';
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        print(response);
        // Remove the deleted appointment from the list
        setState(() {
          widget.reportContainers.removeWhere((item) =>
              item.userId == widget.userId &&
              item.resouceId == widget.resouceId);
        });

        print('Appointment canceled successfully');

        snackbar_green(context, "Appointment canceled successfully");
        setState(() {
          widget.reportContainers.removeWhere((item) =>
              item.userId == widget.userId &&
              item.resouceId == widget.resouceId);
        });
         Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>ReportScreen()));
      } else {
        print(
            'Failed to cancel appointment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error canceling appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color containerColor = Colors.grey;
    if (widget.condition == "completed") {
      containerColor = const Color.fromARGB(255, 12, 227, 23);
    } else if (widget.index == 0) {
      containerColor = Colors.yellow;
    } else {
      containerColor = Colors.red; // Assuming red for the "waiting" stage
    }

    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 23, bottom: 10),
      child: Container(
        height: 135,
        width: 390,
        decoration: BoxDecoration(
            color: widget.business == "Clinic"
                ? Colors.blue.shade300
                : widget.business == "Saloon"
                    ? Colors.black54
                    : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
             widget.gender=="Male"?   Image.asset(
                "assets/mensaloon.jpg",
                  height: 30,
                  width: 30,
                ): widget.gender=="Female"?  Image.asset(
                "assets/femalesaloon.jpg",
                  height: 30,
                  width: 30,
                ): Image.asset(
                "assets/unisaloon.jpg",
                  height: 30,
                  width: 30,
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Text(
                    widget.name,
                    style: TextStyle(
                        color: widget.business == "Clinic"
                            ? Colors.white
                            : widget.business == "Saloon"
                                ? Colors.white
                                : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.20,
                  child: Text(
                    widget.Date,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.business == "Clinic"
                            ? Colors.white
                            : widget.business == "Saloon"
                                ? Colors.white
                                : Colors.black,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text(
                widget.time,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 20),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  CircleAvatar(
                    //   radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                        onPressed: () {
                          _callNumber(widget.mobileno);
                        },
                        icon: Icon(Icons.phone_in_talk_outlined,
                            color: Colors.green)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Call",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                        onPressed: () {},
                        icon: widget.condition == "process"
                            ? Icon(Icons.cut_outlined, color: Colors.blue[900])
                            // ? Icon(Icons.directions_run_rounded,
                            //     color: Colors.blue[900])
                            : CircleAvatar(
                                backgroundColor: Colors.yellow,
                                child: Image.asset(
                                  "assets/waiting.png",
                                ),
                              )),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.condition,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (widget.condition != "process")
                Column(
                  children: [
                    CircleAvatar(
                      //   radius: 20,
                      backgroundColor: Colors.white,
                      child: IconButton(
                          onPressed: () {
                            dialogBox(context);
                          },
                          icon: Icon(Icons.cancel, color: Colors.red)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ])
          ],
        ),
      ),
    );
  }
}