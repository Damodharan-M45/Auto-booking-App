import 'dart:convert';

import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Userhistory extends StatefulWidget {
  const Userhistory({super.key});

  State<Userhistory> createState() => _UserhistoryState();
}

class _UserhistoryState extends State<Userhistory> {
  List<Map<String, dynamic>> dataList = [];
  bool isLoading = false;

  final TextEditingController _dateController = TextEditingController();
  String originalProname = '';

  List<Map<String, dynamic>> salonData = [];
  Future<String?> _fetchDataFromAPI() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SubDomain = prefs.getString('SubDomain') ?? '';
        final Domain = prefs.getString('domain') ?? '';
        final userId = prefs.getString('userId') ?? '';
      print("0000000000000000000000000000000000000000000000000000");

      print(originalProname);
      final response = await http.get(Uri.parse(
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$userId&filtercount=1&f1_field=condition_S&f1_op=eq&f1_value=completed'));
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
              prodata.containsKey('_id') &&
              prodata.containsKey('category') &&
              prodata.containsKey('userId')) {
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
              'category': prodata['category'],
              'userId': prodata['userId']
                  ['\$oid'], // Accessing userId as a string
            });
          }
        }
        // print("Categories: ${tempDataList.map((e) => e['category']).toList()}");
        // print("dataaaaaaaaaaaaaaaaaaaaaaaaaaa:$tempDataList");

        for (var data in tempDataList) {
          print("Category: ${data['category']}");
        }

        // Store the first category value in the cat variable
        String? cat =
            tempDataList.isNotEmpty ? tempDataList.first['category'] : null;
        // print("Category: $cat");

        setState(() {
          dataList = tempDataList;
        });
        return cat;
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

  List<Adminhistory> reportContainers = [];
  Future<void> fetchReportData() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? USERId = prefs.getString('userId');
      final SubDomain = prefs.getString('SubDomain') ?? '';
      final Domain = prefs.getString('domain') ?? '';
      print(":$USERId");

      String selectedDate = _dateController.text;
      print("Selected Date: $selectedDate");

      String logoAssetPath = "assets/mensaloon.jpg";

      String url = Uri.encodeFull(
          'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$USERId&filtercount=2&f1_field=condition_S&f1_op=eq&f1_value=completed&f2_field=currentDate_S&f2_op=eq&f2_value=$selectedDate');

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          final List<dynamic> sources = responseBody['source'];

          reportContainers.clear();

          for (final dynamic source in sources) {
            final Map<String, dynamic> itemData = jsonDecode(source);
            final String name = itemData['name'] ?? 'N/A';
            final String date = itemData['currentDate'] ?? 'N/A';
            final String time = itemData['currentTime'] ?? 'N/A';
            final String condition = itemData['condition'] ?? 'N/A';
            final String business = itemData['business'] ?? 'N/A';
            final String resouceId = itemData['_id']['\$oid'] ?? '';
            final String userId = itemData['userId']['\$oid'] ?? '';

            setState(() {
              reportContainers.add(
                Adminhistory(
                  name: name,
                  Date: date,
                  time: time,
                  business: business,
                  image: business == "Clinic"
                      ? "assets/hos.jpg"
                      : business == "Pets"
                          ? "assets/dog.png"
                          : business == "Saloon"
                              ? "assets/mensaloon.jpg"
                              : logoAssetPath,
                  index: 8,
                  userId: userId,
                  resouceId: resouceId,
                  condition: condition,
                ),
              );
            });
          }

         
        } 
      

      if (reportContainers.isEmpty) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No data available'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
            bussinessname = firstProfileData['business name'];
            shopadress = firstProfileData['shop address'];
            aboutbussines =
                firstProfileData['about business'] ?? 'Default Name';
            resouceId = firstProfileData['userId']['\$oid'];
            DeviceToken = firstProfileData['DeviceToken'];
            category = firstProfileData['category'];
            // Add more variables as needed

            // Print or use the variables as needed
            print('User ID: $userId');
            print(DeviceToken);
            print(category);
            print('Mobile Number: $mobileno');
            print('Profile URL: $aboutbussines');
            print('Name: $bussinessname');
            print('Category: $profileOid');

            // Print or use more variables as needed'
            // prefs.setString('clientRole', clientRole ?? 'defaultRole');
            prefs.setString('business name', bussinessname ?? "");

            print(bussinessname);
            print(profileOid);

            setState(() {
              isLoading = false;
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

  Future<void> getSessionValues(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? USERId = prefs.getString('UseruserId');
    bool? isLogin = prefs.getBool('login');
    String? domain = prefs.getString('Domain');
    String? subDomain = prefs.getString('SubDomain');

    print("User ID: $USERId");
    print("Is Login: $isLogin");
    print("Domain: $domain");
    print("SubDomain: $subDomain");
  }

  @override
  void initState() {
    getSessionValues(context);
    _fetchDataFromAPI();
    _getData();
    fetchProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My history",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 7),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.40,
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () {
                    showDatePicker(
                      context: context,
                      builder:
                          //  widget.category == "Clinic"
                          //     ?
                          //     (context, child) {
                          //   return Theme(
                          //     data: ThemeData.light().copyWith(
                          //       colorScheme: ColorScheme.light(
                          //         primary: Colors.lightBlueAccent.shade400,
                          //         onPrimary: Colors.white,
                          //         surface: Colors.blue.shade100,
                          //         onSurface: Colors.black,
                          //       ),
                          //     ),
                          //     child: child!,
                          //   );
                          // },
                          // : widget.category == "Pets"
                          //     ? (context, child) {
                          //         return Theme(
                          //           data: ThemeData.light().copyWith(
                          //             colorScheme: ColorScheme.light(
                          //               primary: Color.fromARGB(
                          //                   255, 52, 62, 244),
                          //               onPrimary: Colors.white,
                          //               surface: PetsColor,
                          //               onSurface: Colors.black,
                          //             ),
                          //           ),
                          //           child: child!,
                          //         );
                          //       }
                          //:
                          (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                  surface:
                                      const Color.fromRGBO(255, 249, 196, 1),
                                  onSurface: Colors.black)),
                          child: child!,
                        );
                      },
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _dateController.text =
                              "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}";
                          fetchReportData();
                          //"${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                        });
                      }
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelText: "Date",
                    labelStyle: TextStyle(color: Colors.black),
                    focusColor: Colors.black,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      // borderRadius: BorderRadius.circular(20.0),
                    ),
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0),
                  ),
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ),
          reportContainers.length == 0
              ? SizedBox(height: 270)
              : SizedBox(
                  height: 20,
                ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          else
            reportContainers.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: reportContainers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return reportContainers[index];
                      },
                    ),
                  )
                // : Center( child: CircularProgressIndicator( color: Colors.black,))
                : Center(
                    child: Text(
                      'No Reports available',
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  ),
        ],
      ),
      // body: Padding(
      //   padding: const EdgeInsets.only(top: 40),
      //   child: reportContainers.isNotEmpty
      //       ? ListView.builder(
      //           itemCount: reportContainers.length,
      //           itemBuilder: (BuildContext context, int index) {
      //             return reportContainers[index];
      //           },
      //         )
      //       : Center(
      //           child: Text(
      //           'No Reports available',
      //           style: TextStyle(fontSize: 17, color: Colors.black),
      //         )),
      // ),
    );
  }
}

class Adminhistory extends StatefulWidget {
  final String name;
  final String Date;
  final String image;

  final String userId;
  final String resouceId;
  final int index;
  final String time;
  final String business;
  final String condition;
  const Adminhistory({
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
    //required this.condition
  });

  @override
  State<Adminhistory> createState() => _AdminhistoryState();
}

class _AdminhistoryState extends State<Adminhistory> {
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
      final Domain = prefs.getString('Domain');
      final SubDomain = prefs.getString('SubDomain');
      String selectdomain = prefs.getString('category') ?? "";
      print('userId:${widget.userId}');
      print('resouceId: ${widget.resouceId}');
      print(selectdomain);

      final deleteUrl =
          'https://broadcastmessage.mannit.co/mannit/eDelete?domain=$Domain&subdomain=$selectdomain&userId=${widget.userId}&resourceId=${widget.resouceId}';
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        print(response);

        // Remove the deleted appointment from the list

        print('Appointment canceled successfully');
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Appointment canceled successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // snackbar_green(
        //     context as BuildContext, "Appointment canceled successfully");
        setState(() {
          //  Adminhistory .removeWhere(
          //         (element) => element['_id']['\$oid'] == widget.resouceId);
        });
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
        height: 70,
        width: 380,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
                color: Colors.black,
                // color: widget.business == 'Clinic'
                //     ? Colors.blue
                //     : widget.business == 'Auto'
                //         ? Colors.yellow
                //         : Colors.black,
                width: 7),
            // right: BorderSide(color: Colors.black, width: 7)
          ),
          color: const Color.fromARGB(255, 229, 229, 229), // Use containerColor
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            const SizedBox(width: 5),
            Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 10)),
                //widget.business == 'Clinic'
                CircleAvatar(
                    maxRadius: 15,
                    backgroundColor: Colors.transparent,
                    child: Image.asset("assets/mensaloon.png")),
                // : widget.business == 'Saloon'
                //     ? CircleAvatar(
                //         maxRadius: 15,
                //         backgroundColor: Colors.transparent,
                //         child: Image.asset("assets/mens.png"))
                //     : widget.business == 'Auto'
                //         ? CircleAvatar(
                //             maxRadius: 15,
                //             backgroundColor: Colors.transparent,
                //             child: Image.asset("assets/autohd.png"))
                // : Icon(
                //     Icons.person,
                //     size: 30,
                //   ),
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.56,
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
                      widget.Date,
                      style: const TextStyle(
                        color: Colors.black,
                        //fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      widget.time,
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
          ],
        ),
      ),
    );
  }
}