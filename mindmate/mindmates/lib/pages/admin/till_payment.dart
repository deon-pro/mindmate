import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mindmates/components/notifications/model.dart';

class AdminPendingPaymentsPage extends StatefulWidget {
  @override
  State<AdminPendingPaymentsPage> createState() => _AdminPendingPaymentsPageState();
}

class _AdminPendingPaymentsPageState extends State<AdminPendingPaymentsPage> {
  String server = "";
  Map<String, dynamic>? userInfo;

   @override
  void initState() {
    super.initState();
    getFCMServer();
   
  }

 
  void getFCMServer() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    // await remoteConfig.
    var data = remoteConfig.getString('FCM');
    if (data.isNotEmpty) {
      // String serverToken = jsonDecode(data)["FCM"];
      setState(() {
        server = data;
      });
    } else {
     
    }
  }

    // Notif().sendFCMMessage(
    //       widget.token,
    //       '${userInfo!['fname']}  sent a photo',
    //       server,
    //       '${userInfo!['fname']} ${userInfo!['lname']}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Payments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('till_payments')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = snapshot.data!.docs;

          if (payments.isEmpty) {
            return const Center(child: Text('No pending payments found.'));
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(payment['userId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading user...'),
                    );
                  }

                  final user = userSnapshot.data!;
                  return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(payment['profId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading user...'),
                    );
                  }

                  final prof = userSnapshot.data!;
                      return ListTile(
                        title: Text('User: ${user['userName']}'),
                        subtitle: Text(
                          'Transaction ID: ${payment['transactionId']}\n'
                          'Amount: Kes. ${payment['amount']}\n'
                          'Time: ${DateFormat.yMMMd().add_jm().format(payment['timestamp'].toDate())}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showConfirmDialog(
                              context,
                              payment.id,
                              user['userName'],
                              payment['transactionId'],
                              payment['userId'],
                              payment['profId'], 
                              user['userName'],
                              user['token'],
                              prof['token'],
                            );
                          },
                          child: const Text('Confirm'),
                        ),
                      );
                    }
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Show a confirmation dialog
  void _showConfirmDialog(BuildContext context, String paymentId, String userid, String username, String transactionId, String profid,  String name, String usertoken, String proftoken) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Confirm payment for: $username'),
              Text('Transaction ID: $transactionId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _denyPayment(context, paymentId, userid, profid, name, usertoken, proftoken );
                // Navigator.pop(context);
              },
              child: const Text('Deny'),
            ),
            ElevatedButton(
              onPressed: () {
                _confirmPayment(context, paymentId, userid, profid, name, usertoken, proftoken );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Confirm the payment and update Firestore
  Future<void> _confirmPayment(BuildContext context, String paymentId, String userid, String profid, String name, String usertoken, String proftoken) async {
    try {
      // Update payment status in Firestore
      await FirebaseFirestore.instance.collection('till_payments').doc(paymentId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to the user
      await _sendNotificationToUser(userid, profid);
      NotifModel().sendFCMMessagePayment(
          usertoken,
          'Payment Confirmed',
          server,
          'Mindmate');

           NotifModel().sendFCMMessagePayment(
          proftoken,
          '$name made a payment via till',
          server,
          'Mindmate');



      // Close the dialog and show success
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment confirmed successfully')),
      );
    } catch (e) {
      print('Error confirming payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error confirming payment')),
      );
    }
  }

  // Send notification to the user after confirming the payment
  Future<void> _sendNotificationToUser(String userid, String profid) async {
    // Fetch the user's FCM token from Firestore (assuming username is unique or you use userId)
   String message =
        'Your payment request has been verified.';
    final CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    notificationsRef.add({
      'myId': userid,
      'userid': 'admin',
      'message': message,
      'followerId': profid,
      'viewed': false,
      'type': 'pay',
      'id': '',
      'reason': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

      notificationsRef.add({
      'myId': profid,
      'userid': 'admin',
      'message': message,
      'followerId': userid,
      'viewed': false,
      'type': 'pay',
      'id': '',
      'reason': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
    }


    // Confirm the payment and update Firestore
  Future<void> _denyPayment(BuildContext context, String paymentId, String userid, String profid, String name, String usertoken, String proftoken) async {
    try {
      // Update payment status in Firestore
      await FirebaseFirestore.instance.collection('till_payments').doc(paymentId).update({
        'status': 'denied',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to the user
      await _sendNotificationXToUser(userid, profid);
      NotifModel().sendFCMMessage(
          usertoken,
          'Payment Denied',
          server,
          'Mindmate');

          


      // Close the dialog and show success
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment denied')),
      );
    } catch (e) {
      print('Error confirming payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error confirming payment')),
      );
    }
  }

  // Send notification to the user after confirming the payment
  Future<void> _sendNotificationXToUser(String userid, String profid) async {
    // Fetch the user's FCM token from Firestore (assuming username is unique or you use userId)
   String message =
        'Your payment request has been denied.';
    final CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    notificationsRef.add({
      'myId': userid,
      'userid': profid,
      'message': message,
      'followerId': profid,
      'viewed': false,
      'type': 'pay',
      'id': '',
      'reason': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    }
  }

