import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/messaging/single_chat_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class GroupInfoViewOnly extends StatefulWidget {
  final groupId;
  final isAdmin;
  const GroupInfoViewOnly({
    super.key,
    required this.groupId,
    this.isAdmin,
  });

  @override
  State<GroupInfoViewOnly> createState() => GroupInfoViewOnlyState();
}

class GroupInfoViewOnlyState extends State<GroupInfoViewOnly> {
  // final TextEditingController _nameController = TextEditingController();
  String? _profilePhotoUrl;
  File? image;
  bool isUploading = false;
  final _formKey = GlobalKey<FormState>();
  String searchText = '';

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      _selectImage();
    }
  }

  void wrongMsg(user) {
    final snackBar = SnackBar(
      content: Text('Cannot remove user $user as they created the group.'),
      duration: const Duration(seconds: 3),
      backgroundColor: FlutterFlowTheme.of(context).primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if (image == null) {
      return;
    }
    setState(() {
      isUploading = true;
    });

    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('group_profile/${DateTime.now().toString()}');
    final uploadTask = storageRef.putFile(image!);

    await uploadTask.whenComplete(() async {
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _profilePhotoUrl = downloadUrl;
        isUploading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatsGroup')
            .where('id', isEqualTo: widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container();
          }
          if (snapshot.error != null) {
            return const Center(
              child: Text('Error loading bio.'),
            );
          }

          final groupdata = snapshot.data!.docs.first;
          final groupInfo = groupdata.data();
          final profile = groupInfo['profile'];

          final TextEditingController groupname =
              TextEditingController(text: groupInfo['groupname']);
          final TextEditingController groupdesc =
              TextEditingController(text: groupInfo['description']);

          return Scaffold(
            appBar: AppBar(
              iconTheme:
                  IconThemeData(color: FlutterFlowTheme.of(context).primary),
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                      child: GestureDetector(
                        child: CircleAvatar(
                          radius: 50,
                          foregroundImage: profile != null
                              ? NetworkImage(profile)
                              : null as ImageProvider<Object>?,
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                      child: TextFormField(
                        readOnly: true,
                        // border:
                        controller: groupname,
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).accent1,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Group name:',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Add group name...',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a name!!';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                      child: TextFormField(
                        readOnly: true,
                        maxLines: 3,
                        minLines: 1,
                        // border:
                        controller: groupdesc,
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).accent1,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintText: 'Add group description...',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      color: Theme.of(context).dividerColor,
                      height: 0.8,
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 14,
                          color: FlutterFlowTheme.of(context).accent1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 15),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value
                                .toLowerCase(); // Update the searchText on text changes
                          });
                        },
                        // style: TextStyle(
                        //   fontSize: 14,
                        //   color: FlutterFlowTheme.of(context).accent1,
                        //   fontWeight: FontWeight.bold,
                        // ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chatsGroup')
                            .where('id', isEqualTo: widget.groupId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Container(
                              child: const Text('..'),
                            );
                          }
                          if (snapshot.error != null) {
                            return const Center(
                              child: Text('Error loading data...'),
                            );
                          }

                          final userData = snapshot.data!.docs;
                          final people = userData.isNotEmpty
                              ? List<String>.from(userData.first['users'])
                              : [];

                          final List<Stream<QuerySnapshot>> queryStreams = [];
                          const int batchSize = 10;

                          for (int i = 0; i < people.length; i += batchSize) {
                            final batchIds =
                                people.skip(i).take(batchSize).toList();
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
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
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

                                final List<Members> listOfMember =
                                    snapshot.data!
                                        .expand((querySnapshot) {
                                          return querySnapshot.docs.map((doc) {
                                            return Members(
                                              username: doc['userName'],
                                              profile: doc['photo_url'],
                                              userid: doc['uid'],
                                              token: doc['token'],
                                            );
                                          });
                                        })
                                        .cast<Members>()
                                        .toList();

                                // Filter followers based on search text
                                final List<Members> listOfMembers =
                                    listOfMember.where((follower) {
                                  final username =
                                      follower.username.toLowerCase();
                                  final searchQuery = searchText.toLowerCase();
                                  return username.contains(searchQuery);
                                }).toList();

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: listOfMembers.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String username =
                                        listOfMembers[index].username;
                                    String userid = listOfMembers[index].userid;
                                    String fcmtoken = listOfMembers[index].token;
                                    String userPhoto =
                                        listOfMembers[index].profile;
                                    return StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'mental_health_professionals')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Center();
                                          }
                                          if (snapshot.error != null) {
                                            return const Center(
                                              child:
                                                  Text('Error loading data...'),
                                            );
                                          }
                                          final userdata = snapshot.data!.docs;
                                          // bool isUsernameTaken = false;

                                          final existingUser =
                                              Set<String>.from(userdata.map(
                                            (doc) => (doc.data() as Map<String,
                                                    dynamic>)['id']
                                                .toString(),
                                          ));
                                          bool isProfessional =
                                              existingUser.contains(
                                                  listOfMembers[index].userid);

                                          return Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 10),
                                            child: ListTile(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Center(
                                                        child: Text(
                                                          'Direct messaging',
                                                          style: TextStyle(
                                                              // fontStyle: FontStyle.italic
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                                      builder: (context) =>
                                                                          SingleChatWidget(
                                                                            token: fcmtoken,
                                                                            receiverId:
                                                                                userid,
                                                                            userImage:
                                                                                userPhoto,
                                                                            username:
                                                                                username,
                                                                            professional:
                                                                                isProfessional,
                                                                          )));
                                                            },
                                                            title: Text(
                                                              'Message user ${username}',
                                                              style: TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
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
                                                foregroundImage: userPhoto
                                                        .isNotEmpty
                                                    ? NetworkImage(userPhoto)
                                                    : null,
                                                child: const Icon(Icons.person),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text(username),
                                                  isProfessional
                                                      ? Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  10.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Icon(
                                                            Icons.verified,
                                                            color: Color(
                                                                0xFF12CCEE),
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
        });
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
