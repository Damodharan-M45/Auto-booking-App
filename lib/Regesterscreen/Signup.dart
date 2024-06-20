
import 'dart:convert';
import 'package:appointments/Provider/choosebusiness.dart';
import 'package:appointments/Regesterscreen/Resgister.dart';
import 'package:appointments/Regesterscreen/login.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';


class SignupScreen extends StatefulWidget {

  const SignupScreen({super.key,});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? pass = true;
  TextEditingController phoneno = TextEditingController();
    TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userId = '';
  String Domain = '';
  String SubDomain = '';
  bool isSignup = true;

  bool submitClicked = false;
 String domain='';
String subdomain='';
  bool _obscureText = true;

void UerIdStoredSession(Map<String, dynamic> userDetails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (userDetails['source'] != null) {
    Map<String, dynamic> sourceMap = jsonDecode(userDetails['source']);
      prefs.setBool('adminsignup', true);
    //  prefs.setBool('login', true); // Set login flag
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
        prefs.setString("mobileno", mobileNo);
      print("mobileNo: $mobileNo");
    }
      if (sourceMap.containsKey('username') && sourceMap['username'] != null) {
       String username = sourceMap['username'].toString();
        prefs.setString('username', username);
      print("username: $username");
    }
     if (sourceMap.containsKey('role') && sourceMap['role'] != null) {
       String role = sourceMap['role'].toString();
        prefs.setString('adminrole', role);
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
        final SharedPreferences prefs = await SharedPreferences.getInstance();

    
     final subdomain = prefs.getString('businesssubdomain');
      print(proDomain);
      String? deviceToken = await notificationServices.getDeviceToken();
      final response = await http.post(
        Uri.parse(
          //"https://broadcastmessage.mannit.co/mannit/signup"
        signUpUrl(phoneno.text, password.text)
          ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
         "name":name.text,
          "mobileno": int.parse(phoneno.text),
          "password": password.text,
        "role": "Admin",
         "deviceToken":deviceToken,
         "domain:":proDomain,
         // 'subdomain': widget.subdomainName,
          'subdomain': subdomain,
         
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
          
            Navigator.pushReplacement(
                context,
        MaterialPageRoute(
                    builder: (context) =>
                    //Admin())); 
                     ResgisterScreen(subdomainName:subdomain!,)));
        //  Navigator.pushReplacement(
        //         context,
        // MaterialPageRoute(
        //             builder: (context) =>
        //             //Admin())); 
        //             ChooseBusiness()));
          }else if (response.statusCode == 500) {
       
         snackbar_red(context, 'Internal Server Error. Please try again later.');
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
         prefs.setBool('adminsignup', true);

  }
 @override
  void initState() {
    super.initState();
   
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
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
                          colors: [
                            Colors.blueGrey.shade600,
                            Colors.blueGrey.shade700,
                          ],
                        ),
                       
                        SizedBox(height: 20),
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return linearGradient;
                              },
                              child: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
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
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return linearGradient;
                              },
                              child: Icon(
                                Icons.key,
                                color: Colors.white,
                              ),
                            ),
                            // Icon(Icons.key_rounded,),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                cursorColor: Colors.blueGrey,
                                controller: password,
                                obscureText: _obscureText,
                                keyboardType: TextInputType.emailAddress,
                                // obscureText: true,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(color: Colors.black45),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          :Icons.visibility,
                                      color: Colors.blueGrey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
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
                padding: const EdgeInsets.only(top: 570,),
                child: GestureDetector(
                  onTap: () async {
                     setState(() {
                        submitClicked = true;
                      });
                    print("hih");
                    if (_formKey.currentState!.validate()) {
                      if (phoneno.text.trim().isEmpty) {
                        // Show an error message or handle the case where the phone number is not entered
                        snackbar_red(context, 'Please enter a phone number');
                      } else {
                        // Proceed with signup
                        await Signup_api(context);
                        print(password.text + "  " + phoneno.text);
                      }
              
                      // print(password.text + "  " + phoneno.text);
                      // await Signup_api(context);
                    }
                  },
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
                      "Signup",
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
                  padding: const EdgeInsets.only(top:640),
                  child: Row(
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                      SizedBox(width: 5,),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Loginscreen()),
                          );
                        },
                        child: Text(
                          "Login",
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