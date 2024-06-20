import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/auth/base_auth_user_provider.dart';
import 'package:mindmates/pages/menu/reporting.dart';
import 'package:share_plus/share_plus.dart';

class PostMenu extends StatefulWidget {
  final canComment;
  final docid;
  final username;
  bool isFriend;
  final userid;

  PostMenu(
      {super.key,
      required this.isFriend,
      required this.canComment,
      required this.docid,
      this.username, required this.userid});

  @override
  State<PostMenu> createState() => _PostMenuState();
}

class _PostMenuState extends State<PostMenu> {

   void notify(String? userid, String myuserid) {
    String message =
        ' started following you. Follow them back to see their posts.';
    final CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    notificationsRef.add({
      'myId': userid,
      'userid': myuserid,
      'message': message,
      'followerId': myuserid,
      'viewed': false,
      'type': 'follow',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void unnotify(String? myId, String followId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define the query to select the documents to delete
    QuerySnapshot querySnapshot = await firestore
        .collection("notifications")
        .where("myId", isEqualTo: myId)
        .where("followerId", isEqualTo: followId)
        .get();

    // Use a forEach loop to delete each matching document
    querySnapshot.docs.forEach((doc) async {
      await doc.reference.delete();
    });
  }
  @override
  Widget build(BuildContext context) {
    // bool isCommentOn = widget.canComment == true;
    return Container(
      // Customize the appearance of the bottom sheet
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text(
              'Share link',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              final String text =
                  'https:/agripert.tammeir.com/%fs%101/?user=${widget.username}%post=??';
              Share.share(text);

              // Handle option 1
              Navigator.pop(context);
            },
          ),
          widget.isFriend //FIRST HANDLE UNFOLLLOW
              ? ListTile(
                  title: const Text('Unmind',
                      style: TextStyle(
                        fontSize: 11,
                      )),
                  onTap: () {
                    void unfollowMy() async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser?.uid)
                          .update({
                        'minding':
                            FieldValue.arrayRemove([widget.userid]),
                      }).then((_) {
                        print('Unfollowed user successfully');
                      }).catchError((error) {
                        print('Error unfollowing user: $error');
                      });
                      unnotify(currentUser?.uid, widget.userid);
                    }

                    void unfollow() async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userid)
                          .update({
                        'minders': FieldValue.arrayRemove([currentUser?.uid]),
                      }).then((_) {
                        print('Unfollowed user successfully');
                      }).catchError((error) {
                        print('Error unfollowing user: $error');
                      });
                      unfollowMy();
                    }

                    unfollow();
                    // Handle unfollow
                    Navigator.pop(context);
                  },
                )
              : ListTile(
                  //NEXT HANDLE FOLLOW
                  title: const Text('Mind',
                      style: TextStyle(
                        fontSize: 11,
                      )),
                  onTap: () {
                    void followMy() async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser?.uid)
                          .update({
                        'minding':
                            FieldValue.arrayUnion([widget.userid]),
                      }).then((_) {
                        print('Followed user successfully');
                      }).catchError((error) {
                        print('Error following user: $error');
                      });
                    }

                    void follow() async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userid)
                          .update({
                        'minders': FieldValue.arrayUnion([currentUser?.uid]),
                      }).then((_) {
                        print('Followed user successfully');
                      }).catchError((error) {
                        print('Error following user: $error');
                      });
                      followMy();
                      notify(currentUser?.uid, widget.userid);
                    }

                    follow();
                    // Handle option 1
                    Navigator.pop(context);
                  },
                ),
          ListTile(
            title: const Text('Report',
                style: TextStyle(
                  fontSize: 11,
                )),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  //          Navigator.pop(
                  // context);
                  return GeneralReportingWidget(
                    reporteeId: widget.userid,
                    postId: widget.docid.id,
                    username: widget.username,
                  );
                },
              );
              // Handle option 2
            },
          ),
          // Add more ListTiles or widgets as needed
        ],
      ),
    );
  }
}
