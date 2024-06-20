import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mindmates/pages/sos/contact.dart';
import 'package:mindmates/pages/sos/calm.dart';
import 'package:mindmates/pages/sos/message.dart';
import 'package:mindmates/pages/sos/copy.dart';
import 'package:mindmates/pages/sos/call.dart';
import 'package:mindmates/pages/sos/stresstest.dart';
// ignore: unused_import
import 'package:mindmates/pages/sos/review.dart';





class SosButtonPage extends StatelessWidget {
  final Location location = Location();

  Future<void> _requestLocationPermission(BuildContext context) async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    _shareLocation(context);
  }

  Future<void> _shareLocation(BuildContext context) async {
    LocationData currentLocation = await location.getLocation();
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${currentLocation.latitude},${currentLocation.longitude}';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print('Error opening Google Maps URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 75, 57, 239),
      appBar: AppBar(
        title: Text('SOS Button'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'If you need immediate help, click the SOS button below:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactPage()),
                  );
                },
                child: Text(
                  'SOS',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Remember, you are not alone. Reach out for help.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CallPage()),
                  );
                },
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('Immediate Contact Information'),
                subtitle: Text('Crisis helpline, mental health professional, or support person'),
              ),
          ),
          
           GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>MentalHealthGame()),
                  );
                },
                
             child: ListTile(
  leading: Icon(Icons.lightbulb),
  title: Text('Mental Health Assessment Challenge'),
  subtitle: Text('Play our interactive game to assess your mental well-being'),
),
          ),

               GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SafetyDartPage()),
                  );
                },
             child: ListTile(
                leading: Icon(Icons.check),
                title: Text('Crisis Plan'),
                subtitle: Text('Step-by-step guide for coping strategies'),
              ),
          ),
              
               GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MentalHealthPage()),
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text('Calm Down Techniques'),
                  subtitle: Text('Guided meditation, breathing exercises, soothing imagery'),
                ),
              ),
              
              GestureDetector(
  onTap: () {
    
  
    launch('https://www.jigsawplanet.com/');
  },
  child: ListTile(
    leading: Icon(Icons.gamepad),
    title: Text('Distraction Activities'),
    subtitle: Text('Puzzles, games, coloring exercises'),
  ),
),

              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Location Sharing'),
                subtitle: Text('Option to share location with trusted contacts or services'),
                onTap: () {
                  _requestLocationPermission(context);
                },
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MentalHealthSupportScreen()),
                  );
                },
             child: ListTile(
                leading: Icon(Icons.sentiment_satisfied),
                title: Text('Encouraging Messages'),
                subtitle: Text('Display positive and supportive messages'),
              ),
          ),
              
            ],
          ),
        ),
      ),
    );
  }
}

