
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubmitPostReport extends StatelessWidget {
  final reason;
  final reporteeId;
  final postId;
  const SubmitPostReport(
      {super.key, this.reason, this.reporteeId, this.postId});

       void notify(String userid) {
    String message =
        'Your report regarding this post under $reason has been received, our team is working to look into the matter. Please note that your identity is never revealed to the other user.';
    final CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    notificationsRef.add({
      'myId': 'admin',
      'userid': userid,
      'message': message,
      'followerId': '',
      'viewed': false,
      'type': 'report',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAc = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .7,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Report as $reason?',
                      style: const TextStyle(
                          fontSize: 26,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .9,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                      'By submitting a resport to us we ensure that your identity is kept confidential and the other doesn\'t get to know.',
                      style: TextStyle(
                        // fontSize: 26,
                        letterSpacing: 2,
                        // fontWeight: FontWeight.w500,
                        wordSpacing: 3,
                      )),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * .6,
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () async {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference messagesRef =
                        firestore.collection('reports');
                    final userId = userAc?.uid;

                    try {
                      DocumentReference documentRef = await messagesRef.add({
                        'complaintId': userId,
                        'reporteeId': reporteeId,
                        'reason': reason,
                        'postId': postId, // 'text' or 'image'
                        // 'content': imageUrl, // Image URL
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      await documentRef.update({'id': documentRef.id});
                       notify(userId!);
                    } catch (e) {
                      // Handle any errors that occur during image upload
                      print('Error uploading images: $e');
                    }
                  },
                  child: const Text('Submit report')),
            ),
          ],
        ),
      ),
    );
  }
}
