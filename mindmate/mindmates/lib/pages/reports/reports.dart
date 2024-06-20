import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int totalExperts = 0;
  double totalPayments = 0.0;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    fetchTotalExperts();
    fetchTotalPayments();
    getCurrentUser();
  }

  Future<void> fetchTotalExperts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('mental_health_professionals').get();
    setState(() {
      totalExperts = querySnapshot.docs.length;
    });
  }

  Future<void> fetchTotalPayments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('paid').get();
    double sum = 0.0;

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?; // Type-casting the data
      if (data != null && data.containsKey('totalAmount')) {
        var amount = data['totalAmount'];
        if (amount is double) {
          sum += amount;
        } else if (amount is int) {
          sum += amount.toDouble();
        } else {
          print('Unexpected type for totalAmount: ${amount.runtimeType}');
        }
      }
    }
    print('Calculated total payments: $sum');
    setState(() {
      totalPayments = sum;
    });
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mental Health Report'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentUser!.email != 'deniskyalo28@gmail.com') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mental Health Report'),
        ),
        body: Center(
          child: Text('You do not have permission to view this report.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Report'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue,
              child: ListTile(
                leading: Icon(Icons.people, color: Colors.white),
                title: Text('Total Experts', style: TextStyle(color: Colors.white)),
                subtitle: Text('$totalExperts', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              color: Colors.orange,
              child: ListTile(
                leading: Icon(Icons.pie_chart, color: Colors.white),
                title: Text('Patient Distribution', style: TextStyle(color: Colors.white)),
                subtitle: Text('Male: 44%, Female: 56%', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              color: Colors.green,
              child: ListTile(
                leading: Icon(Icons.attach_money, color: Colors.white),
                title: Text('Total Payments', style: TextStyle(color: Colors.white)),
                subtitle: Text('\$${totalPayments.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
