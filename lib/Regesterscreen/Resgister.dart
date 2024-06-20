import 'dart:convert';
import 'dart:io';
import 'package:appointments/Home.dart';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:appointments/saloonadmin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResgisterScreen extends StatefulWidget {
 final String subdomainName;

const ResgisterScreen({super.key,required this.subdomainName,});

  @override
  State<ResgisterScreen> createState() => _ResgisterScreenState();
}

class _ResgisterScreenState extends State<ResgisterScreen> {
    TextEditingController aboutbussines = TextEditingController();
    bool pass = false;
     String vehicleRegistrationNumber = '';
  TextEditingController phoneno = TextEditingController();
  TextEditingController password = TextEditingController();
    TextEditingController bussinessname = TextEditingController();
    TextEditingController name = TextEditingController();
    TextEditingController registration_no= TextEditingController();    TextEditingController typebussiness = TextEditingController();
String selectedblood = "";
List bloodgroups=[

  "A+","A-","AB+","AB-","B+","B-"];
  List Businesses=[

  "Appartment","Auto","Car","Clinic","Salon","Pets"];
  String selectedBusiness = "";
    String selectedGender = "";

 TextEditingController shopadress = TextEditingController();

   NotificationServices notificationService=NotificationServices();
 String? deviceToken; // Variable to store the device token
// Initialize Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
   String? token='';
// Function to get the device token
   _getDeviceToken() async {
    // Request permission for receiving notifications (if not already granted)
    // NotificationSettings settings = await _firebaseMessaging.requestPermission(
    //   announcement: true,
    // );
    // print('User granted permission: ${settings.authorizationStatus}');

    // Get the device token
     token = await _firebaseMessaging.getToken();
    setState(() {
      deviceToken = token;
      print("token got:$token");
    });
  }


  String _imageBytes = "";
    TextEditingController shop_name=TextEditingController();
  TextEditingController Name = TextEditingController();
  TextEditingController PostalCode = TextEditingController();
  TextEditingController PartyId = TextEditingController();
  final Phoneno = TextEditingController();
  final Password = TextEditingController();
  String? Gender;
  String? member;
  TextEditingController stateController = TextEditingController();
  List gender = ["MALE", "FEMALE"];
  String? rol;
  String? roles;
  String? state;
  Uint8List? bintoimg;
  String? phoneNumber;
  bool submitClicked = false;
  //String? userId = '';

  TextEditingController address = TextEditingController();
  Future<LatLng> _getLatLngFromAddress(String address) async {
    try {
      print("getlaTlon");
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      } else {
        print("nolatlon");
        return LatLng(0.0, 0.0);
      }
    } catch (e) {
      print('Error during geocoding: $e');
      return LatLng(0.0, 0.0);
    }
  }

  Map<String, dynamic> data = {};
  String? newuserId;
  String? memberuserId;
  String? areauserId;
  String? mpuserId;
   String? userId ;
     String? adminId ;
    String? Domain ;
    String? SubDomain ;
    String? mobileno='';
  Session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('register', true);
  }

  var ProfileobjectId;
  String? getnewuserId;
  String? getDomain;
  String? getSubDomain;
  String? aoid;
// Function to store ObjectId in shared preferences
  Future<void> profileObjectId(String objectId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileobjectId', objectId);
    print("Profile object id: $objectId");
  }

  String? profileOid;
  String? resourceId;
  String profileName = "";
  String? category;

  String? partyId;
  String profileurl = "";
  String? type;
  String? clientRole;
  String? postalcode;
  
  Map<String, dynamic>? providerdata;

   getShareduserId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //userId = prefs.getString('userId');
      adminId=prefs.getString('adminId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      mobileno=prefs.getString('mobileno');
    }
  Future<void> AutoregisterBusiness() async {
    try {
   
      final SharedPreferences prefs = await SharedPreferences.getInstance();
     String?  userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      mobileno=prefs.getString('mobileno');

      final response = await http.post(
        Uri.parse(UserProfile_Url(userId, Domain, SubDomain)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobileno": mobileno,
          'business name':bussinessname.text,
          if(widget.subdomainName=="Auto")'registrationno': registration_no.text,
          "currentlocation": {
            "currentlat": _currentPosition!.latitude,
            "currentlon": _currentPosition!.longitude
          },
          "name": name.text,
          "role": "admin",
          "gender": selectedGender,
          "address": shopadress.text,
          "addresslatlon": await _getLatLngFromAddress(shopadress.text),
          'about business': aboutbussines.text,
          'bloodgroup':selectedblood,
          "deviceToken":deviceToken,
          "feedback":"0.0",
          "bookingstatus": "false",
          "Live":"true"
 }), 
      );

      if (response.statusCode == 200) {
        // Successfully created the profile, handle the response accordingly
        print('user created successfully');
        snackbar_green(context, "Registered Successfully ");
        print(response.body);

        print("profile userID:$getnewuserId");
        try {
          var responseData = jsonDecode(response.body);

          print('Response body: $responseData');

          if (responseData['message'] == 'Resource Created Successfully') {
            var source = jsonDecode(responseData['source']);
            ProfileobjectId = source['_id']['\$oid'];

            if (ProfileobjectId != null) {
              await profileObjectId(ProfileobjectId);
              // String name = source['name'];
              // String category = source['category'];
              // String state = source['state'];
              // String role=source['role'];
              //await storeProfileInfo(name, category, state,role);
              await Session();
              print('Session set');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Autoadmin(
                         
                        )),
              );
              print('Navigating to BottomNav');

              print('Profile created Successfully');
            } else {
              print('Failed to extract ObjectId from the response.');
            }
          } else {
            print('Response message is not "Resource Created Successfully".');
          }
        } catch (e) {
          print('Error decoding response: $e');
        }
      } else {
        // Failed to create the profile, handle the error accordingly
        print('Failed to create user. Status code: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // Handle any other errors that might occur during the API call
      print('Error in create user API: $e');
    }
  }
  Future<void> registerBusiness() async {
      await getShareduserId();
    
      final SharedPreferences prefs = await SharedPreferences.getInstance();
     String?  userId = prefs.getString('userId');
      Domain = prefs.getString('domain');
      SubDomain = prefs.getString('subdomain');
      mobileno=prefs.getString('mobileno');
     
     
      String apiUrl =
          'https://broadcastmessage.mannit.co/mannit/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$userId';

      // Prepare data to send to the API
      LatLng locationData = await _getLatLngFromAddress(shopadress.text);
      String? token = await _firebaseMessaging.getToken(); // Get the FCM token

      Map<String, dynamic> requestData = {
        // Add your request data here
        'mobileno': mobileno,
        'business name': bussinessname.text,
        'name': name.text,
        'shop address': shopadress.text,
        "location": {
          "lat": locationData.latitude,
          "lon": locationData.longitude,
        },
        // 'business type': typebussiness.text,
        'about business': aboutbussines.text,
        'feedback': "0.0",
        "gender": selectedGender,
        "bloodgroup": selectedblood,
        // "categoryshop": selectedShop,
       // "category": "Saloon",
        "shopname":shop_name.text,
        "deviceToken": token,
        "Live": "true"
      };

      try {
        // Make POST request to the API
        var response = await http.post(Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestData));

        // Handle response
        if (response.statusCode == 200) {
         
          print("api response:$requestData");
          snackbar_green(context, 'User Successfully Registered');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const SalonBookscreen()));
          print('Registration successful!');
          print(shopadress.text);
        } else {
          // If registration fails
          // Handle error scenario here

          print('Registration failed: ${response.statusCode}');
          // Show error message to the user
        }
      } catch (e) {
        // Handle any exceptions that occur during the API call
        print('Error occurred: $e');
        // Show error message to the user
      }
    }
    Position? _currentPosition;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      // Address.text = _currentPosition!.latitude.toString()+" "+_currentPosition!.longitude.toString();
      print([_currentPosition!.latitude, _currentPosition!.longitude]);
    }).catchError((e) {
      debugPrint(e);
    });
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

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _getCurrentPosition();
       _getDeviceToken();
    // getShareduserId();
    super.initState();
     // phonenoController.text = widget.phoneno;
    bussinessname.text = widget.subdomainName;
  }

  @override
  Widget build(BuildContext context) {
   
    
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
          backgroundColor:Colors.blueGrey.shade300,
          
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Stack(
                clipBehavior: Clip.none, children: [
              Positioned(
                    left: 260,
                    bottom: 450,
                    right: -42,
                    child: Container(
                      height: 430,
                      width: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [   Colors.blueGrey.shade700,
                              Colors.blueGrey.shade300,],
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
                          colors: [   Colors.blueGrey.shade700,
                              Colors.blueGrey.shade300,],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                  top: 75,
                 left: 50,
                 right: 50,
                  child: Center(
                    child: Text(
                      "Register Your Bussiness",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                 Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                               
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 30, left: 35, bottom: 20,top:150 ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormBuilderTextField(
                          cursorColor: Colors.black,
                          controller: name,
                           keyboardType: TextInputType.name,
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
                          // obscureText: pass ? true : false,
                          enabled: false, // Disable user input
                           style: TextStyle(color: Colors.black), // Set text color to red
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
                          name: '',
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
               widget.subdomainName!="Auto" ?  Padding(
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
                          // obscureText: pass ? true : false,
                         // enabled: false, // Disable user input
                           style: TextStyle(color: Colors.black), // Set text color to red
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
                              icon: 
                              const Icon(
                                Icons.store,
                                color: Colors.black,
                              ),
                             // Icon(FontAwesomeIcons.shoppingBag, size: 23, color: Colors.white)
                            ),
                            labelStyle: const TextStyle(color: Colors.black),
                          ),
                          name: '',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter shop name'; // Error message when field is empty
                            }
                            return null; // Return null if validation passes
                          },
                        ),
                      ],
                    ),
                  ):SizedBox(),
                                 widget.subdomainName=="Auto"||widget.subdomainName=="Car"?
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
                  ):SizedBox(),
                   Padding(
                      padding: const EdgeInsets.only(
                          right: 30, left: 35, bottom: 20, top: 0),
                      child: Row(
                        children: [
                         widget.subdomainName=="Saloon" ?   Expanded(
                            child: FormBuilderDropdown(
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
                                hintText: "Gender",
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.transgender,
                                    color: Colors.black,
                                  ),
                                ),
                                labelStyle: const TextStyle(color: Colors.black),
                              ),
                              name: 'gender',
                              items: ['Male', 'Female', 'Unisex']
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                selectedGender = value.toString();
      
                                print('Selected Gender: $selectedGender');
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select gender';
                                }
                                return null;
                              },
                            ),
                          ):Expanded(
                            child: FormBuilderDropdown(
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
                                hintText: "Gender",
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.transgender,
                                    color: Colors.black,
                                  ),
                                ),
                                labelStyle: const TextStyle(color: Colors.black),
                              ),
                              name: 'gender',
                              items: ['Male', 'Female', 'Transgender']
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                selectedGender = value.toString();
      
                                print('Selected Gender: $selectedGender');
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select gender';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FormBuilderDropdown(
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
                                hintText: "Blood",
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.bloodtype,
                                    color: Colors.black,
                                  ),
                                ),
                                labelStyle: const TextStyle(color: Colors.black),
                              ),
                              name: 'Blood',
                              items: [
                                'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                              ]
                                  .map((blood) => DropdownMenuItem(
                                        value: blood,
                                        child: Text(blood),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                selectedblood = value.toString();
      
                                print('Selected Blood Group: $selectedblood');
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select blood group';
                                }
                                return null;
                              },
                            ),
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
                          cursorColor: Colors.black,
                          controller: shopadress,
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
                            hintText:widget.subdomainName=="Auto"? "Address":"Shop Address",
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
                      textCapitalization: TextCapitalization.words,// Capitalize the first letter of each word
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                     onChanged: (value) {
            // Capitalize the first letter of the input
            final newValue = value!.isNotEmpty
                ? '${value[0].toUpperCase()}${value.substring(1)}'
                : value;
            // Update the text in the text field
            shopadress.value = shopadress.value.copyWith(
              text: newValue,
              selection: TextSelection.collapsed(offset: newValue.length),
            );
          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return widget.subdomainName=="Auto"?'Please enter your address':'Please enter your shop address';
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
                        child:  Column(
                          children: [
                            FormBuilderTextField(
                              cursorColor: Colors.black,
                              controller: aboutbussines,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              // obscureText: pass ? true : false,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(right: 10.0, left: 10.0,top:20),
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
                               textCapitalization: TextCapitalization.sentences,// Capitalize the first letter of each word
                               onChanged: (value) {
                                               // Capitalize the first letter of the input
                                                final newValue = value!.isNotEmpty
                                          ? '${value[0].toUpperCase()}${value.substring(1)}'
                                          : value;
                                                // Update the text in the text field
                                                aboutbussines.value = aboutbussines.value.copyWith(
                            text: newValue,
                            selection: TextSelection.collapsed(offset: newValue.length),
                                                );
                                              },
                                               
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter about bussiness';
                                }
                                return null;
                              },
                            ),
                             const SizedBox(
                          height: 30,
                        ),
                  
                       
                              GestureDetector(
                      
                      onTap: () async {
                        print("eneterint into on press");
                        setState(() {
                          submitClicked = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          print("eneterint into iffffffffffff");
                          if (_currentPosition == null) {
                            print('qq');
                            snackbar_red(
                                context, 'Please enable location service');
                            bool hasPermission =
                                await checkLocationPermission();
                            if (!hasPermission) {
                              await Geolocator.openAppSettings();
                              await _getCurrentPosition();
                            }
                          } else {
                            
                            //AutoregisterBusiness();
                              widget.subdomainName=="Auto"?
                          await AutoregisterBusiness():await registerBusiness();
                           
                          }
                        }
                      },
                      child: Container(
                      height: 50,
                      width: 170,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ),
                          ],
                        ),
                            ),
                              
                    
                  ],
                ),
                ]
              ),
            ),
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
