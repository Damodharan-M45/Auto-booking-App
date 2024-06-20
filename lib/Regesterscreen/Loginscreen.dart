// // ignore_for_file: unnecessary_import, use_build_context_synchronously

// import 'dart:convert';

// import 'package:appointments/Admin/bottom_nav_bar.dart';
// import 'package:appointments/Booking_screen/Salonbookui.dart';
// import 'package:appointments/Home.dart';
// import 'package:appointments/Mapscreen.dart';
// import 'package:appointments/Regesterscreen/Signup.dart';
// import 'package:appointments/property/Crendtilas.dart';
// import 'package:appointments/property/utlis.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Loginscreen extends StatefulWidget {
  
//   Loginscreen({super.key});

//   @override
//   State<Loginscreen> createState() => _LoginscreenState();
// }

// class _LoginscreenState extends State<Loginscreen> {
//    bool? pass = true;
//   TextEditingController phoneno = TextEditingController();
//   TextEditingController password = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
// String domain='';
// String subdomain='';
// String? Role;

// void UerIdStoredSession(Map<String, dynamic> userDetails) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   if (userDetails['source'] != null) {
//     Map<String, dynamic> sourceMap = jsonDecode(userDetails['source']);
//     prefs.setBool('adminlogin', true); // Set login flag
//     if (sourceMap.containsKey('_id') && sourceMap['_id'] != null) {
//       String userId = sourceMap['_id']['\$oid'];
//       prefs.setString('userId', userId);
//       print('Session Object ID!: $userId');
//     }
    

//     // Store the role in SharedPreferences
//     if (sourceMap.containsKey('role') && sourceMap['role'] != null) {
//     Role = sourceMap['role'];
//       prefs.setString('adminrole', Role!);
//       print("Role: $Role");
//     }

//     // Remove the colon from the key to access the domain value
//     if (sourceMap.containsKey('domain:') && sourceMap['domain:'] != null) {
//       String domain = sourceMap['domain:'];
//       prefs.setString('domain', domain);
//       print("Domain: $domain");
//     }

//     if (sourceMap.containsKey('subdomain') && sourceMap['subdomain'] != null) {
//       String subdomain = sourceMap['subdomain'];
//       prefs.setString('subdomain', subdomain);
//       print("Subdomain: $subdomain");
//     }

//     if (sourceMap.containsKey('mobileno') && sourceMap['mobileno'] != null) {
//       String mobileNo = sourceMap['mobileno'].toString();
//       prefs.setString('mobileno', mobileNo);
//       print("Mobile Number: $mobileNo");
//     }
   
//   }
// }
//   Session() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('adminlogin', true);
//   }
//   Future<void> Login_api1() async {
//     try {
//        print("admin login ");
     
//              SharedPreferences prefs = await SharedPreferences.getInstance();
//         String? role = prefs.getString('adminrole');
//           print("roleeeeeee in admin:$role");
//       final response = await http.post(
//         Uri.parse(loginUrl(phoneno.text, password.text, domain, subdomain)),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "mobileno": phoneno.text.trim(),
//           "password": password.text.trim(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
// UerIdStoredSession(data);
// await Session();
//         print(data);
       
//           print(phoneno.text);
//           print(password.text);
//            print("RRRRoleeeee:$role");

           
//         if(Role=="admin"){
// Navigator.push(context,
//               MaterialPageRoute(builder: (context) =>  SalonBookscreen()));
//   snackbar_green(context, 'Logged in successfully');
//             }else if (Role=="user"){
//               // snackbar_red(context, 'Only admins can login');
//             }
//   else{
//     print(" logiiinnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
//   }
      
//       } else {
//       //  snackbar_red(context, 'Invalid login credential');
//       }
//     } catch (e, stackTrace) {
//       print('Error during login API call: $e');
//       print('Stack trace: $stackTrace');
//       snackbar_red(context, 'An error occurred. Please try again later.');
//     }
//   }
//    Future<void> Login_api() async {
//     try {
//        print("admin login ");
     
//              SharedPreferences prefs = await SharedPreferences.getInstance();
//         String? role = prefs.getString('adminrole');
//           print("roleeeeeee in admin:$role");
//       final response = await http.post(
//         Uri.parse(loginUrl(phoneno.text, password.text, domain, subdomain)),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "mobileno": phoneno.text.trim(),
//           "password": password.text.trim(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         Session();
// UerIdStoredSession(data);
//         print(data);
       
//            print("RRRRoleeeee:$role");
//         if(Role=="admin"){
// Navigator.push(context,
//               MaterialPageRoute(builder: (context) =>  SalonBookscreen()));
//   snackbar_green(context, 'Logged in successfully');
//             }else if (Role=="user"){
//                snackbar_red(context, 'Only admins can login');
//             }
//   else{
//     print(" logiiinnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
//   }
  
//   //   print("roleeeee:$role");
 
// // if(widget.fromuser!=true){
// //   if(role == 'user'){
// //           print("userrrrrrrrrrrr");
// //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Mapscreen(autoclick: true, autoadmin: false, AutouserId: '',)));
// //         }
// // }else if(widget.fromuser==true){
// //   if (role == 'admin') {
// //           print("adminnnnnnn");
// //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SalonBookscreen()));
// //         } 
// // }else{
// //   print("no screens");
// // }
//         // if (role == 'admin') {
//         //   print("adminnnnnnn");
//         //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SalonBookscreen()));
//         // } else if(role == 'user'){
//         //   print("userrrrrrrrrrrr");
//         //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Mapscreen(autoclick: true, autoadmin: false, AutouserId: '',)));
//         // }
          
      
//       } else {
//         snackbar_red(context, 'Invalid login credential');
//       }
//     } catch (e, stackTrace) {
//       print('Error during login API call: $e');
//       print('Stack trace: $stackTrace');
//       snackbar_red(context, 'An error occurred. Please try again later.');
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
// print("roleeeee:$Role");
//   }
//   @override
// void dispose() {
//   phoneno.dispose();
//   password.dispose();
//   super.dispose();
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Background_colour,
//       body: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Stack(
//             clipBehavior: Clip.none, 
//             children: [
//                Positioned(
//               left: 260,
//               bottom: 380,
//               right: -42,
//               child: Container(
//                 height: 400,
//                 width: 210,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [eclipse_color1, eclipse_color2],
//                   ),
//                 ),
//               ),
//             ),
//              Positioned(
//               top: 650,
//               left: -28,
//               child: Container(
//                 height: 220,
//                 width: 200,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [eclipse_color1, eclipse_color2],
//                   ),
//                 ),
//               ),
//             ),
//             Column(children: [
//               const SizedBox(
//                 height: 20,
//               ),
//               // Image.asset(
//               //   "assets/home.png",
//               // ),
                     
//                        Padding(
//                       padding: const EdgeInsets.only(
//                           right: 30, left: 35, bottom: 10, top: 340),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           FormBuilderTextField(
//                             maxLength: 10,
//                             keyboardType: TextInputType.number,
//                             controller: phoneno,
//                             decoration: InputDecoration(
//                               contentPadding:
//                                   const EdgeInsets.only(right: 10.0, left: 10.0),
//                               fillColor: Colors.white,
//                               focusColor: Colors.white,
//                               filled: true,
//                               disabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: const BorderSide(
//                                     width: 1.5, color: Colors.white),
//                               ),
//                               focusedErrorBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: const BorderSide(
//                                     width: 1.5, color: Colors.white),
//                               ),
//                               errorBorder: UnderlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: const BorderSide(
//                                     width: 1.5, color: Colors.white),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: const BorderSide(
//                                     width: 1.5, color: Colors.white),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: const BorderSide(
//                                     width: 1.5, color: Colors.white),
//                               ),
//                               hintText: "  Enter Phone Number",
//                               prefixIcon: IconButton(
//                                 onPressed: () {},
//                                 icon: const Icon(
//                                   Icons.phone,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               labelStyle: const TextStyle(color: Colors.black),
//                             ),
//                             autovalidateMode: AutovalidateMode.onUserInteraction,
//                             validator: (value) {
//                               if (value!.isEmpty) {
//                                 return "Enter phone number";
//                               } else if (value.length < 10) {
//                                 return "Enter valid phone number";
//                               } else if (value.startsWith(RegExp('[0-5]'))) {
//                                 return "Phone number cannot start with 0, 1, 2, 3, 4, 5";
//                               } else {
//                                 return null;
//                               }
//                             },
//                             name: '',
//                           ),
//                         ],
//                       ),
//                     ),
            
//               Padding(
//                       padding: const EdgeInsets.only(
//                           right: 30, left: 35, bottom: 10, top: 0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           FormBuilderTextField(
//                               controller: password,
//                               obscureText: pass! ? true : false,
//                               decoration: InputDecoration(
//                                 contentPadding: const EdgeInsets.only(
//                                     right: 10.0, left: 10.0),
//                                 fillColor: Colors.white,
//                                 focusColor: Colors.white,
//                                 filled: true,
//                                 disabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                   borderSide: const BorderSide(
//                                       width: 1.5, color: Colors.white),
//                                 ),
//                                 focusedErrorBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                   borderSide: const BorderSide(
//                                       width: 1.5, color: Colors.white),
//                                 ),
//                                 errorBorder: UnderlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                   borderSide: const BorderSide(
//                                       width: 1.5, color: Colors.white),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                   borderSide: const BorderSide(
//                                       width: 1.5, color: Colors.white),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                   borderSide: const BorderSide(
//                                       width: 1.5, color: Colors.white),
//                                 ),
//                                 hintText: "  Enter Password",
//                                 suffixIcon: IconButton(
//                                   icon: Icon(
//                                     !pass!
//                                         ? Icons.visibility
//                                         : Icons.visibility_off,
//                                     color: Colors.black,
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       pass = !pass!;
//                                     });
//                                   },
//                                 ),
//                                 prefixIcon: IconButton(
//                                   onPressed: () {},
//                                   icon: const Icon(
//                                     Icons.lock,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 labelStyle: const TextStyle(color: Colors.black),
//                               ),
//                               name: '',
//                               autovalidateMode:
//                                   AutovalidateMode.onUserInteraction,
//                               validator: (value) {
//                                 if (value!.length < 8) {
//                                   return "Password length must be greater than 8 characters";
//                                 } else {
//                                   return null;
//                                 }
//                               }),
//                         ],
//                       ),
//                     ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     '                   Don\'t have an account? ',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const SignupScreen(),
//                           ));
//                     },
//                     child: const Text(
//                       'Sign Up',
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 17),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               GestureDetector(
//                 onTap: () async {
//                   if (_formKey.currentState!.validate()) {
//                     print(1);
//                   //  await Login_api1();
//                      await Login_api();
//                   }
//                 },
//                 child: Container(
//                   height: 50,
//                   width: 150,
//                   decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.all(Radius.circular(20))),
//                   child: const Center(
//                     child: Text(
//                       "Login",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               )
//             ]),
//           ]),
//         ),
//       ),
//     );
//   }
// }
