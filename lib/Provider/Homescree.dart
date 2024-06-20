import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/material.dart';

class HomeSrceen extends StatefulWidget {
  //final bool fromuser;
  HomeSrceen({super.key,
  //required this.fromuser
  });

  @override
  State<HomeSrceen> createState() => _HomeSrceenState();
}

class _HomeSrceenState extends State<HomeSrceen> {
  @override
  void initState() {
    super.initState();
    _loadNextScreen();
  }

  void _loadNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const ChooseAppointmentscreen()),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Background_colour,
        body: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 260,
            bottom: 550,
            right: -42,
            child: Container(
              height: 430,
              width: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [eclipse_color1, eclipse_color2],
                ),
              ),
            ),
          ),
          Positioned(
            top: 670,
            left: -28,
            child: Container(
              height: 220,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [eclipse_color1, eclipse_color2],
                ),
              ),
            ),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              "assets/home.png",
            ),
            const Text(
              "CHOOSE YOUR APPOINTMENT",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            const Text('Loading...',
                style: TextStyle(fontSize: 20, color: Colors.white))
          ])
        ]));
  }
}
