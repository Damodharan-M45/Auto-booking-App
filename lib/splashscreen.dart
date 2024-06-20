
import 'package:appointments/Home.dart';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/Regesterscreen/Resgister.dart';

import 'package:appointments/Regesterscreen/commonScreen.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //NotificationService notificationService=NotificationService();
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      appstate();
    });
    super.initState();
  }

  appstate() async {
    if (mounted) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? userlogin = prefs.getBool('userlogin');
            bool? adminlogin = prefs.getBool('adminlogin');

      bool? usersignup = prefs.getBool('usersignup');
            bool? adminsignup = prefs.getBool('adminsignup');

      bool? register = prefs.getBool('register');
      print(adminlogin);
      print(usersignup);
       print(userlogin);
      print(adminsignup);
        print(register);
         

      if (adminlogin == null && usersignup == null && userlogin == null&& adminsignup == null && register == null ) {
        navigateToReplacement(context, Commonscreen());
      } else if (adminsignup == true && register == null) {
        navigateToReplacement(context, ResgisterScreen(subdomainName: '',));
      }
      else if (adminsignup == true && register == true && adminlogin==true) {
        navigateToReplacement(context, Autoadmin());
      }
      
      
       else if (usersignup == true && userlogin == true ) {
        navigateToReplacement(
            context,
            const ChooseAppointmentscreen());
      } else {
        navigateToReplacement(context, Commonscreen());
      }
    }
  }

  // Helper function for safe navigation
  void navigateToReplacement(BuildContext context, Widget page) {
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Commonscreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top shapes
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.3,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: CircleContainer(color: Colors.blueAccent, size: 0.5),
          ),
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.5,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: CircleContainer(color: Colors.purpleAccent, size: 4),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.7,
            left: -MediaQuery.of(context).size.width * 0.3,
            child: SquareContainer(color: Colors.redAccent, size: 0.3),
          ),

          Positioned(
            bottom: -MediaQuery.of(context).size.width * 0.2,
            right: -MediaQuery.of(context).size.width * 0.2,
            child: CircleContainer(color: Colors.greenAccent, size: 0.2),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.width * 0.5,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: CircleContainer(color: Colors.yellowAccent, size: 0.4),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: -MediaQuery.of(context).size.width * 0.3,
            child: SquareContainer(color: Colors.orangeAccent, size: 0.3),
          ),

          Center(
            child: Image.asset(
              "assets/logo1.jpg",
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class SquareContainer extends StatelessWidget {
  final Color color;
  final double size;

  SquareContainer({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * size,
      height: MediaQuery.of(context).size.width * size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
      ),
    );
  }
}

class CircleContainer extends StatelessWidget {
  final Color color;
  final double size;
  CircleContainer({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}