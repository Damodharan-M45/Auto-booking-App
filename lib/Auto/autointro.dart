
import 'package:appointments/Mapscreen.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AutoIntro extends StatelessWidget {
  const AutoIntro({super.key,required this.autoclick});
  final bool autoclick;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: auto_backgrond,
        body: Column(
          children: [
          Padding(
             padding: const EdgeInsets.only(left: 300),
            child: Image.asset("assets/offround.png",)),
              Padding(
             padding: const EdgeInsets.only(top:5,left:250),
            child: Image.asset("assets/round1.png",)),
              Padding(
             padding: const EdgeInsets.only(top:5,left:200),
            child: Image.asset("assets/round2.png",)),
              Padding(
             padding: const EdgeInsets.only(top:5,left:160),
            child: Image.asset("assets/round3.png",)),

            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(child: Container(
                
                child: Image.asset("assets/auto_home.png",
                fit: BoxFit.fill,
                height: 200 ,))),
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Center(
                child: Text(
                  "Anytime, anywhere",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            Text(
              "with our auto booking app.",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(
              "Your journey, your way.",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 110,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  Mapscreen(autoclick: true,autoadmin: false, AutouserId: '',),
                    ));
              },
              child: Container(
                height: 60,
                width: 270,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Center(
                  child: Text(
                    "Lets Go",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
