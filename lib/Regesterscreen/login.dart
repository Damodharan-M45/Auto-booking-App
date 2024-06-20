// ignore_for_file: unnecessary_import, use_build_context_synchronously, avoid_print, prefer_const_constructors_in_immutables

import 'dart:convert';

import 'package:appointments/Home.dart';
import 'package:appointments/Provider/choosebusiness.dart';
import 'package:appointments/Regesterscreen/Signup.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:appointments/saloonadmin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {

  Loginscreen({super.key, });

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool pass = false;
  TextEditingController phoneno = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var objectId;
  String mobileno = '';
  String Domain = '';
  bool load = false;
  String userId = '';

  String domain='';
String subdomain='';
String? Role;
  bool _obscureText = true;

Future<void> navigateBasedOnRole(String Role,) async {
   
    // AuthService.setUserRole(role);
  SharedPreferences prefs = await SharedPreferences.getInstance();
 String ? businesssubdomain= prefs.getString('businesssubdomain');
 String ? subdomain= prefs.getString('subdomain');
 print("Naviiiiii subdomain:$subdomain");
 print("Naviiiiii businesssubdomain:$businesssubdomain");
    if (Role == "Admin"&&businesssubdomain=="Auto") {

   if(subdomain==businesssubdomain){
      snackbar_green(context, 'Logged in successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Autoadmin()),
      );}
      else{
        snackbar_red(context, "You are not a Auto Owner");      }
      }
      else if(Role == "Admin"&&businesssubdomain=="Saloon"){
      if(subdomain==businesssubdomain) { snackbar_green(context, 'Logged in successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SalonBookscreen()));}
        else{
        snackbar_red(context, "You are not a Saloon Owner");      }
      
      }
     else {
      // Handle other roles or set a default navigation
      print("Unknown role: $Role");
      // You may choose to set a default navigation here
      snackbar_red(context, "Admin can Login");
    }
  }
void UerIdStoredSession(Map<String, dynamic> userDetails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (userDetails['source'] != null) {
    Map<String, dynamic> sourceMap = jsonDecode(userDetails['source']);
    prefs.setBool('adminlogin', true); // Set login flag
    if (sourceMap.containsKey('_id') && sourceMap['_id'] != null) {
      String userId = sourceMap['_id']['\$oid'];
      prefs.setString('userId', userId);
      print('Session Object ID!: $userId');
    }
    

    // Store the role in SharedPreferences
    if (sourceMap.containsKey('role') && sourceMap['role'] != null) {
    Role = sourceMap['role'];
      prefs.setString('adminrole', Role!);
      print("Role: $Role");
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
      prefs.setString('mobileno', mobileNo);
      print("Mobile Number: $mobileNo");
    }
           navigateBasedOnRole(Role!,);
  }
}
  Session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adminlogin', true);
  }

   Future<void> Login_api() async {
    try {
       print("admin login ");
     
             SharedPreferences prefs = await SharedPreferences.getInstance();
        String? role = prefs.getString('adminrole');
          print("roleeeeeee in admin:$role");
      final response = await http.post(
        Uri.parse(loginUrl(phoneno.text, password.text, domain, subdomain)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno": phoneno.text.trim(),
          "password": password.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Session();
UerIdStoredSession(data);
        print(data);
       
           print("RRRRoleeeee:$role");
        
  
          
      
      } else {
        snackbar_red(context, 'Invalid login credential');
      }
    } catch (e, stackTrace) {
      print('Error during login API call: $e');
      print('Stack trace: $stackTrace');
      snackbar_red(context, 'An error occurred. Please try again later.');
    }
  }
final Shader linearGradient = LinearGradient(
    colors: <Color>[
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade300,
    ],
  ).createShader(
      Rect.fromLTWH(56.0, 123.0, 200.0, 70.0)); // Adjust the Rect as needed
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
                  colors: [
                    Colors.blueGrey.shade700,
                    Colors.blueGrey.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 110, left: 10, right: 10),
              child: Card(
                color: Colors.white,
                shadowColor: Colors.blueGrey.shade600,
                surfaceTintColor: Colors.white,
                elevation: 10,
                // shadowColor: Colors.teal,
                // elevation: 20,
                // color: Colors.teal.shade50,
                // color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueGrey.shade700,
                                  Colors.blueGrey.shade300,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset("assets/admin.png",color: Colors.white,),height: 100,width: 100,),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                cursorColor: Colors.blueGrey,
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
                              color: Colors.blueGrey,
                            ),
                            // Icon(Icons.key_rounded,),
                            SizedBox(width: 10),
                            Expanded(
                                child: TextFormField(
                              cursorColor: Colors.blueGrey,
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
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            )),
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
            Padding(
              padding: const EdgeInsets.only(top: 570,),
              child: GestureDetector(
                onTap: () async {
                  print("admin login");
                  if (_formKey.currentState!.validate()) {
                    if (phoneno.text.trim().isEmpty) {
                      // Show an error message or handle the case where the phone number is not entered
                      snackbar_red(context, 'Please enter a phone number');
                    } else {
                      // Proceed with signup
                      await Login_api();
                      print(password.text + "  " + phoneno.text);
                    }

                    //print(password.text + "  " + phoneno.text);
                    // await Signup_api(context);
                  }
                },
                child: Center(
                  child: Container(
                    height: 50,
                    width: 210,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueGrey.shade700,
                            Colors.blueGrey.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40)),
                    child: Center(
                        child: Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.56,
                child: Padding(
                  padding: const EdgeInsets.only(top:640),
                  child: Row(
                    children: [
                      
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                  
                       GestureDetector(
                         onTap: () {
                        //  print("Autoooooo:${widget.subdomain}");
                           Navigator.pushReplacement(
                             context,
                             MaterialPageRoute(builder: (context) => SignupScreen()),
                           );
                         },
                         child: Text(
                           " Sign Up",
                           style: TextStyle(
                               color: Colors.black,
                               fontSize: 16,
                               fontWeight: FontWeight.bold),
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
                    colors: [
                      Colors.blueGrey.shade700,
                      Colors.blueGrey.shade300,
                    ],
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