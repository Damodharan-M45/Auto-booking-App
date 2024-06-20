// ignore_for_file: unnecessary_import, use_build_context_synchronously

import 'dart:convert';
import 'package:appointments/Home.dart';
import 'package:appointments/Mapscreen.dart';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/Regesterscreen/Signup.dart';
import 'package:appointments/autouser/userhome.dart';
import 'package:appointments/autouser/usermap.dart';
import 'package:appointments/autouser/usersignup.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userLoginscreen extends StatefulWidget {
  
  userLoginscreen({super.key,});

  @override
  State<userLoginscreen> createState() => _userLoginscreenState();
}

class _userLoginscreenState extends State<userLoginscreen> {
   bool? pass = true;
  TextEditingController phoneno = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // String domain = "appiontmanet";
  // String subdomain = "category";
String domain='';
String subdomain='';
String? Role;


  void navigateBasedOnRole(String Role) {
    // AuthService.setUserRole(role);

    if (Role == "User") {
      snackbar_green(context, 'Logged in successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChooseAppointmentscreen()),
      );
    } else {
      // Handle other roles or set a default navigation
      print("Unknown role: $Role");
      // You may choose to set a default navigation here
      snackbar_red(context, "User can Login");
    }
  }
void UerIdStoredSession(Map<String, dynamic> userDetails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
print("user login stored data...............................");
  if (userDetails['source'] != null) {
    Map<String, dynamic> sourceMap = jsonDecode(userDetails['source']);
       await prefs.setBool('userlogin', true);

    if (sourceMap.containsKey('_id') && sourceMap['_id'] != null) {
      String userId = sourceMap['_id']['\$oid'];
      prefs.setString('userId', userId);
      print('Session Object ID!: $userId');
    }

    // Store the role in SharedPreferences
    if (sourceMap.containsKey('role') && sourceMap['role'] != null) {
    Role = sourceMap['role'];
      prefs.setString('userrole', Role!);
      print("Role: $Role");
    }
 if (sourceMap.containsKey('username') && sourceMap['username'] != null) {
       String username = sourceMap['username'].toString();
        prefs.setString('username', username);
      print("username: $username");
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
      prefs.setString('usermobileno', mobileNo);
      print("Mobile Number: $mobileNo");
    }
     navigateBasedOnRole(Role!); 
  }
}

  Future<void> Login_api() async {
    try {
    print("user login ");
       SharedPreferences prefs = await SharedPreferences.getInstance();
        String? role = prefs.getString('userrole');
      final response = await http.post(
        Uri.parse(loginUrl(phoneno.text, password.text, domain, subdomain)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno": phoneno.text.trim(),
          "password": password.text.trim(),
        }),
      );
print("roleeeeeeeee in user login:$Role");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
UerIdStoredSession(data);
Session();
        print(data);
      
            
      }  else {
        print(response.statusCode);
        snackbar_red(context, 'Invalid login credential');
      }
    } catch (e, stackTrace) {
      print('Error during login API call: $e');
      print('Stack trace: $stackTrace');
      snackbar_red(context, 'An error occurred. Please try again later.');
    }
  }
  Session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('userlogin', true);
  }


 bool _obscureText = true;

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
                        Container(
                            height: 70,
                            width: 70,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade700,
                                  Colors.teal.shade300
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people_alt_rounded,
                              color: Colors.white,
                              size: 35,
                            )),
                      SizedBox(height: 20),
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
                       // SizedBox(height: 20),
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
                    if (_formKey.currentState!.validate()) {
                      if (phoneno.text.trim().isEmpty) {
                        // Show an error message or handle the case where the phone number is not entered
                        snackbar_red(context, 'Please enter a phone number');
                      } else {
                        // Proceed with signup
                        await Login_api();
                       // print(password.text + "  " + phoneno.text);
                      }
              
                      //print(password.text + "  " + phoneno.text);
                      // await Signup_api(context);
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
                      "LOG IN",
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
                  padding: const EdgeInsets.only(top:635,),
                  child: Row(
                   // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
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
                                builder: (context) => const userSignupScreen(),
                              ));
                        },
                        child: const Text(
                          'Sign Up',
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
