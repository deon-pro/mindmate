import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  final String phoneNumber = '0800723253'; // Phone number to call

  _launchPhone() async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HELP',
          style: TextStyle(
            color: Colors.red, // Change app bar text color to red
            fontWeight: FontWeight.bold, // Make app bar text bold
          ),
        ),
        centerTitle: true, // Center the app bar title
        backgroundColor: Colors.black, // Change app bar background color to black
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/help.jpg'), // Add your image path here
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _launchPhone,
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // Change button color to black
                ),
                child: Text(
                  'Call 0800 723 253',
                  style: TextStyle(
                    color: Colors.red, // Change text color to red
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
