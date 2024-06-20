import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/auth/firebase_auth/auth_util.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/messaging/add_admins_list.dart';
import 'package:mindmates/pages/messaging/single_chat_widget.dart';
import 'package:rxdart/rxdart.dart';

class GroupAdmins extends StatefulWidget {
  final groupId;
  const GroupAdmins({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupAdmins> createState() => GroupAdminsState();
}

class GroupAdminsState extends State<GroupAdmins> {
  // final TextEditingController _nameController = TextEditingController();
  String? _profilePhotoUrl;
  File? image;
  bool isUploading = false;
  final _formKey = GlobalKey<FormState>();
  void wrongMsg(user) {
    final snackBar = SnackBar(
      content: Text('Cannot dismiss user $user as they created the group.'),
      duration: const Duration(seconds: 3),
      backgroundColor: FlutterFlowTheme.of(context).primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primary),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(25, 40, 25, 4),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).accent1,
                    ),
                  )),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                color: Theme.of(context).dividerColor,
                height: 0.8,
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => CreateAdminWidget(
                          groupId: widget.groupId,
                        )))),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text(
                        'Add admins',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      )),
                      Container(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: FlutterFlowTheme.of(context).accent1,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 0, 25, 20),
                color: Theme.of(context).dividerColor,
                height: 0.8,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 20, 25, 4),
                color: Theme.of(context).dividerColor,
                height: 0.8,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                color: Theme.of(context).dividerColor,
                height: 0.8,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  'Group admins',
                  style: TextStyle(
                    fontSize: 14,
                    color: FlutterFlowTheme.of(context).accent1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chatsGroup')
                      .where('id', isEqualTo: widget.groupId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        child: const Text('..'),
                      );
                    }
                    if (snapshot.error != null) {
                      return const Center(
                        child: Text('Error loading data...'),
                      );
                    }

                    final groupData = snapshot.data!.docs.first;
                    final groupInfo = groupData.data() as Map<String,
                        dynamic>; // Explicitly cast to the correct type
                    final superAdmin = groupInfo['superAdmin'];

                    final userData = snapshot.data!.docs;
                    final people = userData.isNotEmpty
                        ? List<String>.from(userData.first['groupAdmins'])
                        : [];

                    final List<Stream<QuerySnapshot>> queryStreams = [];
                    const int batchSize = 10;

                    for (int i = 0; i < people.length; i += batchSize) {
                      final batchIds = people.skip(i).take(batchSize).toList();
                      final queryStream = FirebaseFirestore.instance
                          .collection('users')
                          .where('uid', whereIn: batchIds)
                          .snapshots();

                      queryStreams.add(queryStream);
                      print(batchIds);
                    }

                    return StreamBuilder<List<QuerySnapshot>>(
                        stream: CombineLatestStream.list(queryStreams),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container();
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }
                          if (snapshot.error != null) {
                            return const Center(
                              child: Text('Error loading.'),
                            );
                          }

                          final List<Members> listOfMembers = snapshot.data!
                              .expand((querySnapshot) {
                                return querySnapshot.docs.map((doc) {
                                  return Members(
                                    username: doc['userName'],
                                    profile: doc['photo_url'],
                                    userid: doc['uid'], token:  doc['token'],
                                  );
                                });
                              })
                              .cast<Members>()
                              .toList();
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listOfMembers.length,
                            itemBuilder: (BuildContext context, int index) {
                              String username = listOfMembers[index].username;
                              String userPhoto = listOfMembers[index].profile;
                              String userid = listOfMembers[index].userid;
                              String fcmtoken = listOfMembers[index].token;
                              return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('mental_health_professionals')
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

                                    final existingUser =
                                        Set<String>.from(userdata.map(
                                      (doc) => (doc.data()
                                              as Map<String, dynamic>)['id']
                                          .toString(),
                                    ));
                                    bool isProfessional = existingUser
                                        .contains(listOfMembers[index].userid);
                                    return Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 10),
                                      child: ListTile(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Center(
                                                  child: Text(
                                                    'Direct messaging',
                                                    style: TextStyle(
                                                        // fontStyle: FontStyle.italic
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SingleChatWidget(
                                                                          receiverId:
                                                                              userid,
                                                                          userImage:
                                                                              userPhoto,
                                                                          username:
                                                                              username,
                                                                          professional:
                                                                              isProfessional, token: fcmtoken,
                                                                        )));
                                                      },
                                                      title: Text(
                                                        'Message user ${username}',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      onTap: () async {
                                                        if (userid !=
                                                            superAdmin) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'chatsGroup')
                                                              .doc(widget
                                                                  .groupId)
                                                              .update({
                                                            'groupAdmins':
                                                                FieldValue
                                                                    .arrayRemove([
                                                              userid
                                                            ]),
                                                          }).then((_) async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'chatsGroup')
                                                                .doc(widget
                                                                    .groupId)
                                                                .update({
                                                              'lastmessage':
                                                                  '$currentUserName dismissed user $username as admin',
                                                            }).then((_) {
                                                              Navigator.pop(
                                                                  context);
                                                            }).catchError(
                                                                    (error) {
                                                              print(
                                                                  'Error r: $error');
                                                            });
                                                          }).catchError(
                                                                  (error) {
                                                            print(
                                                                'Error f: $error');
                                                          });
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                          wrongMsg(username);
                                                        }
                                                      },
                                                      title: Text(
                                                        'Dismiss admin ${username}',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        leading: CircleAvatar(
                                          radius: 25,
                                          foregroundImage: userPhoto.isNotEmpty
                                              ? NetworkImage(userPhoto)
                                              : null,
                                          child: const Icon(Icons.person),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(username),
                                            isProfessional
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10.0,
                                                            0.0,
                                                            0.0,
                                                            0.0),
                                                    child: Icon(
                                                      Icons.verified,
                                                      color: Color(0xFF12CCEE),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          );
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class Members {
  String username;
  String profile;
  String userid;
  String token;

  Members({
    required this.username,
    required this.profile,
    required this.userid,
     required this.token,
  });
}
