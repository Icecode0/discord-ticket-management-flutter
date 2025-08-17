import 'package:flutter/material.dart';

Widget economyPage(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Economy Overview',
        style: TextStyle(
          fontFamily: 'Anton',
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.teal,
    ),
    body: Container(
      color: Colors.grey[900], // Dark background for a stylized look
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 100,
              color: Colors.tealAccent,
            ),
            SizedBox(height: 20),
            Text(
              'Economy Overview',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
                fontFamily: 'Anton',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
            ),
          ],
        ),
      ),
    ),
  );
}
