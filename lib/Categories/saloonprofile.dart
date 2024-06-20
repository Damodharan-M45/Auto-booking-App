// ignore_for_file: unnecessary_string_interpolations, unused_local_variable, prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names, library_private_types_in_public_api, unused_import

import 'dart:async';
import 'dart:convert';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/Provider/Reportscreen.dart';
import 'package:appointments/Regesterscreen/Resgister.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:appointments/property/utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Salonprofile extends StatefulWidget {
  const Salonprofile({super.key, required String businessName, required String shopAddress, required String proname, required String aboutbussines});

  @override
  State<Salonprofile> createState() => _SalonprofileState();
}

class _SalonprofileState extends State<Salonprofile> {
  bool _disposed = false;
  // Function to update current date and time every second
  void _updateDateTime() {
    if (!_disposed) {
      setState(() {
        _currentDateTime = DateTime.now();
      });

      // Update every second if widget is still mounted
      Timer(const Duration(seconds: 1), _updateDateTime);
    }
  }

  TextEditingController name = TextEditingController();
  TextEditingController phoneno = TextEditingController();

  String? userId;
  String? mobileno;
  String? proname;
  String? bussinessname;
  String? Domain;
  String? SubDomain;
  String? shopadress;
  String? aboutbussines;
  String? profileOid;
  String? address;
  Map<String, dynamic>? providerdata;
  void loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    final savedPhoneNo = prefs.getString('phoneNumber');
    final savedObjectId = prefs.getString('objectId'); // Add this line

    if (savedName != null) {
      name.text = savedName;
      print("Name: $savedName");
    }
    if (savedPhoneNo != null) {
      print("Phone Number: $savedPhoneNo");
      phoneno.text = savedPhoneNo;
    }
    if (savedObjectId != null) {
      print("Object ID: $savedObjectId"); // Print ObjectId value
    }
  }

  Future<void> Signup_api(BuildContext context) async {
    print("qwert");
    try {
      final response = await http.post(
        Uri.parse(
          signUpUrl(phoneno.text, name.text)
          ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno": int.parse(phoneno.text),
          "password": "Admin@123",
          "name": name.text,
          'domain': "appointment",
          'subdomain': "category",
        }),
      );

      if (response.statusCode == 200) {
        var a = response.body;
        if (a.startsWith('%')) {
          print("Response body is not JSON but contains an IP address: $a");
          // Handle this case as needed
        } else {
          var data = await jsonDecode(a);
          print(response.body);
          if (data['message'] == 'User Successfully Registered') {
            // Save user data in SharedPreferences
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('userName', name.text);
            prefs.setString('phoneNumber', phoneno.text);
            // Extract ObjectId from the response and save it in SharedPreferences
            final sourceData = jsonDecode(data['source']);
            final objectId = sourceData['_id']['\$oid'];
            prefs.setString('objectId', objectId);
            // User registration successful, proceed with any necessary actions
            snackbar_green(context, 'Appointment Booked Successfully ');
          } else if (data['errorCode'] == '104') {
            // User mobile number already exists, navigate to profile creation
            print("User mobile number already exists. Creating profile...");
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            final objectId = prefs.getString('objectId');
            await createProfile(objectId ?? ''); // Pass user ID if needed
          } else {
            // Display error messages from 'errorMsg' if available
            if (data.containsKey('errorMsg')) {
              snackbar_red(context, data['errorMsg']);
            } else {
              print(response.body);
            }
          }
        }
      } else {
        print(response.body);
        // Handle specific error messages based on errorCode
        var errorData = jsonDecode(response.body);
        if (errorData.containsKey('errorCode')) {
          switch (errorData['errorCode']) {
            case '103':
              snackbar_red(context, 'Invalid mobile number.');
              break;
            case '104':
              print("User mobile number already exists. Creating profile...");
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              final objectId = prefs.getString('objectId');
              await createProfile(objectId ?? '');
              break; // Added break statement here
            case '105':
              snackbar_red(context,
                  'For enhanced security, your password must contain at least one uppercase letter, one number, and one special character..');
              break;
            default:
              snackbar_red(context, 'Server Error: ${response.statusCode}');
              break;
          }
        } else {
          snackbar_red(context, 'Server Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      snackbar_red(context, 'An error occurred: $e');
      print("Error during API call: $e");
    }
  }

  Future<void> fetchProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      Domain = prefs.getString('Domain');
      SubDomain = prefs.getString('SubDomain');
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

            // Extracting values into variables
            mobileno = firstProfileData['mobileno'];
            proname = firstProfileData['name'];
            bussinessname = firstProfileData['business_name'];
            shopadress = firstProfileData['shop_address'];
            aboutbussines = firstProfileData['about_business'];

            // Print or use the variables as needed

            setState(() {
              providerdata = {
                'mobileno': mobileno,
                'business_name': bussinessname,
                'name': proname,
                'shop_address': shopadress,
                'about_business': aboutbussines
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

  var ProfileobjectId;
  String? getnewuserId;
  String? getDomain;
  String? getSubDomain;
  String? aoid;

  List<Map<String, dynamic>> salonData = [];

  final url =
     // "https://broadcastmessage.mannit.co/mannit/eCreate?domain=appointment&subdomain=category";
"http://192.168.1.13:8080/mannit/eCreate?domain=appointment&subdomain=category";
  Future<void> createProfile(String objectId) async {
    // Accept objectId as a parameter
    try {
      final response = await http.post(
        Uri.parse('$url&userId=$objectId'), // Append objectId to the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno": phoneno.text,
          "name": name.text,
          "currentDate": "${DateFormat('dd/MM/yy').format(_currentDateTime)}"
        }),
      );

      if (response.statusCode == 200) {
        // Successfully created the profile, handle the response accordingly
        print('User created successfully');
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

  late DateTime _currentDateTime;

  // final List<Map<String, String>> salondata = [
  //   {
  //     "num": "1",
  //     'name': 'Pradeep',
  //     'condition': 'Process',
  //   },
  //   {
  //     "num": "2",
  //     'name': 'Mathan',
  //     'condition': 'Process',
  //   },
  //   {
  //     "num": "3",
  //     'name': 'Krish',
  //     'condition': 'Process',
  //   },
  //   {
  //     "num": "4",
  //     'name': 'Mathan',
  //     'condition': 'waiting',
  //   },
  // ];
  void _showdialogue(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                      await Signup_api(context);
                      print(name.text + "  " + phoneno.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        });
  }

  // void fetchData() async {
  //   // Get the current date
  //   DateTime currentDate = DateTime.now();

  //   // Format the date according to your API URL format (assuming dd/MM/yy)
  //   String formattedDate =
  //       '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';

  //   // Construct the modified API URL with the current date
  //   final url =
  //       'https://broadcastmessage.mannit.co/mannit/eSearch?domain=appointment&subdomain=category&filtercount=1&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate';

  //   final response = await http.get(Uri.parse(url));

  //   // Check if the response status code is 200 (OK)
  //   if (response.statusCode == 200) {
  //     // Print the response body in the console
  //     print(response.body);
  //   } else {
  //     // Print an error message if the response status code is not 200
  //     print('Failed to fetch data: ${response.statusCode}');
  //   }
  // }

// Assuming this is your function to fetch data

  void fetchData() async {
    // final Url =
    //     'https://broadcastmessage.mannit.co/mannit/eSearch?domain=appointment&subdomain=category&filtercount=1&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate';
    // Fetch data from the API
    final response = await http.get(Uri.parse(url));

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> responseData = jsonDecode(response.body);
      print(responseData);

      // Update the salonData list with the parsed data
      setState(() {
        salonData = responseData.map((data) {
          return {
            'num': data['name'] ?? '', // Example: ObjectId
            'name': data['currentDate'] ?? '',
            'condition': data['conditoin'] ?? 'Process',
          };
        }).toList();
      });
    } else {
      // Print an error message if the response status code is not 200
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    loadUserData();
    fetchData();
    _updateDateTime();
  }

  @override
  void dispose() {
    name.dispose();
    phoneno.dispose();
    _disposed = true; // Set flag to true when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime tomorrow = _currentDateTime.add(const Duration(days: 1));
    // Create date format for DD/MM/YY
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const ReportScreen(),
                //     ));
              },
              icon: const Icon(
                Icons.report,
                color: Colors.white,
              ))
        ],
        title: Text(
          proname ?? '',
          // "Profile",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 0.5, // Border width
                ),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/salonapp.png",
                      width: MediaQuery.of(context).size.width * 0.40,
                      height: MediaQuery.of(context).size.height * 0.16,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Text(
                          proname ?? '',
                          // "Iface Hairdressing",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.28,
                        child: Row(
                          children: [
                            Text(
                              shopadress ?? '',
                              // "about app",
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        bussinessname ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 78, 77, 77),
                        ),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Text(
                            aboutbussines ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                const Text(
                  "     Today's Appointmensts",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                const Spacer(),
                Container(
                  height: 30,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    // Display current date and time
                    child: Text(
                      "${DateFormat('dd/MM/yy').format(_currentDateTime)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: salonData.isEmpty
                  ? const Center(
                      child: Text(
                        'No appointments available',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: salonData.length,
                      itemBuilder: (context, index) {
                        var salon = salonData[index];
                        return Saloncontsiner(
                          num: salon['name'] ?? '',
                          name: salon['currentDate'] ?? '',
                          condition: salon['condition'] ?? 'process',
                        );
                      },
                    )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        focusColor: Colors.white,
        elevation: 10,
        hoverColor: Colors.black,
        onPressed: () {
          _showdialogue(context);
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      // Expanded(
      //   child: ListView(
      //     children: history.map((profile) {
      //       return profileConatiner(
      //         name: profile['name'] ?? '',
      //         mobilno: profile['mobileno'] ?? '',
      //         oncall: () {
      //           _callNumber(profile['mobileno']!);
      //         },
      //         onwhatsapp: () {
      //           var whatsappUrl =
      //               "whatsapp://send?phone=${"91" + profile['mobileno']!}" +
      //                   "&text=${Uri.encodeComponent("hi...." + profile['name']!)}";
      //           try {
      //             launch(whatsappUrl);
      //           } catch (e) {
      //             //To handle error and display error message
      //             snackbar_red(context, "Unable to open whatsapp");
      //           }
      //         },
      //         toogle: true,
      //       );
      //     }).toList(),
      //   ),
      // ),
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
