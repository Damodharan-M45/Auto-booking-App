
import 'package:appointments/Regesterscreen/login.dart';
import 'package:appointments/autouser/userlogin.dart';
import 'package:appointments/autouser/usersignup.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointments/Provider/choosebusiness.dart';
import 'package:flutter/material.dart';
class Commonscreen extends StatelessWidget {
  const Commonscreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      
      onWillPop: () async { 
       SystemNavigator.pop();
       return false;
       },
      child: Scaffold(
        // appBar: AppBar(),
        // backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/common.jpg",
                  fit: BoxFit.fitHeight,
                  // opacity: ,
                ),
              ),
            ),
            Positioned(
              bottom: 420,
              right: 100,
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseBusiness(),
                      ),
                    );
                    //  Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>  Loginscreen(),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.990,
                    height: 500,
                    // height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueGrey.shade700,
                          Colors.blueGrey.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // borderRadius: BorderRadius.only(
                      //   bottomRight:
                      //       Radius.circular(470.0), // Adjust the radius as needed
                      // ),
                      border: Border.all(
                        color: Colors.blueGrey.shade700, // Border color
                        width: 0, // Border width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 170, 204, 221)
                              .withOpacity(1),
                          spreadRadius: 24,
                          blurRadius: 20,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/admin.png",
                            height: 120,
                            width: 130,
                            color: Colors.white,
                          ),
                          //style: GoogleFonts.alegreyaSc(
                          //
                          Text(
                            "Owner",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.alegreyaSc(
                                color: Colors.white, fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 420,
              left: 100,
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => userLoginscreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.990,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.5),
                          spreadRadius: 24,
                          blurRadius: 20,
                          offset: Offset(0, 0),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.5),
                        width: 0,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_alt_rounded,
                              size: 80, color: Colors.white),
                          SizedBox(height: 10),
                          Text(
                            "User",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.alegreyaSc(
                                color: Colors.white, fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}