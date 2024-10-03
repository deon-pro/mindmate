import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assuming you're using Firestore

class ConfirmationPage extends StatefulWidget {
  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final TextEditingController _codeController = TextEditingController();
  String _status = '';
  String _transactionId = '';
  String _amount = '';
  String _comment = '';
  IconData _statusIcon =
      Icons.error_outline; // Default icon for non-existent code
  Color _statusColor = Colors.grey; // Default color

  void _checkCode() async {
    String code = _codeController.text.trim();

    // Fetch from Firestore where transactionId is equal to the entered code
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('till_payments')
        .where('transactionId', isEqualTo: code)
        .where('profId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document that matches
      DocumentSnapshot doc = querySnapshot.docs.first;

      // Cast the data to a Map
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Fetch the necessary fields
      String status = data['status'];
      String transactionId = data['transactionId'];
      String amount = data['amount'].toString();
      String comment = ''; // Add your logic for the comment
      // Determine status and associated details
      if (status == 'confirmed') {
        setState(() {
          _statusIcon = Icons.check_circle_outline;
          _statusColor = Colors.green;
          comment = 'Transaction success';
        });
      } else if (status == 'pending') {
        setState(() {
          _statusIcon = Icons.hourglass_empty;
          _statusColor = Colors.orange;
          comment = 'Transaction pending';
        });
      } else if (status == 'denied') {
        setState(() {
          _statusIcon = Icons.cancel_outlined;
          _statusColor = Colors.red;
          comment = 'Transaction denied';
        });
      }

      // Update state with fetched data
      setState(() {
        _status = status;
        _transactionId = transactionId;
        _amount = amount;
        _comment = comment;
      });

      _showBottomSheet(); // Show the result in the bottom sheet
    } else {
      // If the code does not exist
      setState(() {
        _statusIcon = Icons.error_outline;
        _statusColor = Colors.grey;
        _status = 'Not Exist';
        _comment = 'Transaction code does not exist';
      });
      _showBottomSheet();
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(
                    _statusIcon,
                    color: _statusColor,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
              if (_status != 'Not Exist') ...[
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Transaction ID: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_transactionId),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Amount: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Kes. $_amount'),
                  ],
                ),
              ],
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Comment: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_comment),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Payment'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Confirmation Code:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter code here',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkCode,
              child: Text('Check'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
