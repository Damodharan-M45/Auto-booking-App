// ignore_for_file: non_constant_identifier_names, unnecessary_import, prefer_interpolation_to_compose_strings, unused_import, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:appointments/Mapscreen.dart';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/Provider/Homescree.dart';
import 'package:appointments/Regesterscreen/Resgister.dart';
import 'package:appointments/Regesterscreen/login.dart';
import 'package:appointments/autouser/userhome.dart';
import 'package:appointments/autouser/userlogin.dart';
import 'package:appointments/autouser/usermap.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class userSignupScreen extends StatefulWidget {
    
  const userSignupScreen({super.key,});

  @override
  State<userSignupScreen> createState() => _userSignupScreenState();
}

class _userSignupScreenState extends State<userSignupScreen> {
  bool? pass = true;
  TextEditingController phoneno = TextEditingController();
    TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userId = '';
  String Domain = '';
  String SubDomain = '';
  bool isSignup = true;
    bool _obscureText = true;
 String domain='';
String subdomain='';
void UerIdStoredSession(Map<String, dynamic> userDetails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (userDetails['source'] != null) {
    Map<String, dynamic> sourceMap = jsonDecode(userDetails['source']);
      prefs.setBool('usersignup', true);
      //prefs.setBool('login', true); // Set login flag
    if (sourceMap.containsKey('_id') && sourceMap['_id'] != null) {
      String  userId = sourceMap['_id']['\$oid'];
      prefs.setString('userId', userId);
      print('Session Object ID!: $userId');
    }

    // Remove the colon from the key to access the domain value
    if (sourceMap.containsKey('domain:') && sourceMap['domain:'] != null) {
      String domain = sourceMap['domain:'];
      prefs.setString('domain', domain);
      print("Domain: $domain");
    }

    if (sourceMap.containsKey('subdomain') && sourceMap['subdomain'] != null) {
      String subdomain = sourceMap['subdomain'];
      prefs.setString('subdomain', subdomain);
      print("Subdomain: $subdomain");
    }
    if (sourceMap.containsKey('mobileno') && sourceMap['mobileno'] != null) {
       String mobileNo = sourceMap['mobileno'].toString();
        prefs.setString("usermobileno", mobileNo);
      print("mobileNo: $mobileNo");
    }
      if (sourceMap.containsKey('username') && sourceMap['username'] != null) {
       String username = sourceMap['username'].toString();
        prefs.setString('username', username);
      print("username: $username");
    }
    if (sourceMap.containsKey('role') && sourceMap['role'] != null) {
       String role = sourceMap['role'].toString();
        prefs.setString('userrole', role);
      print("role: $role");
    }
  }
}

String? user="user";
String? admin="admin";
NotificationServices notificationServices=NotificationServices();
  Future<void> Signup_api(BuildContext context) async {
    print("qwert");
    try {
      String? deviceToken = await notificationServices.getDeviceToken();
      final response = await http.post(
        Uri.parse(
             "https://broadcastmessage.mannit.co/mannit/signup"
        //  signUpUrl(phoneno.text, password.text)
          ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
         "username":name.text,
          "mobileno": int.parse(phoneno.text),
          "password": password.text,
      
        "role": "User",
         "userdeviceToken":deviceToken,
         "domain:":proDomain,
          'subdomain': userSubDomain,
         
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
            UerIdStoredSession( data);
            await Session();
            await shared();
            await namestore();
            snackbar_green(context, 'User Successfully Registered');
  
        //     Navigator.pushReplacement(
        //         context,
        // MaterialPageRoute(
        //             builder: (context) =>
        //             //Admin())); 
        //           //userMapscreen(autoclick: true,autoadmin: false, AutouserId: '',)));
        //           userhome(autoclick: true,autoadmin: false, AutouserId: '',)));
         Navigator.pushReplacement(
                context,
        MaterialPageRoute(
                    builder: (context) =>
                    //Admin())); 
                    ChooseAppointmentscreen()));
                //userMapscreen(autoclick: true,autoadmin: false, AutouserId: '',)));
                 // userhome(autoclick: true,autoadmin: false, AutouserId: '',)));


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
              snackbar_red(context, 'User mobile number already exists.');
              break;
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

  shared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileno', phoneno.text);
    print(" stored mobileno:${phoneno.text}");
  }

  namestore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name.text);
    print(" stored user name:${name.text}");
  }
  Session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('usersignup', true);
  }
    bool submitClicked = false;
 @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
   
     return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              height: 180,
              width: 440,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110, left: 10, right: 10),
              child: Card(
                color: Colors.white,
                shadowColor: Color.fromARGB(255, 7, 241, 218),
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GradientText(
                          'SIGNUP',
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                          colors: [Colors.teal.shade600, Colors.teal.shade300],
                        ),
                        SizedBox(height: 20),
                          Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.teal,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                cursorColor: Colors.teal,
                                //maxLength: 10,
                                controller: name,
                                keyboardType: TextInputType.name,
                                 inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(color: Colors.black45),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'Name',
                                  hintText: 'Enter your name',
                                  //  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                       // SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.teal,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                cursorColor: Colors.teal,
                                maxLength: 10,
                                controller: phoneno,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(color: Colors.black45),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'Mobile number',
                                  hintText: 'Enter your mobile number',
                                  //  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your mobile number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        //SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.key,
                              color: Colors.teal,
                            ),
                            // Icon(Icons.key_rounded,),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                cursorColor: Colors.teal,
                                controller: password,
                                keyboardType: TextInputType.emailAddress,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(color: Colors.black45),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Text("")
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 570, ),
                child: GestureDetector(
                  onTap: () async {
                    print("hih");
                       setState(() {
                          submitClicked = true;
                        });
                    if (_formKey.currentState!.validate()) {
                      if (phoneno.text.trim().isEmpty) {
                        // Show an error message or handle the case where the phone number is not entered
                        snackbar_red(context, 'Please enter a phone number');
                      } else {
                        // Proceed with signup
                        await Signup_api(context);
                      //  print(password.text + "  " + phoneno.text);
                      }
              
                   
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 210,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade700, Colors.teal.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40)),
                    child: Center(
                        child: Text(
                      "SIGN UP",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
                  ),
                ),
              ),
            ),
           
               Center(
                 child: SizedBox(
                     width: MediaQuery.of(context).size.width*0.56,
                   child: Padding(
                     padding: const EdgeInsets.only(top:635),
                     child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                  color: Colors.black,
                                 // fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => userLoginscreen(),
                                    ));
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                   ),
                 ),
               ),
            Padding(
              padding: const EdgeInsets.only(top: 720, left: 0),
              child: Container(
                height: 130,
                width: 420,
                decoration: BoxDecoration(
                  // color: Colors.blue,
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ]),
        ));
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
