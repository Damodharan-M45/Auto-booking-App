// import 'package:appointments/Booking_screen/Salonbookui.dart';
// import 'package:appointments/Home.dart';
// import 'package:appointments/Mapscreen.dart';
// import 'package:flutter/material.dart';

// class Salonintro extends StatefulWidget {
//   const Salonintro({super.key});

//   @override
//   State<Salonintro> createState() => _SalonintroState();
// }

// class _SalonintroState extends State<Salonintro> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Container(
//         height: double.infinity, width: double.maxFinite,
//         // height: double.infinity,
//         // width: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/salon_home.png"),
//             fit: BoxFit.fill,
//           ),
//         ),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 30,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 440, left: 0),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const Mapscreen(autoclick: false,autoadmin: false,AutouserId: "",),
//                           ));
//                     },
//                     child: Image.asset(
//                       "assets/women_logo.png",
//                       height: 210,
//                       width: 140,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 440, left: 10),
//                   child: GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //     context,
//                       //     MaterialPageRoute(
//                       //       builder: (context) => const SalonBookscreen(),
//                       //     ));
//                     },
//                     child: Image.asset(
//                       "assets/men.png",
//                       height: 210,
//                       width: 150,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             const SizedBox(
//               height: 40,
//             ),
//             const Text(
//               "Select Your Gender",
//               style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:appointments/Mapscreen.dart';
import 'package:appointments/autouser/usermap.dart';
import 'package:appointments/saloonmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Salonintro extends StatefulWidget {
  const Salonintro({super.key});

  @override
  State<Salonintro> createState() => _SalonintroState();
}

class _SalonintroState extends State<Salonintro> {
  void _handleGenderSelection(String gender, String SubDomain) async {
    print('Selected gender: $gender');

    // Save the selected gender to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedGender', gender);
    prefs.setString('SubDomain', SubDomain);

    // Navigate to the Mapscreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => saloonMapscreen()),
    );
  }

  // void _Usnisex(String gender, String cat) async {
  //   print('Selecteduni: $gender');

  //   // Save the selected gender to shared preferences
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('Unisex', gender);
  //   prefs.setString('category', cat);

  //   // Navigate to the Mapscreen
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => Mapscreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/salon_home.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            // const SizedBox(
            //   height: 30,
            // ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 440, left: 0),
                  child: GestureDetector(
                    onTap: () {
                      _handleGenderSelection('Female', "Saloon");
                    },
                    child: CircleAvatar(
                      radius: 81,
                      backgroundColor: Colors.orange,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 78,
                        child: Image.asset(
                          "assets/femalesaloon.jpg",
                          height: 90,
                          width: 100,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 420, left: 4),
                  child: GestureDetector(
                    onTap: () {
                      _handleGenderSelection('Male', "Saloon");
                    },
                    child: CircleAvatar(
                      maxRadius: 81,
                      backgroundColor: Colors.orange,
                      child: CircleAvatar(
                        radius: 78,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          "assets/mensaloon.jpg",
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),

            GestureDetector(
              onTap: () {
                _handleGenderSelection('Unisex', "Saloon");
              },
              child: CircleAvatar(
                maxRadius: 80,
                backgroundColor: Colors.orange,
                child: CircleAvatar(
                  radius: 78,
                  foregroundColor: Colors.orange,
                  backgroundColor: Colors.orange,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 77,
                    child: Image.asset(
                      "assets/unisaloon.jpg",
                      height: 125,
                      width: 125,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "Choose Your Gender",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}