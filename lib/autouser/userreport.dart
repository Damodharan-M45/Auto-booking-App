// ignore_for_file: file_names, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:convert';
import 'package:appointments/notify/notification.dart';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class userReport extends StatefulWidget {

  const userReport({super.key, });

  @override
  State<userReport> createState() => _userReportState();
}

class _userReportState extends State<userReport> {
  final TextEditingController _dateController = TextEditingController();
  List<ReportContainer> reportContainers = [];
  List<Map<String, dynamic>> salonData = [];
  Future<void> fetchReportData() async {
    try {
setState(() {
  isloading=true;
});
    print("nnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? "";
        String? cat = prefs.getString('cat') ?? "";
      // print("Selected Date: $selectedDate");
       print("cattttttttttttttttttttttttttttttttttttttttttttttttttttttttt:$cat");
       
      // final Domain = prefs.getString('domain');
      // final SubDomain = prefs.getString('subdomain');
  final  Domain = prefs.getString('domain');
   final SubDomain = prefs.getString('adminSubDomain');
      String selectedDate = _dateController.text;
      print("domain:$Domain");
      print("Subdomain:$SubDomain");
      print("Selected Date: $selectedDate");
       print("userId in report: $userId");
    
     String url =
    cat=="Auto"?      '$base_url/eSearch?domain=$proDomain&subdomain=$cat&userId=$userId&filtercount=2&f1_field=currentDate_S&f1_op=eq&f1_value=$selectedDate&f2_field=appointment_S&f2_op=eq&f2_value=dropped'
    : '$base_url/eSearch?domain=$proDomain&subdomain=$cat&userId=$userId&filtercount=2&f1_field=currentDate_S&f1_op=eq&f1_value=$selectedDate&f2_field=appointment_S&f2_op=eq&f2_value=completed';

          //'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=1&f1_field=currentDate_S&f1_op=eq&f1_value=$selectedDate';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];
        print(responseBody);
        reportContainers.clear();
        for (final dynamic source in sources) {
          final Map<String, dynamic> itemData = jsonDecode(source);
          final String name = itemData['adminname'] ?? 'N/A';
          final String date = itemData['currentDate'] ?? 'N/A';
          final String time = itemData['currentTime'] ?? 'N/A';
          final String business = itemData['business name'] ?? 'N/A';
          reportContainers.add(
            ReportContainer(
              name: name,
              Date: date,
              time:time,
              business:business,
              //chip:cat!,
            ),
          );
        }
        setState(() {isloading=false;}); // Trigger rebuild to reflect changes
      } else {
        throw Exception('Failed to load report data (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching report data: $e');
    }
  }
NotificationServices notificationServices=NotificationServices();

List<bool> isSelected = [false, false, false, false,false];
void handleChipSelection(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = (i == index);
      }

      switch (index) {
        case 0:
          reportContainers.clear();
          break;
        case 1:
          reportContainers.clear();
          break;
        case 2:
          reportContainers.clear();
          break;
        case 3:
          reportContainers.clear();
          //  markers.clear();

          break;
        case 4:
          reportContainers.clear();
          // markers.clear();

          break;
        case 5:
          reportContainers.clear();
          //markers.clear();

          break;
      }
    });
  }

  void _handleGenderSelection(String cat) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cat', cat);
      print('Category updated: $cat');
    } catch (e) {
      print('Error updating category: $e');
    }
  }
  bool isloading=false;
  @override
  void initState() {
    super.initState();
     notificationServices.forgroundMessage();
    TextEditingController _dateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "Report",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
           SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // SelectableChip(
                //   txt: "CLINIC",
                //   bordercolor: Colors.white,
                //   selectedIcon: CupertinoIcons.bandage,
                //   selectedTextColor: Colors.white,
                //   isSelected: isSelected[0],
                //   onTap: () async {
                //     handleChipSelection(0);
                //     _handleGenderSelection('Clinic');
                //     // await _fetchMarkerPositions();
                //   },
                //   selectedColor: Colors.blue,
                //   selectedIconcolor: Colors.white,
                // ),
                SelectableChip(
                  txt: "AUTO",
                  selectedIcon: CupertinoIcons.car_fill,
                  selectedTextColor: Colors.black,
                  isSelected: isSelected[1],
                  selectedColor: Colors.yellow,
                  selectedIconcolor: Colors.white,
                  bordercolor: Colors.black,
                  onTap: () async {
                    _handleGenderSelection('Auto');
               
setState(() {
  reportContainers.clear();
});
                    handleChipSelection(1);
                     showDatePicker(
                            context: context,
                            builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                  colorScheme: ColorScheme.light(
                                                      primary: Colors.teal,
                                                      onPrimary: Colors.white,
                                                      surface:  Colors.white,
                                                      onSurface: Colors.black)),
                                              child: child!,
                                            );
                                          },
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                                      
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              setState(() {
                                _dateController.text =
                                    "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}";
                                      fetchReportData();
                                //"${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                              });
                            }
                          });
                 // await fetchReportData();
                  },
                ),
                // SelectableChip(
                //   selectedColor: Color.fromARGB(255, 240, 190, 64),
                //   selectedIconcolor: Colors.white,
                //   txt: "PETS",
                //   bordercolor: Colors.white,
                //   selectedIcon: CupertinoIcons.paw_solid,
                //   selectedTextColor: Colors.white,
                //   isSelected: isSelected[2],
                //   onTap: () async {
                //     _handleGenderSelection('Pets');
                //     handleChipSelection(2);
                //     //  await _fetchMarkerPositions();
                //   },
                // ),
                SelectableChip(
                  selectedColor: Colors.black,
                  txt: "SALOON",
                  bordercolor: Colors.white,
                  selectedIconcolor: Colors.white,
                  isSelected: isSelected[3],
                  onTap: () async {
                    _handleGenderSelection('Saloon');
                      handleChipSelection(3);
                    setState(() {
  reportContainers.clear();
});
 showDatePicker(
                            context: context,
                            builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                  colorScheme: ColorScheme.light(
                                                      primary: Colors.teal,
                                                      onPrimary: Colors.white,
                                                      surface:  Colors.white,
                                                      onSurface: Colors.black)),
                                              child: child!,
                                            );
                                          },
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                                      
                          ).then((selectedDate) {
                            if (selectedDate != null) {
                              setState(() {
                                _dateController.text =
                                    "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}";
                                      fetchReportData();
                                //"${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                              });
                            }
                          });
                  
                  //  await fetchReportData();
                    ;
                  },
                  selectedIcon: CupertinoIcons.scissors,
                  selectedTextColor: Colors.white,
                ),
                // SelectableChip(
                //   selectedIconcolor: Colors.white,
                //   selectedColor: Colors.amber,
                //   txt: "TAXI",
                //   isSelected: isSelected[4],
                //   onTap: () async {
                //     _handleGenderSelection('Taxi');

                //     handleChipSelection(4);
                //     // await _fetchMarkerPositions();
                //   },
                //   selectedIcon: CupertinoIcons.car,
                //   selectedTextColor: Colors.white,
                //   bordercolor: Colors.white,
                // )
              ],
           ),
),
    
          //),
          const SizedBox(height: 20),
          
          reportContainers.length == 0
              ? SizedBox(height: 270)
              : SizedBox(
                  height: 20,
                ),
          if (isloading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          else
            reportContainers.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: reportContainers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return reportContainers[index];
                      },
                    ),
                  )
                // : Center( child: CircularProgressIndicator( color: Colors.black,))
                : Center(
                    child: Text('No reports avilable',style: TextStyle(color: Colors.grey,fontSize: 26),
                  ),)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
}
}

class SelectableChip extends StatelessWidget {
  final String txt;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData selectedIcon;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color selectedIconcolor;
  final Color bordercolor;

  SelectableChip({
    required this.txt,
    required this.isSelected,
    required this.onTap,
    required this.selectedIcon,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.selectedIconcolor,
    required this.bordercolor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 35,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.blueGrey.shade100,
              border: Border.all(
                color: isSelected ? bordercolor : Colors.white,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Icon(
                    selectedIcon,
                    color: isSelected ? selectedTextColor : Colors.teal,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "   $txt   ",
                    style: TextStyle(
                      color: isSelected
                          ? selectedTextColor
                          : Colors.teal, // Modify this line
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}