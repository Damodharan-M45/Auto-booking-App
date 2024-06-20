
import 'package:appointments/Home.dart';
import 'package:appointments/Provider/chooseappointments.dart';
import 'package:appointments/Regesterscreen/commonScreen.dart';
import 'package:appointments/saloonadmin.dart';
import 'package:appointments/splashscreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

//function to listen background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("some notifcation received");
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call initializeApp before using other Firebase services.
  // await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve login status from SharedPreferences
  bool? userLoggedIn = prefs.getBool('userlogin');
  bool? adminLoggedIn = prefs.getBool('adminlogin');
 bool? register = prefs.getBool('register');
String? logindomain = prefs.getString('domain');
String? loginsubdomain = prefs.getString('subdomain');
Future<void>  getsubdomain() async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
  
    String?  domain = prefs.getString('domain');
    String?  subdomain = prefs.getString('subdomain');
    print("domain///////////////////////////////////:$domain");
        print("subdomain///////////////////////////////////:$subdomain");
    }  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Listen to background
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // bool? login = prefs.getBool('login');
 getsubdomain() ;
  requestNotificationpermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  runApp( 
    MyApp(
     userLoggedIn: userLoggedIn,
    adminLoggedIn: adminLoggedIn,
     register: register,
     logindomain:logindomain,
     loginsubdomain:loginsubdomain
  )
  );
}

Future<void> requestNotificationpermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}


class MyApp extends StatefulWidget {
  final bool? userLoggedIn;
  final bool? adminLoggedIn;
  final String? logindomain;
  final String? loginsubdomain;
final bool? register;
  const MyApp({super.key,this.userLoggedIn, this.adminLoggedIn,this.register,required this.logindomain,required this.loginsubdomain});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    String?  domain ;
    String?  subdomain;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  
  }
  Widget build(BuildContext context) {
   
 // Determine which screen to show based on login status
    Widget initialScreen;
    if (widget.userLoggedIn == true) {
      initialScreen = const ChooseAppointmentscreen();
    } else if (widget.adminLoggedIn == true) {
      
      initialScreen = 
      widget.loginsubdomain=="Auto"?
      Autoadmin(): widget.loginsubdomain=="Saloon"?SalonBookscreen():Commonscreen();
    } 
    // else if (widget.register == true) {
    //   initialScreen = const ResgisterScreen(subdomainName: '');
    // }
    else {
      initialScreen = const SplashScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}

