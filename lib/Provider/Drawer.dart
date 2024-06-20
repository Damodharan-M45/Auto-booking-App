import 'dart:convert';
import 'package:appointments/property/utlis.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyDrawer extends StatefulWidget {
  MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool _isLoading = true;

  String? userId;
  String? Domain;
  String? SubDomain;
  String? resourceId;
  List<Map<String, dynamic>> events =
      []; // Replace this with your actual list of events
  List<String> eventIds = []; // Add this line
  List<Map<String, dynamic>> eventslist = [];
  String profileName = "";
  String? category;
  String? state;
  String? profileurl;
  String? partyId;
  String? mobileno;
  String? postalcode;
  String? Role;
  String? profileOid;
  String? clientRole;
  String? address;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
            decoration: const BoxDecoration(),
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  // name,
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                const Text(
                  "",
                  //  '$category - $state',
                  style: TextStyle(
                    fontSize: 16,
                    color: Background_colour,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Your existing drawer items
                ListTile(
                  leading: const Icon(
                    Icons.home,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Home",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_search_rounded,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Search Members",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.where_to_vote_outlined,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Search By Booth",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.add,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Add Booth",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Add Member",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(
                    Icons.list_rounded,
                    size: 26,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "User List",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),
                // SizedBox(
                //   height: 5,
                // ),
                ListTile(
                  leading: const Icon(
                    Icons.location_history_outlined,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Agent List",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: const Text(
                    "Log Out",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  onTap: () async {},
                ),
              ],
            )));
  }
}
