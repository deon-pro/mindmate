import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/public_profile/public_profile.dart';

import '../../auth/firebase_auth/auth_util.dart';

class NotificationPage extends StatefulWidget {

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
   final userAc = FirebaseAuth.instance.currentUser;

  List<String> followingUserIds =
      []; 
 // Track the user IDs being followed by the current user
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchFollowingUserIds(); // Fetch the list of user IDs being followed
  }

  void fetchFollowingUserIds() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userAc?.uid)
        .get();

    final followingList = userSnapshot.get('minding') as List<dynamic>?;
    if (followingList != null) {
      setState(() {
        followingUserIds = List<String>.from(followingList);
      });
    }
  }

  Future<String?> getSenderUsername(String senderID) async {
    try {
      DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderID)
          .get();

      if (senderSnapshot.exists && senderSnapshot.data() != null) {
        return senderSnapshot['userName'];
      }
    } catch (error) {
      print('Error fetching sender username: $error');
    }
    return null;
  }

  Future<String?> getSenderProfileImage(String senderID) async {
    try {
      // Query the users collection for the sender's data
      if (senderID == 'admin') {
        return null;
      } else {
        DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderID)
            .get();

        // Check if sender exists and has a profile image URL
        if (senderSnapshot.exists && senderSnapshot.data() != null) {
          return senderSnapshot['photo_url'];
          //     String profileImageUrl = senderSnapshot['photo_url'];
          // String username = senderSnapshot['username'];
          // return {'photo_url': profileImageUrl, 'username': username};
        }
      }
    } catch (error) {
      print('Error fetching sender data: $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        title: Text('Notification'),
      ),
      body: Container(
        // color: Colors.black, // Set background color to black
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('userid', isEqualTo: currentUser?.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No notifications yet.'));
          }
          final notificationDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notificationDocs.length,
            itemBuilder: (context, index) {
              final notification =
                  notificationDocs[index].data() as Map<String, dynamic>;

              final senderID = notification['myId'] as String?;
                final isFollowingBack = followingUserIds
                                .contains(notification['myId']);


              String formatTimeDifference(DateTime dateTime) {
                final now = DateTime.now();
                final difference = now.difference(dateTime);

                if (difference.inSeconds < 60) {
                  return '${difference.inSeconds}s';
                } else if (difference.inMinutes < 60) {
                  return '${difference.inMinutes}m';
                } else if (difference.inHours < 24) {
                  return '${difference.inHours}h';
                } else if (difference.inDays < 7) {
                  return '${difference.inDays}d';
                } else if (difference.inDays < 30) {
                  return '${(difference.inDays / 7).floor()}w';
                } else if (difference.inDays < 365) {
                  return '${(difference.inDays / 30).floor()}mo';
                } else {
                  return '${(difference.inDays / 365).floor()}y';
                }
              }

              return StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection(
                                                  'mental_health_professionals')
                                              // .where('isUser', isEqualTo: true)
                                              // .where('userid', isEqualTo: userid)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.data!.docs.isEmpty) {
                                              return const Center();
                                            }
                                            if (snapshot.error != null) {
                                              return const Center(
                                                child: Text(
                                                    'Error loading data...'),
                                              );
                                            }
                                            final userdata =
                                                snapshot.data!.docs;
                                            // bool isUsernameTaken = false;

                                            final existingUser =
                                                Set<String>.from(userdata.map(
                                              (doc) => (doc.data() as Map<
                                                      String,
                                                      dynamic>)['id']
                                                  .toString()
                                                  ,
                                            ));
                                            bool isProfessional =
                                                existingUser.contains(notification['myId']);

                  return GestureDetector(
                    onTap: () async {
                      notification['type'] == 'follow'
                          ? Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PublicProfile(
                                    userid: notification['myId'] ,
                                    isProfessional: isProfessional,
                                  )))
                          : null;
                    },
                    child: ListTile(
                      leading: FutureBuilder<String?>(
                        future: senderID != null
                            ? getSenderProfileImage(senderID)
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircleAvatar(child: CircularProgressIndicator());
                          } else if (snapshot.hasError || snapshot.data == null) {
                            return senderID == 'admin'
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/minds.png'),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.person),
                                  );
                          } else {
                            return CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data!),
                            );
                          }
                        },
                      ),
                      title: FutureBuilder<String?>(
                        future: notification['type'] == 'follow'
                            ? getSenderUsername(senderID!)
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text('...');
                          } else if (snapshot.hasError || snapshot.data == null) {
                            return Text(
                              notification['message'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: FlutterFlowTheme.of(context).mineIcon,
                              ),
                            );
                          } else {
                            final senderUsername = snapshot.data!;
                            final message = notification['message'] as String;
                            return RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: FlutterFlowTheme.of(context).mineIcon,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$senderUsername ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: message,
                                    style: TextStyle(
                                        // fontSize: 12,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      subtitle: Text(
                        formatTimeDifference(notification['timestamp'].toDate()),
                        style: TextStyle(
                          fontSize: 10,
                          color: FlutterFlowTheme.of(context).time,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: notification['type'] == 'follow'? isFollowingBack
                                          ? null
                                          :ElevatedButton(
                                                onPressed: () {
                                                  void followMy() async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(userAc?.uid)
                                                        .update({
                                                      'minding':
                                                          FieldValue.arrayUnion([
                                                        notification['myId']
                                                      ]),
                                                    }).then((_) {
                                                      print(
                                                          'Minded user successfully');
                                                    }).catchError((error) {
                                                      print(
                                                          'Error minding user: $error');
                                                    });
                                                  }
                            
                                                  void follow() async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(notification['myId'])
                                                        .update({
                                                      'minders':
                                                          FieldValue.arrayUnion(
                                                              [userAc?.uid]),
                                                    }).then((_) {
                                                      print(
                                                          'Minded user successfully');
                                                    }).catchError((error) {
                                                      print(
                                                          'Error minding user: $error');
                                                    });
                                                    followMy();
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              NotificationPage()),
                                                    );
                                                  }
                            
                                                  follow();
                                                },
                                                child: const Text(
                                                  'Mind',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ):null,
                    ),
                  );
                }
              );
            },
          );
        },
      ),
    ),
    );

  }
}
