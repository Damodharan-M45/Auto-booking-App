import 'package:flutter/material.dart';

class NotificationHandler extends StatelessWidget {
  final String notificationMessage;

  const NotificationHandler({Key? key, required this.notificationMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(notificationMessage),
            ElevatedButton(
              onPressed: () {
                // Perform action when "OK" button is pressed
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
