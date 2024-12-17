import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindmates/auth/firebase_auth/auth_util.dart';
import 'package:mindmates/pages/public_profile/public_profile.dart';

import '../flutter_flow/flutter_flow_theme.dart';

class MindmateSearchBar extends StatefulWidget {
  @override
  _MindmateSearchBarState createState() => _MindmateSearchBarState();
}

class _MindmateSearchBarState extends State<MindmateSearchBar> {
  late TextEditingController _searchController;
  final userAc = FirebaseAuth.instance.currentUser;
  List<String> followingUserIds =
      []; // Track the user IDs being followed by the current user

  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchFollowingUserIds();
    _searchController = TextEditingController();
  }

  void notify(String userid, String myuserid) {
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
      'id': '',
      'reason': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void unnotify(String myId, String followId) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchText = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search MindMate',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
      body: Container(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('Mindmates.'),
              );
            }
            if (snapshot.error != null) {
              return const Center(
                child: Text('Error loading users...'),
              );
            }
            List<QueryUser> allQueryUsers = snapshot.data!.docs.map((doc) {
              return QueryUser(
                username: doc['userName'],
                profile: doc['photo_url'],
                userid: doc['uid'],
              );
            }).toList();

            // Filter users based on search text
            List<QueryUser> filteredUsers = allQueryUsers.where((user) {
              return user.username.toLowerCase().contains(searchText);
            }).toList();

            return ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var isFollowingBack =
                    followingUserIds.contains(filteredUsers[index].userid);

                return filteredUsers[index].userid == userAc!.uid
                    ? Container()
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('mental_health_professionals')
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
                              child: Text('Error loading data...'),
                            );
                          }
                          final userdata = snapshot.data!.docs;
                          // bool isUsernameTaken = false;

                          final existingUser = Set<String>.from(userdata.map(
                            (doc) => (doc.data() as Map<String, dynamic>)['id']
                                .toString(),
                          ));
                          bool isProfessional = existingUser
                              .contains(filteredUsers[index].userid);

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PublicProfile(
                                  userid: filteredUsers[index].userid,
                                  isProfessional: isProfessional,
                                ),
                              ));
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                foregroundImage: filteredUsers[index].profile !=
                                        ''
                                    ? NetworkImage(filteredUsers[index].profile)
                                    : null,
                                child: const Icon(Icons.person),
                              ),
                              title: Row(
                                children: [
                                  Text(filteredUsers[index].username),
                                  isProfessional
                                      ? Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  6.0, 0.0, 0.0, 0.0),
                                          child: Icon(
                                            Icons.verified,
                                            color: Color(0xFF12CCEE),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (isFollowingBack) {
                                      unfollow(filteredUsers[index].userid);
                                      followingUserIds
                                          .remove(filteredUsers[index].userid);
                                    } else {
                                      follow(filteredUsers[index].userid);
                                      followingUserIds
                                          .add(filteredUsers[index].userid);
                                    }
                                  });
                                },
                                child: Text(
                                  isFollowingBack ? 'Unmind' : 'Mind',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
              },
            );
          },
        ),
      ),
    );
  }

  void unfollow(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userAc?.uid)
        .update({
      'minding': FieldValue.arrayRemove([userId]),
    }).then((value) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'minders': FieldValue.arrayRemove([currentUserUid]),
      });
      unnotify(currentUserUid, userId);
    }).catchError((error) {
      print('Error unminding user: $error');
    });
  }

  void follow(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userAc?.uid)
        .update({
      'minding': FieldValue.arrayUnion([userId]),
    }).then((value) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'minders': FieldValue.arrayUnion([currentUserUid]),
      });
      notify(currentUserUid, userId);
    }).catchError((error) {
      print('Error minding user: $error');
    });
  }
}

class QueryUser {
  final String username;
  final String profile;
  final String userid;

  QueryUser({
    required this.username,
    required this.profile,
    required this.userid,
  });
}

Future<void> unfollow(String userId) async {
  final userAc = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance.collection('users').doc(userAc?.uid).update({
    'minding': FieldValue.arrayRemove([userId]),
  }).catchError((error) {
    print('Error unminding user: $error');
  });
}

Future<void> follow(String userId) async {
  final userAc = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance.collection('users').doc(userAc?.uid).update({
    'minding': FieldValue.arrayUnion([userId]),
  }).catchError((error) {
    print('Error minding user: $error');
  });
}
