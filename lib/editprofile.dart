
import 'dart:convert';
import 'package:appointments/Home.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:appointments/saloonadmin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool pass = false;
  TextEditingController phoneno = TextEditingController();
  TextEditingController bussinessname = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController shopadress = TextEditingController();
  TextEditingController typebussiness = TextEditingController();
  TextEditingController aboutbussines = TextEditingController();
  TextEditingController address = TextEditingController();
    TextEditingController shop_name = TextEditingController();
  String? userId;
  String? Domain;
  String? SubDomain;
  String? aoid;
  String? oid;
  String? profileobjectId;
  String? selectedcatgory;
  String? selectedGender;

  String? selectedBlood;
  List<String> gender = ['Male', 'Female', 'Transgender'];
    List<String> saloongender = ['Male', 'Female', 'Unisex'];
  List<String> bloodgrp = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> cate = ['Clinic', 'Saloon', 'Pets'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<LatLng> _getLatLngFromAddress(String address) async {
    try {
      print("getlaTlon");
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      } else {
        print("nolatlon");
        return LatLng(0.0, 0.0); // Default value if geocoding fails
      }
    } catch (e) {
      print('Error during geocoding: $e');
      return LatLng(0.0, 0.0);
    }
  }

  getShareduserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    Domain = prefs.getString('domain');
    SubDomain = prefs.getString('subdomain');
    profileobjectId = prefs.getString('profileobjectId');
    oid = prefs.getString('oid');
  }

  var firstProfileData;
  bool isLoading = false;
  String? profileOid;
  Future<void> UpdateProfileApi(data) async {
    // Show loading indicator
    setState(() {
      isLoading = true;
    });
    try {
       String? token = await _firebaseMessaging.getToken(); // Get the FCM token
      print("updating profile.....");

      await getShareduserId();
      LatLng locationData = await _getLatLngFromAddress(shopadress.text);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
    //  profileOid = prefs.getString('profileOid');

      Map<String, dynamic> data = {
       // 'mobileno': phoneno.text,
        'name': name.text,
      //  "business name": bussinessname.text,
     if(businesstype!="Auto")  "shopname":shop_name.text,
        'gender': selectedGender,
        "bloodgroup": selectedBlood,
       if(businesstype!="Auto")    "location": {
          "lat": locationData.latitude,
          "lon": locationData.longitude,
        },
    if(businesstype=="Auto")      "registrationno":registration_no.text,
      // if(businesstype!="Auto") 'category': selectedcatgory,
      if(businesstype=="Auto")    'address':address,
        if(businesstype!="Auto") 'shop address': shopadress.text,
       //'business type': typebussiness.text,
       "address":address.text,
        'about business': aboutbussines.text,
     "   deviceToken":token
      };
      final response = await http.put(
        Uri.parse(ProfileUpdate_Url(userId, profileOid, Domain, SubDomain)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
      businesstype=="Auto"?  Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Autoadmin(),
            )):Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SalonBookscreen(),
            ));
        snackbar_green(context, "Profile updated  successfully");
        print('Data saved successfully');
        print(response.body);
        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to save data. Status code: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error in UpdateProfileApi: $e');
      // Hide loading indicator on error
    }
  }

  Future<void> getDetails() async {
    print("edit profile get DETAILS");
    try {
      await getShareduserId();

      final response = await http.get(
        Uri.parse(readProfile_url(userId, Domain, SubDomain, profileOid)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Profile read in edit successfully');

        var responseBody = response.body;
        print(response.body);

        // Parse the response body
        var data = jsonDecode(responseBody);

        if (data.containsKey('source') && data['source'] is List) {
          var sourceList = data['source'] as List;

          // Check if the list is not empty
          if (sourceList.isNotEmpty) {
            // Assuming you only need the first profile
            firstProfileData = jsonDecode(sourceList.first);

            setState(() {
              name.text = firstProfileData['name'] ?? "";

              phoneno.text = firstProfileData['mobileno'] ?? "";
              bussinessname.text = firstProfileData['business name'] ?? "";
              selectedGender = firstProfileData['gender'];
              selectedBlood = firstProfileData['bloodgroup'];
              selectedcatgory = firstProfileData['category'];
              shopadress.text = firstProfileData['shop address'] ?? "";
                 shop_name.text = firstProfileData['shopname'] ?? "";
                address.text = firstProfileData['address'] ?? "";
              typebussiness.text = firstProfileData['business type'] ?? "";
                 typebussiness.text = firstProfileData['business type'] ?? "";
businesstype=firstProfileData['business name'] ?? "";
registration_no.text=firstProfileData['registrationno'] ?? "";
              // Set the profileobjectId
              profileOid = firstProfileData['_id']['\$oid'];
              aboutbussines.text = firstProfileData['about business'];
            });
          } else {
            print('Profile data not found in the response');
          }
        } else {
          print('Source key not found or not a list in the response');
        }
      } else {
        print('Failed to read profile. Status code: ${response.statusCode}');
        // Handle specific error messages if needed
      }
    } catch (e) {
      snackbar_red(context, 'An error occurred: $e');
      print('Error: $e');
    }
  }

  Map<String, dynamic>? eventdata;
  get_details() {
    print("edit profile get detAILS");
    if (eventdata != null && eventdata!['profile'] != null) {
      Map<String, dynamic> profileData = eventdata!['profile'];
      if (profileData.containsKey('mobileno')) {
        setState(() {
          phoneno = profileData['mobileno'] ?? "";
        });
      }
      if (profileData.containsKey('name')) {
        setState(() {
          name.text = profileData['name'] ?? "";
        });
      }

      if (profileData.containsKey('gender')) {
        setState(() {
          selectedGender = profileData['gender'] ?? null;
        });
      }
       if (profileData.containsKey('shopname')) {
        setState(() {
          shop_name.text = profileData['shopname'] ?? null;
        });
      }
      if (profileData.containsKey('bloodgroup')) {
        setState(() {
          selectedBlood = profileData['bloodgroup'] ?? null;
        });
      }

      if (profileData.containsKey('business name')) {
        setState(() {
          bussinessname = profileData['business name'] ?? "";
        });
      }

      if (profileData.containsKey('category')) {
        setState(() {
          selectedcatgory = profileData['category'] ?? null;
        });
      }

      if (profileData.containsKey('shop address')) {
        setState(() {
          shopadress.text = profileData['shop address'] ?? "";
        });
      }
        if (profileData.containsKey('address')) {
        setState(() {
          address.text = profileData['address'] ?? "";
        });
      }
      if (profileData.containsKey('business type')) {
        setState(() {
          typebussiness.text = profileData['business type'] ?? "";
        });
      }
      if (profileData.containsKey('about business')) {
        setState(() {
          aboutbussines.text = profileData['about business'] ?? null;
        });
      }
    }
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      // return false;
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
 TextEditingController registration_no= TextEditingController();    
  Map<String, dynamic>? providerdata;
  String? resouceId;
  String? mobileno;
  String? DeviceToken;
  String? category;
    String? businesstype;
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
  
    
    getDetails();
    get_details();
 
  }

  @override
  void dispose() {
    name.dispose();
    phoneno.dispose();
    bussinessname.dispose();
    shopadress.dispose();
    typebussiness.dispose();
    aboutbussines.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body:profileOid==null?
      Center(child: CircularProgressIndicator(color: Colors.blue,)):
       Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                  left: 22,
                  top: 40,
                  child: IconButton(
                      onPressed: () {
                     businesstype=="Auto"?   Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Autoadmin(),
                            )):
                            Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalonBookscreen(),
                            ));
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ))),
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
                      colors: [
                        Colors.blueGrey.shade700,
                        Colors.blueGrey.shade300
                      ],
                      //  colors: [],
                    ),
                  ),
                ),
              ),
              Positioned(
                top:- 50,
                left:220,
                child: Container(
                  height: 220,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueGrey.shade700,
                        Colors.blueGrey.shade300
                      ],
                      //  colors: [],
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 100,
                left: 40,
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              Column(children: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        controller: name,
                           cursorColor: Colors.black,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        obscureText: pass ? true : false,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          hintText: "Name",
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        name: '',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter  name'; // Error message when field is empty
                          }
                          return null; // Return null if validation passes
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        controller: bussinessname,
                        enabled: false,
                        cursorColor: Colors.black,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        // obscureText: pass ? true : false,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          hintText: "Bussiness Name",
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.business,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        name: 'business name',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bussiness name'; // Error message when field is empty
                          }
                          return null; // Return null if validation passes
                        },
                      ),
                    ],
                  ),
                ),
                
                  businesstype=="Auto"?
                Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        cursorColor: Colors.black,
                        controller: registration_no,
                        // keyboardType: TextInputType.name,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                        // obscureText: pass ? true : false,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          hintText: "Auto Registration Number",
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.bookmark_outlined,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        name: '',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter registration number'; // Error message when field is empty
                        //   }
                        //   return null; // Return null if validation passes
                        // },
                        validator: (value) {
                // Custom validator to check if the format matches a pattern
                final validFormat =  RegExp(r'^[A-Za-z0-9\s]{10}$|^[A-Za-z0-9\s]{12}$|^[A-Za-z0-9\s]{11}$|^[A-Za-z0-9\s]{13}$');
                if (!validFormat.hasMatch(value ?? '')) {
                  return 'Invalid format.';
                }
                return null;
              },
                      ),
                    ],
                  ),
                ):
                 Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                          inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                        controller: shop_name,
                           cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          hintText: "Shop name",
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.store,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        name: 'shop name',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter shop name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: 170,
                          padding: const EdgeInsets.only(
                              right: 0, top: 0, bottom: 0),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.5, color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(15),
                              
                              hint: Text(
                                'Gender',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              items: businesstype=="Auto"?gender
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ))
                                  .toList():saloongender
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          width: 170,
                          padding: const EdgeInsets.only(
                              right: 0, top: 0, bottom: 0),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.5, color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              borderRadius: BorderRadius.circular(15),
                              hint: Text(
                                'Blood',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              items: bloodgrp
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedBlood,
                              onChanged: (value) {
                                setState(() {
                                  selectedBlood = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // businesstype!="Auto"?  Padding(
              //     padding:
              //         const EdgeInsets.only(left: 35, right: 30, bottom: 15),
              //     child: Container(
              //       width: 500,
              //       padding: const EdgeInsets.only(right: 0, top: 0, bottom: 0),
              //       decoration: ShapeDecoration(
              //         color: Colors.white,
              //         shape: RoundedRectangleBorder(
              //           side: BorderSide(width: 0, color: Colors.white),
              //           borderRadius: BorderRadius.circular(20),
              //         ),
              //       ),
              //       child: AbsorbPointer(
              //         absorbing: true,
              //         child: DropdownButtonHideUnderline(
              //           child: DropdownButton(
              //             borderRadius: BorderRadius.circular(15),
              //             hint: Text(
              //               'Category',
              //               style: TextStyle(
              //                   fontSize: 16,
              //                   color: Colors.black,
              //                   fontWeight: FontWeight.normal),
              //             ),
              //             padding: EdgeInsets.only(left: 10, right: 10),
              //             items: cate
              //                 .map((item) => DropdownMenuItem<String>(
              //                       value: item,
              //                       child: Text(
              //                         item,
              //                         style: TextStyle(
              //                             fontSize: 14,
              //                             color: Colors.black,
              //                             fontWeight: FontWeight.w500),
              //                       ),
              //                     ))
              //                 .toList(),
              //             value: selectedcatgory,
              //             onChanged: (value) {
              //               setState(() {
              //                 selectedcatgory = value;
              //               });
              //             },
              //           ),
              //         ),
              //       ),
              //     ),
              //   ):SizedBox(),

                businesstype=='Auto'?
                Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        controller: address,
                           cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          hintText: "Address",
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.location_pin,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        name: '',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ):
                 Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        controller: shopadress,
                           cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
                          fillColor: Colors.white,
                          focusColor: Colors.white,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                width: 1.5, color: Colors.white),
                          ),
                          hintText: "Shop Address",
                          prefixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.location_pin,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.black),
                        ),
                        name: '',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter shop address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 30, left: 35, bottom: 20, top: 0),
                  child: FormBuilderTextField(
                    cursorColor: Colors.black,
                    controller: aboutbussines,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    // obscureText: pass ? true : false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                          right: 10.0, left: 10.0, top: 20),
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(width: 1.5, color: Colors.white),
                      ),
                      hintText: "About Bussiness",
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.business,
                          color: Colors.black,
                        ),
                      ),
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    name: '',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      
                    },

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter about bussiness';
                      }
                      return null;
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      bool hasPermission = await checkLocationPermission();
                      if (!hasPermission) {
                        return;
                      }

                      try {
                        await _getLatLngFromAddress(shopadress.text);
                        await UpdateProfileApi(json);
                      } catch (error) {
                        // Handle any errors that might occur during the async operations
                        print('An error occurred: $error');
                        // Optionally, show an alert dialog to inform the user of the error
                      }
                    }
                  },

                  // },
                  child: Container(
                    height: 50,
                    width: 170,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                      child: Text(
                        "Update",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ]),
            ]),
          )),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  // request notification permission
  static Future Intt() async {
    await _firebaseMessaging.requestPermission(
        announcement: true,
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false);

    // get  the token for this device
    final token = await _firebaseMessaging.getToken();
    print("Device Token :$token");
  }
}