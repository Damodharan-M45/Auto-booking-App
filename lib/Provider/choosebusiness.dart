
import 'package:appointments/Regesterscreen/Signup.dart';
import 'package:appointments/Regesterscreen/login.dart';
import 'package:appointments/autouser/userlogin.dart';
import 'package:appointments/filtermap.dart';
import 'package:appointments/notify/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:appointments/Provider/Drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ChooseBusiness extends StatefulWidget {
  const ChooseBusiness({super.key});

  @override
  State<ChooseBusiness> createState() => _ChooseBusinessState();
}

class _ChooseBusinessState extends State<ChooseBusiness> {
  void _handleSubdomain(String subdomain) async {
    print('handled Subdomain: $subdomain');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('businesssubdomain', subdomain);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
     // _handleLocationPermission();
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

  NotificationServices notificationServices = NotificationServices();
  TextEditingController categoryController = TextEditingController();
void _filterCategories() {
    String query = categoryController.text.toLowerCase();
    setState(() {
      filteredCategories = allCategories
          .where((category) => category.label.toLowerCase().startsWith(query))
          .toList();
    });
  }

 

  void _handleSubdomainAndNavigate(String subdomain) {
    _handleSubdomain(subdomain);
    _navigateTo(Loginscreen());
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  List<Category> allCategories = [];
  List<Category> filteredCategories = [];
  @override
  void initState() {
    
    _handleLocationPermission();
    notificationServices.requestNotificationPermisions();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isRefreshToken();
    notificationServices.getDeviceToken().then((value) {
      print(value);
    });
    super.initState();

    allCategories = [
      Category(Icons.local_taxi_rounded, 'Auto',
          () => _handleSubdomainAndNavigate('Auto')),
      Category(
          Icons.cut, 'Saloon', () => _handleSubdomainAndNavigate('Saloon')),
      Category(Icons.local_hospital_rounded, 'Clinic',
          () => {}
          //_handleSubdomainAndNavigate('Clinic')
          ),
      Category(
          Icons.pets_outlined, 'Pets', () => {}),
    
           
      Category(Icons.directions_bike, 'Bike', () {}),
      Category(Icons.build, 'Mechanic', () {}),
      Category(Icons.local_shipping, 'Shipping', () {}),
      Category(Icons.airport_shuttle, 'Shuttle', () {}),
      Category(Icons.plumbing, 'Plumber', () {}),
      Category(Icons.home, 'Rental', () {}),
      Category(Icons.security, 'Watchman', () {}),
      Category(Icons.cleaning_services, 'Helper', () {}),
      Category(FontAwesomeIcons.truck, 'Load Van',
          () => {}
          //_handleSubdomainAndNavigate('Loadvan')
          ),
      Category(FontAwesomeIcons.baby, 'Baby Sitter', () {}),
      Category(FontAwesomeIcons.carRear, 'Cab', () {}),
      Category(FontAwesomeIcons.shirt, 'Laundry', () {}),
    ];

    // Initially show all categories
    filteredCategories = List.from(allCategories);

    // Add listener to filter categories based on search input
    categoryController.addListener(_filterCategories);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController category = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      
     // drawer: MyDrawer(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left:10),
              child: Text(
                "Welcome Owner!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right:60),
              child: Text(
                "Choose Your",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                "Business",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 10, left: 10, bottom: 20, top: 10),
            child: Column(
              children: [
                TextField(
                  controller: categoryController,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(right: 4.0, left: 5.0),
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    filled: true,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(width: 1.5, color: Colors.black),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(width: 1.5, color: Colors.black),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(width: 1.5, color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(width: 1.5, color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(width: 1.5, color: Colors.black),
                    ),
                    hintText: "Search for Categories",
                    suffixIcon: IconButton(
                      onPressed: () {
                        print("Search for Categories: ${category.text}");
                        category.clear();
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: filteredCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10.0,
                  ),
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return CategoryColumn(
                      icon: category.icon,
                      label: category.label,
                      onPressed: category.onPressed,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SlideAction(
              innerColor: Colors.white,
              outerColor: Colors.blueGrey,
              sliderButtonIcon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.blueGrey,
              ),
              borderRadius: 12,
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "            Slide to ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Seek  ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Icon(MdiIcons.mapSearch, size: 23, color: Colors.white),
                  Text(
                    " Appointments",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              textStyle: TextStyle(fontSize: 20, color: Colors.white),
              onSubmit: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => filterMapscreen()));
              },
            ),
          ),
          SizedBox(height: 30,)
        ],
      ),
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
            color: label=="Auto" || label=="Saloon"?Colors.teal:Colors.blueGrey,
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

class Category {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  Category(this.icon, this.label, this.onPressed);
}
