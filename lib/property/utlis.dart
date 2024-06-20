// ignore_for_file: constant_identifier_names, unused_import, non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

const Background_colour = Color.fromRGBO(253, 166, 35, 1.0);
Color eclipse_color1 = const Color.fromRGBO(255, 233, 133, 1.0);
Color eclipse_color2 = const Color.fromRGBO(250, 166, 43, 1.0);
Color Car_background = const Color.fromRGBO(78, 20, 17, 1.0);
Color auto_backgrond=Color(0xFFF8D921);

Color process = const Color.fromRGBO(111, 195, 150, 1.0);
Color waiting = const Color.fromRGBO(240, 177, 137, 1.0);
void snackbar_red(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    margin: const EdgeInsets.all(20),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void snackbar_green(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    margin: const EdgeInsets.all(20),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class Saloncontsiner extends StatelessWidget {
  final String num;
  final String name;
  final String condition;
  const Saloncontsiner(
      {super.key,
      required this.num,
      required this.name,
      required this.condition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 23, bottom: 10),
      child: Container(
        height: 45,
        width: 350,
        decoration: BoxDecoration(
            border:
                const Border(left: BorderSide(color: Colors.black, width: 7)),
            color: const Color.fromARGB(255, 229, 229, 229),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.08,
              child: Text(
                num,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.38,
              child: Text(
                name,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            condition == "waiting"
                ? Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                        color: waiting,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      condition,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )))
                : Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                        color: process,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      condition,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    )))
          ],
        ),
      ),
    );
  }
}

class profileConatiner extends StatefulWidget {
  final String name;
  final String mobilno;
  final VoidCallback oncall;
  final VoidCallback onwhatsapp;
  final bool toogle;
  const profileConatiner(
      {super.key,
      required this.name,
      required this.mobilno,
      required this.oncall,
      required this.onwhatsapp,
      required this.toogle});

  @override
  State<profileConatiner> createState() => _profileConatinerState();
}

class _profileConatinerState extends State<profileConatiner> {
  bool _switchValue = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 13, bottom: 10),
      child: Container(
        height: 50,
        width: 350,
        decoration: BoxDecoration(
            border:
                const Border(left: BorderSide(color: Colors.black, width: 7)),
            color: const Color.fromARGB(255, 229, 229, 229),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: Text(
                widget.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            GestureDetector(
              onTap: widget.onwhatsapp,
              child: Image.asset(
                "assets/whatapp.png",
                height: 30,
                width: 30,
              ),
            ),
            IconButton(
                onPressed: widget.oncall,
                icon: const Icon(Icons.phone, color: Colors.black)),
            Row(
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: CupertinoSwitch(
                    value: _switchValue,
                    trackColor: process,
                    activeColor: waiting,
                    onChanged: (value) {
                      setState(() {
                        _switchValue = value;
                        print(value ? 'on' : 'off');
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PatientContainer extends StatelessWidget {
  final String num;
  final String name;
  final String condition;
  const PatientContainer(
      {super.key,
      required this.num,
      required this.name,
      required this.condition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 23, bottom: 10),
      child: Container(
        height: 45,
        width: 350,
        decoration: BoxDecoration(
            border:
                const Border(left: BorderSide(color: Colors.blue, width: 7)),
            color: const Color.fromARGB(255, 229, 229, 229),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.08,
              child: Text(
                num,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.38,
              child: Text(
                name,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            condition == "waiting"
                ? Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                        color: waiting,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      condition,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )))
                : Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                        color: process,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      condition,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    )))
          ],
        ),
      ),
    );
  }
}

class PetsContainer extends StatelessWidget {
  final String num;
  final String name;
  final String condition;
  const PetsContainer(
      {super.key,
      required this.num,
      required this.name,
      required this.condition});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 23, bottom: 10),
      child: Container(
        height: 45,
        width: 350,
        decoration: BoxDecoration(
            border: const Border(
                left: BorderSide(
                    color: Color.fromARGB(255, 251, 208, 116), width: 7)),
            color: const Color.fromARGB(255, 229, 229, 229),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.08,
              child: Text(
                num,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.38,
              child: Text(
                name,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            condition == "waiting"
                ? Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                        color: waiting,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      condition,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )))
                : Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                        color: process,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Center(
                        child: Text(
                      condition,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    )))
          ],
        ),
      ),
    );
  }
}

class ReportContainer extends StatelessWidget {
  final String name;
  final String Date;
  final String time;
  final String business;
  //final String chip;
  //final String condition;
  const ReportContainer({
    super.key,
    required this.name,
    required this.Date,
     required this.time,
      required this.business,
      //required this.chip,
    //required this.condition
  });

  @override
  Widget build(BuildContext context) {
//print("chippppppppppppppppppppppppppppppppppp:$chip");
    print("business:$business");
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: 

      Container(
          height: 70,
          width: 380,
          decoration: BoxDecoration(
            border:  Border(left: BorderSide(color: business=="Auto"?  Colors.yellow:Colors.black, width: 7),
          //  right: BorderSide(color: Colors.teal, width: 7)
            ),
            color: const Color.fromARGB(255, 229, 229, 229), // Use containerColor
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              
                 const SizedBox(height: 15),
              const SizedBox(width: 5),
              Row(
                children: [
                    Padding(padding: EdgeInsets.only(left:10)),
               
                     
 Icon(Icons.person_pin,size: 30,),
                  SizedBox(width: 5,),
                  SizedBox(
                width: MediaQuery.of(context).size.width * 0.60,
                child: Text(
                name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
               Column(
                 children: [
                   Text(
                      Date,
                        style: const TextStyle(
                          color: Colors.black,
                          //fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                time,
                    style: const TextStyle(
                      color: Colors.black,
                     // fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                 ],
               ),
                   
                ],
              ),
                
             
         
        
            ],
          ),
          
        ),
    );
  }
}





class UserEventContainer extends StatelessWidget {
  final String title;
  final String duration;
  final String venue;
  final String description;
  final String sender_name;
  UserEventContainer(
      {required this.title,
      required this.duration,
      required this.venue,
      required this.sender_name,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, right: 20, left: 20),
      child: Material(
        elevation: 2.5,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
              ),
              SizedBox(
               // width: MediaQuery.of(context).size.width * 0.70,
                child: Text("  " + title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.39,
                        color: Color(0xff278D27))),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("  "),
                  Icon(
                    Icons.access_time_rounded,
                    color: Color(0xffFF6601),
                  ),
                  Text('  ' + duration + '  ')
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("  "),
                  Icon(
                    Icons.location_on_sharp,
                    color: Color(0xffFF6601),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(
                      venue,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              // Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           SizedBox(
              //             width: 10,
              //           ),
              //           Icon(
              //             Icons.groups,
              //             color: Colors.orange,
              //             size: 25,
              //           ),
              //           SizedBox(
              //             width: 10,
              //           ),
              //           Text(
              //             sender_name ?? "",
              //             style: TextStyle(
              //                 color: Colors.orange,
              //                 fontWeight: FontWeight.bold),
              //           ),
              //           Spacer(),
              //           IconButton(
              //             onPressed: () {
              //               Description.showAlert(context, description);
              //             },
              //             icon: Icon(Icons.more),
              //             color: Colors.green,
              //           )
              //         ],
              //       ),
              Row(
                children: [
                  Text("  "),
                  Icon(
                    Icons.person,
                    color: Color(0xffFF6601),
                    // size: 25,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    sender_name ?? "",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Description.showAlert(context, description);
                    },
                    icon: Icon(Icons.more),
                    color: Color(0xff278D27),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
class Description {
  static void showAlert(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Description"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Builder(
            builder: (context) {
              return Container(
                // color: Colors.orange,
                height: 400,
                width: MediaQuery.of(context).size.width * 0.80,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description.toString(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}


_AutoshowMarkerInfoDialog(
  BuildContext context,
  String name,
  String vehicle_no,
  String phone,
  String ratings,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display shop name
            Text('Vehicle Number:$vehicle_no'),
          //  const SizedBox(height: 8),
            // Display shop address
            // Text('Address: $shopAddress'),
            // const SizedBox(height: 8),
            // // Display about business
            // Text('About Business: $aboutBusiness'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to profile screen or perform any other action
              Navigator.of(context).pop();
            },
            child: Text(
              'call',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}




class DeletedialogBox {
  final BuildContext context;
  final String description;
  final Future<void> Function() onPressed;

  DeletedialogBox(this.context, this.description, this.onPressed);

  void show() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  size: 60.0,
                  color: Colors.red,
                ),
                SizedBox(height: 20.0),
                Text(
                  "Confirmation",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: onPressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

