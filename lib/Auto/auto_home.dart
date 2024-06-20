// // ignore_for_file: prefer_const_literals_to_create_immutables, library_private_types_in_public_api, non_constant_identifier_names, avoid_print

// import 'dart:convert';
// import 'package:appointments/Auto/auto_report.dart';
// import 'package:appointments/Provider/Reportscreen.dart';
// import 'package:appointments/property/Crendtilas.dart';
// import 'package:http/http.dart' as http;
// import 'package:appointments/Provider/chooseappointments.dart';
// import 'package:appointments/property/utlis.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// class autoHome extends StatefulWidget {
//   const autoHome({super.key});

//   @override
//   State<autoHome> createState() => _autoHomeState();
// }

// class _autoHomeState extends State<autoHome> {
//   String? userId;
//   String? Domain;
//   String? SubDomain;
//   String? mobileno;
//   String? name;
//   String? bussinessname;
//   String? shopadress;
//   String? proname;
//   String? aboutbussines;
//   String? profileOid;
//   String? oid;
//   Map<String, dynamic>? providerdata;

//   Future<void> fetchProfileData() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       userId = prefs.getString('userId');
//       Domain = prefs.getString('Domain');
//       SubDomain = prefs.getString('SubDomain');
//       final response = await http.get(
//         Uri.parse(profileRead_url(userId, Domain, SubDomain)),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         print("profile data is :${response.body}");
//         if (data.containsKey('source') && data['source'] is List) {
//           var sourceList = data['source'] as List;

//           // Assuming you only need the first profile
//           if (sourceList.isNotEmpty) {
//             var firstProfileData = jsonDecode(sourceList.first);
// //9887634354
//             profileOid = firstProfileData['_id']['\$oid'];
//             mobileno = firstProfileData['mobileno'];
//             name = firstProfileData['name'];
//             bussinessname = firstProfileData['business name'];
//             shopadress = firstProfileData['shop address'];
//             aboutbussines =
//                 firstProfileData['about business'] ?? 'Default Name';

//             // Add more variables as needed

//             // Print or use the variables as needed
//             print('User ID: $userId');

//             print('Mobile Number: $mobileno');
//             print('Profile URL: $aboutbussines');
//             print('Name: $bussinessname');
//             print('Category: $profileOid');

//             // Print or use more variables as needed'
//             // prefs.setString('clientRole', clientRole ?? 'defaultRole');
//             prefs.setString('business name', bussinessname ?? "");

//             print(bussinessname);
//             print(profileOid);

//             setState(() {
//               providerdata = {
//                 'name': name,
//                 'mobileno': mobileno,
//                 "business name": bussinessname,
//                 "about business": aboutbussines,
//                 "shop address": shopadress
//               };
//             });
//           } else {
//             print('Profile data not found in the response');
//           }
//         } else {
//           print('Source key not found or not a list in the response');
//         }
//       } else {
//         print('Failed to fetch data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//   }

//   void _callNumber(String mobileno) async {
//     final phoneNumber = 'tel:$mobileno';

//     // Request permission to make phone calls
//     var status = await Permission.phone.request();
//     if (status.isGranted) {
//       try {
//         await launch(phoneNumber);
//       } catch (e) {
//         print('Could not launch phone call: $e');
//       }
//     } else {
//       print('Phone call permission denied');
//     }
//   }

// //6544892894
//   List<Map<String, dynamic>> salonData = [];
//   void fetchData() async {
//     try {
//       salonData.clear();
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       String businessname = prefs.getString('business name') ?? "";
//       print(businessname);
//       // Get the current date
//       DateTime currentDate = DateTime.now();
//       // Format the date according to your API URL format (assuming dd/MM/yy)
//       String formattedDate =
//           '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().substring(2)}';
//       final fetch =
//           'https://broadcastmessage.mannit.co/mannit/eSearch?domain=appointment&subdomain=category&filtercount=2&f1_field=currentDate_S&f1_op=eq&f1_value=$formattedDate&f2_field=shop name_S&f2_op=eq&f2_value=$businessname';
//       final response = await http.get(Uri.parse(fetch));
//       // Check if the response status code is 200 (OK)
//       if (response.statusCode == 200) {
//         // Parse the JSON response
//         final Map<String, dynamic> responseBody = jsonDecode(response.body);
//         print(responseBody);
//         // Check if the response data is in the expected format
//         if (responseBody.containsKey('message') &&
//             responseBody['message'] == 'Successfully Searched' &&
//             responseBody.containsKey('source')) {
//           List<dynamic> sources = responseBody['source'];
//           // Check if there are entries for the specified shop name and today's date
//           if (sources.isNotEmpty) {
//             setState(() {
//               // Update salonData with the parsed source data
//               salonData = List<Map<String, dynamic>>.from(
//                   sources.map((source) => jsonDecode(source)));
//             });
//           } else {
//             // Print a message if no entries are found for the specified criteria
//             print('No entries found for shop name and today\'s date.');
//           }
//         } else {
//           // Print an error message if the response data does not contain the expected fields
//           print('Unexpected response format: $responseBody');
//         }
//       } else {
//         // Print an error message if the response status code is not 200
//         print('Failed to fetch data: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Print an error message if an exception occurs
//       print('Error fetching data: $e');
//     }
//   }

//   @override
//   void initState() {
//     fetchData();
//     fetchProfileData();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: providerdata == null
//           ? null
//           : AppBar(
//               backgroundColor: Colors.black,
//               title: Text(
//                 providerdata!['business name'] ?? "",
//                 // "Iface Hairdressing ",
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               centerTitle: true,
//               actions: [
//                 Image.asset(
//                   "assets/salonapp.png",
//                   height: 60,
//                   width: 60,
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 AdminReport(busname: bussinessname ?? ""
//                                     // proname: proname,
//                                     ),
//                           ));
//                     },
//                     icon: const Icon(
//                       Icons.report,
//                       color: Colors.white,
//                     ))
//               ],
//               leading: IconButton(
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ChooseAppointmentscreen(),
//                         ));
//                   },
//                   icon: const Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.white,
//                   ))),
//       body: providerdata == null
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     top: 10,
//                     left: 10,
//                     right: 10,
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Colors.black,
//                         width: 0.5,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         ClipOval(
//                           child: Image.asset(
//                             "assets/salonapp.png",
//                             width: MediaQuery.of(context).size.width * 0.40,
//                             height: MediaQuery.of(context).size.height * 0.16,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.40,
//                               child: Text(
//                                 // '',
//                                 providerdata!['name'] ?? "",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 3,
//                             ),
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.28,
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     // "",
//                                     providerdata!['business name'] ?? "",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Text(
//                               // "",
//                               providerdata!['shop address'] ?? "",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Color.fromARGB(255, 78, 77, 77),
//                               ),
//                             ),
//                             SizedBox(
//                                 width: MediaQuery.of(context).size.width * 0.50,
//                                 child: Text(
//                                   providerdata!['about business'] ?? "",
//                                   // "",
//                                   style: const TextStyle(
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                   ),
//                                 ))
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: salonData.isEmpty
//                       ? const Center(
//                           child: Text('No reports available'),
//                         )
//                       : ListView.builder(
//                           itemCount: salonData.length,
//                           itemBuilder: (context, index) {
//                             final salon = salonData[index];
//                             final serialNumber = index + 1;
//                             // print(
//                             //     'resouceId: ${salon.containsKey('_id') ? salon['_id'].toString() : '--'}');
//                             // print(
//                             //     'userId: ${salon.containsKey('userId') ? salon['userId'].toString() : '--'}');
//                             // return SaloonAppoint(
//                             //   num: '$serialNumber',
//                             //   // num: salon['num'] ?? '',
//                             //   name: salon['name'] ?? '',
//                             //   condition: salon['condition'] ?? '',
//                             //   Date: salon['currentDate'] ?? '--',
//                             //   toogle: true,
//                             //   userId: salon.containsKey('userId')
//                             //       ? salon['userId'].toString()
//                             //       : '--',
//                             //   oncall: () {
//                             //     _callNumber(salon['mobileno'] ?? "");
//                             //   },
//                             //   resouceId: salon.containsKey('_id')
//                             //       ? salon['_id'].toString()
//                             //       : '--',
//                             //         onCreated: onCreatedCallback,
//                             // );

//                             void onCreatedCallback() {
//                               print(
//                                   'resouceId: ${salon.containsKey('_id') ? salon['_id']['\$oid'].toString() : '--'}');
//                               print(
//                                   'userId: ${salon.containsKey('userId') ? salon['userId']['\$oid'].toString() : '--'}');
//                             }

//                             return SaloonAppoint(
//                               num: '$serialNumber',
//                               name: salon['name'] ?? '',
//                               condition: salon['condition'] ?? '',
//                               Date: salon['currentDate'] ?? '--',
//                               toogle: true,
//                               userId: salon.containsKey('userId')
//                                   ? salon['userId']['\$oid'].toString()
//                                   : '--',
//                               oncall: () {
//                                 _callNumber(salon['mobileno'] ?? "");
//                               },
//                               resouceId: salon.containsKey('_id')
//                                   ? salon['_id']['\$oid'].toString()
//                                   : '--',
//                               onCreated: onCreatedCallback,
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton(
//         focusColor: Colors.white,
//         elevation: 10,
//         hoverColor: Colors.black,
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return const CustomAlertDialog();
//             },
//           );
//         },
//         backgroundColor: Colors.black,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30.0),
//         ),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 30,
//         ),
//       ),
//     );
//   }
// }

// class CustomAlertDialog extends StatefulWidget {
//   const CustomAlertDialog({super.key});

//   @override
//   _CustomAlertDialogState createState() => _CustomAlertDialogState();
// }

// class _CustomAlertDialogState extends State<CustomAlertDialog> {
//   TextEditingController name = TextEditingController();
//   TextEditingController phoneno = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.black,
//       title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//         IconButton(
//           icon: const Icon(
//             Icons.close,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         )
//       ]),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: name,
//             inputFormatters: [
//               UpperCaseTextFormatter(),
//             ],
//             decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.only(right: 10.0, left: 10.0),
//                 fillColor: Colors.white,
//                 focusColor: Colors.white,
//                 filled: true,
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 errorBorder: UnderlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 hintText: "Enter Name",
//                 labelStyle: const TextStyle(color: Colors.black),
//                 prefixIcon: const Icon(
//                   Icons.person,
//                   color: Colors.black,
//                 )),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             controller: phoneno,
//             keyboardType: TextInputType.number,
//             maxLength: 10,
//             cursorColor: Colors.black,
//             decoration: InputDecoration(
//                 counterStyle: const TextStyle(
//                   color: Colors.white,
//                 ),
//                 contentPadding: const EdgeInsets.only(right: 10.0, left: 10.0),
//                 fillColor: Colors.white,
//                 focusColor: Colors.white,
//                 filled: true,
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 errorBorder: UnderlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(width: 1.5, color: Colors.white),
//                 ),
//                 hintText: "Enter Mobile Number",
//                 labelStyle: const TextStyle(color: Colors.black),
//                 prefixIcon: const Icon(
//                   Icons.phone,
//                   color: Colors.black,
//                 )),
//           ),
//           const SizedBox(
//             height: 40,
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text(
//               'Submit',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     name.dispose();
//     phoneno.dispose();
//     super.dispose();
//   }
// }

// class UpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     return TextEditingValue(
//       text: newValue.text.toUpperCase(),
//       selection: newValue.selection,
// );
// }
// }
