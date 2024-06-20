import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Map_Url extends StatelessWidget {
  
  final List<Map<String, double>> locations = [
    {'latitude': 10.8505, 'longitude': 76.2711}, // Kerala
    {'latitude': 13.0827, 'longitude': 80.2707}, // Chennai
    {'latitude': 12.9611, 'longitude': 80.2097}, // Madipakkam
    {'latitude': 13.0083, 'longitude': 80.2128}, // Guindy
    {'latitude': 12.8694, 'longitude': 79.6997}, // Poonamallee
    {'latitude': 12.9185, 'longitude': 80.1239}, // Medavakkam
  ];

  void _launchMap() async {
    for (var location in locations) {
      double latitude = location['latitude']!;
      double longitude = location['longitude']!;
      String mapUrl = 'https://www.google.com/maps?q=$latitude,$longitude';
      if (Platform.isAndroid) {
        await launch(mapUrl, forceSafariVC: false);
      } else {
        await launch(mapUrl, universalLinksOnly: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchMap,
          child: Text('Open All Locations on Map'),
        ),
      ),
    );
  }
}
