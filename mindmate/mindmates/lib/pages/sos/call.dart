import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Helpline Numbers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CallPage(),
    );
  }
}

class CallPage extends StatelessWidget {
  final emergencyNumbers = [
    {'title': 'Kenya Red Cross Counseling', 'number': '1199'},
    {'title': 'NACADA for Substance Abuse Counselling', 'number': '1192'},
    {'title': 'Healthcare Assistance Kenya (HAK)', 'number': '1195'},
    {'title': 'Gender Violence Recovery Centre (GVRC)', 'number': '0800720565'},
    {'title': 'Coalition on Violence Against Women (COVAW)', 'number': '0800720553'},
    {'title': 'Befrienders Kenya', 'number': '+254 722 178 177'},
    {'title': 'Basic Needs Watch', 'number': '0800723253'},
    {'title': 'Gender Based Violence', 'number': '21094'},
    {'title': 'Gender Based Violence For Men', 'number': '1195'},
    {'title': 'LVCT For General Counselling Services', 'number': '1190'},
    {'title': 'Child Help Line', 'number': '116'},
    {'title': 'Police', 'number': '911'},
    {'title': 'Health Care Worker Counselling Help Line', 'number': '0800720608'},
    {'title': 'Persons With Disability', 'number': '21094'},
    {'title': 'Nairobi Metropolitan Services (NMS) Emergency Operating Centre For Free Ambulances', 'number': '0800720541'}
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Helpline Numbers', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.blue],
          ),
        ),
        child: ListView.builder(
          itemCount: emergencyNumbers.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(emergencyNumbers[index]['title']!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                subtitle: Text(emergencyNumbers[index]['number']!,
                    style: TextStyle(color: Colors.black)),
                leading: Icon(Icons.call, color: Colors.deepPurple),
                onTap: () => _makePhoneCall(emergencyNumbers[index]['number']!),
              ),
            );
          },
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    if (await canLaunch('tel:$phoneNumber')) {
      await launch('tel:$phoneNumber');
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
}
