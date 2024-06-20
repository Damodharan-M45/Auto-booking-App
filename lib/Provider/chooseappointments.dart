
// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:appointments/Mapscreen.dart';
import 'package:appointments/Provider/Reportscreen.dart';
import 'package:appointments/Push_notification.dart';
import 'package:appointments/Regesterscreen/commonScreen.dart';
import 'package:appointments/autouser/userhome.dart';
import 'package:appointments/autouser/usermap.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:appointments/Categories/salon_intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ChooseAppointmentscreen extends StatefulWidget {
  const ChooseAppointmentscreen({super.key});

  @override
  State<ChooseAppointmentscreen> createState() => _ChooseAppointmentscreenState();
}

class _ChooseAppointmentscreenState extends State<ChooseAppointmentscreen> {
@override




  String ?userName;
   usernamestored() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  userName=  await prefs.getString('username');
    print(" stored user name:$userName");
  }
  String? username;
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }
  
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //_handleLocationPermission();
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
   void _handleSubdomain(String subdomain) async {
    print('handled Subdomain: $subdomain');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('SubDomain', subdomain);
  }

 void initState() {
   // _handleLocationPermission();
  _loadUsername();
   usernamestored();


  
    super.initState();
  }
  
 logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? userlogin = prefs.getBool('userlogin');
           // bool? adminlogin = prefs.getBool('adminlogin');

      bool? usersignup = prefs.getBool('usersignup');
           // bool? adminsignup = prefs.getBool('adminsignup');

      bool? register = prefs.getBool('register');
      if (userlogin != null) {
        await prefs.remove('userlogin');
      }
   
      if (usersignup != null) {
        await prefs.remove('usersignup');
      }
    
    } catch (e) {
      print(e);
    }
  }
Future<void> showLogoutAlertDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('Confirm Logout',style: TextStyle(fontSize: 20),),
            ],
          ),
        content: Text(
            'Are you sure want to logout?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16
            ),
          ),
        actions: <Widget>[
           Row(
             children: [
               TextButton(
                style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.red)),
                child: Text('Cancel',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                         ),
                         Spacer(),
                          TextButton(
                style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.green)),
                child: Text('Ok',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  logout();
        
                  Navigator.of(context).pop();
                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Commonscreen(),
          ),
        );
                },
                         ),
                         
             ],
           ),
          
        ],
      );
    },
  );
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

  
    @override
  Widget build(BuildContext context) {
    TextEditingController category = TextEditingController();
    return userName == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.teal,),
            ),
          )
        : WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                actions: [
                  IconButton(
                      onPressed: () {
                        showLogoutAlertDialog(context);
                        // logout();
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => Commonscreen()));
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.teal,
                      ))
                ],
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                userhome(userhometomap: false),
                            ));
                        // ReportScreen(proname: proname);
                      },
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.teal,
                      )),
                ),
              ),
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              body: Stack(clipBehavior: Clip.none, children: [
                Positioned(
                  left: 10,
                  top: 20,
                  child: Row(
                    children: [
                      Text(
                        "Welcome  ",
                        style: const TextStyle(
                            color: Colors.black,
                            //fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text(
                        userName!,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10, left: 10, bottom: 30, top: 90),
                      child: Column(
                        children: [
                          TextField(
                            controller: category,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  right: 4.0, left: 5.0),
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              filled: true,
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    width: 1.5, color: Colors.black),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    width: 1.5, color: Colors.black),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    width: 1.5, color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    width: 1.5, color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    width: 1.5, color: Colors.black),
                              ),
                              hintText: "Search for Categories",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  print(
                                      "Search for Categories: ${category.text}");
                                  category.clear();
                                },
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                              ),
                              labelStyle:
                                  const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 350,
                      width: 370,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            
                              // CategoryColumn(
                                
                              //   icon: Icons.cut,
                              //   label: "Saloon",
                              //   onPressed: () {
                              //    _handleSubdomain('Saloon');
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) =>
                              //               const Salonintro(),
                              //         ));
                              //   },
                              // ),
                              
                              Column(
                                children: [
                                  IconButton(onPressed: (){
                                   _handleSubdomain('Saloon');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Salonintro(),
                                          ));
                                  }, icon: Icon(Icons.cut,color: Colors.teal,size: 40,)),
                                   Text(
           "Saloon",
            style: GoogleFonts.roboto(
              color: const Color.fromRGBO(0, 0, 0, 1),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
                                ],
                              ),
                              // CategoryColumn(
                              //   icon: Icons.local_taxi_rounded,
                              //   label: "Auto",
                              //   onPressed: () {
                              //     _handleSubdomain ("Auto");
                              //       Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => const userMapscreen(autoclick: true, autoadmin: false, AutouserId: '', userhometomap: false, adminuserid: '',),
                              //       ),
                              //     );
                              //   },
                              // ),
          Column(
                                children: [
                                  IconButton(onPressed: (){
                                _handleSubdomain ("Auto");
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const userMapscreen(autoclick: true, autoadmin: false, AutouserId: '', userhometomap: false, adminuserid: '',),
                                    ),
                                  );
                                  }, icon: Icon(Icons.local_taxi_rounded,color: Colors.teal,size:40 ,)),
                                   Text(
           "Auto",
            style: GoogleFonts.roboto(
              color: const Color.fromRGBO(0, 0, 0, 1),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
                                ],
                              ),
                                CategoryColumn(
                                icon: Icons.local_hospital_rounded,
                                label: "Clinic",
                                onPressed: () {
                                //  _handleGenderSelection('Clinic');
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           const Mapscreen(),
                                  //     ));
                                },
                              ),
                              CategoryColumn(
                                icon: Icons.pets_outlined,
                                label: "Pets",
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => const PetIntro(),
                                  //   ),
                                  // );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CategoryColumn(
                                icon: Icons.directions_bike,
                                label: "Bike",
                                onPressed: () {},
                              ),
                              CategoryColumn(
                                icon: Icons.build,
                                label: "Mechanic",
                                onPressed: () {},
                              ),
                              CategoryColumn(
                                icon: Icons.local_shipping,
                                label: "Shipping",
                                onPressed: () {},
                              ),
                              CategoryColumn(
                                icon: Icons.airport_shuttle,
                                label: "Shuttle",
                                onPressed: () {},
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CategoryColumn(
                                icon: Icons.plumbing,
                                label: "Plumber",
                                onPressed: () {},
                              ),
                              CategoryColumn(
                                icon: Icons.home,
                                label: "House rent",
                                onPressed: () {},
                              ),
                              CategoryColumn(
                                icon: Icons.security,
                                label: "Watchman",
                                onPressed: () {},
                              ),
                              CategoryColumn(
                                icon: Icons.cleaning_services,
                                label: "House help",
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ])),
        );
  }
}

class CategoryColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const CategoryColumn({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 40,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}