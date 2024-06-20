// ignore_for_file: file_names, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:convert';
import 'package:appointments/property/Crendtilas.dart';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminReport extends StatefulWidget {
  final String busname;
  const AdminReport({super.key, required this.busname});

  @override
  State<AdminReport> createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  final TextEditingController _dateController = TextEditingController();
  List<ReportContainer> reportContainers = [];
  List<Map<String, dynamic>> salonData = [];
   String? SubDomain;
  get() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? "";
      final Domain = prefs.getString('domain');
    SubDomain = prefs.getString('subdomain');
    print("SubDomainSubDomain:$SubDomain");
  }
  Future<void> fetchReportData() async {
    try {
       final SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? "";
      final Domain = prefs.getString('domain');
      final SubDomain = prefs.getString('subdomain');
      
      String selectedDate = _dateController.text;
      print("Selected Date: $selectedDate");
      // // Get objectId from _getData()
      // final Map<String, String> data = await _getData();
      // final String objectId = data['Object ID'] ?? '';
      List<Map<String, dynamic>> currentSalonAppointments = salonData
          .where((appointment) => appointment['shop name'] == widget.busname)
          .toList();
      // Store the original proname value
      String? originalProname = widget.busname;

      print(originalProname);

      print("jiii");
      String url =
          //  "https://broadcastmessage.mannit.co/mannit/eSearch?domain=appointment&subdomain=category&filtercount=2&f1_field=shop name_S&f1_op=eq&f1_value=pradeep&f2_field=currentDate_S&f2_op=eq&f2_value=07/05/24";
         
         
        SubDomain=="Auto"? '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$selectedDate&f2_field=adminId_S&f2_op=eq&f2_value=$userId&f3_field=appointment_S&f3_op=eq&f3_value=dropped'
        :'$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=currentDate_S&f1_op=eq&f1_value=$selectedDate&f2_field=adminId_S&f2_op=eq&f2_value=$userId&f3_field=appointment_S&f3_op=eq&f3_value=completed';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> sources = responseBody['source'];
        print(responseBody);
        reportContainers.clear();
        for (final dynamic source in sources) {
          final Map<String, dynamic> itemData = jsonDecode(source);
          final String name = itemData['name'] ?? 'N/A';
          final String date = itemData['currentDate'] ?? 'N/A';
            final String time = itemData['currentTime'] ?? 'N/A';
              final String business = itemData['business name'] ?? 'N/A';
          reportContainers.add(
            ReportContainer(
              name: name,
              Date: date,
              time:time,
              business:SubDomain!,
             // chip:SubDomain!
            ),
          );
        }
        setState(() {}); // Trigger rebuild to reflect changes
      } else {
        throw Exception('Failed to load report data (${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching report data: $e');
    }
  }

  @override
  void initState() {
    get();
    print("reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeppppooorrrttt:${widget.busname}");
    super.initState();
    TextEditingController _dateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.busname=="Auto"?Colors.yellow:Colors.black,
        title: Text(
          "Report",
          style: TextStyle(color:  widget.busname=="Auto"?Colors.black:Colors.white,fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon:  Icon(
            Icons.arrow_back_ios,
            color: widget.busname=="Auto"?Colors.black:Colors.white
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height:10),
          Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: 100,
                width: 390,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))
                  ,color:  const Color.fromARGB(255, 229, 229, 229),),
                child: Row(
                  children: [
                  widget.busname=="Auto"?  Padding(
                      padding: const EdgeInsets.only(left:10,right:55),
                      child: Text("RIDER HISTORY",style: TextStyle(fontSize:16 , fontWeight: FontWeight.bold,),),
                    ):  Padding(
                      padding: const EdgeInsets.only(left:20,right:100),
                      child: Text("HISTORY",style: TextStyle(fontSize:16 , fontWeight: FontWeight.bold,),),
                    ),
                    Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.40,
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                    
                        onTap: () {
                          showDatePicker(
                            context: context,
                            builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                  colorScheme: ColorScheme.light(
                                                      primary: widget.busname=="Auto"?Color.fromARGB(226, 237, 214, 2):Colors.black,
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
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: "Date",
                          labelStyle: TextStyle(color: Colors.black),
                          focusColor: Colors.black,
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
              
                            borderRadius: BorderRadius.circular(20.0),
                            
                          ),
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                          // suffixIcon: IconButton(
                          //     onPressed: () {
                          //       fetchReportData();
                          //     },
                          //     icon: const Icon(
                          //       Icons.search,
                          //       color: Colors.black,
                          //     )),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 20.0),
                        ),
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                         Padding(padding: EdgeInsets.only(right: 10,))
                  ]
              
                ),
              ),
            ),
            
          ),
          SizedBox(height: 20,),
        //  const SizedBox(height: 10),
          reportContainers.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: reportContainers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return reportContainers[index];
                    },
                  ),
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top:250),
                    child: Text(
                      'No Reports available',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ),
                ),
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
