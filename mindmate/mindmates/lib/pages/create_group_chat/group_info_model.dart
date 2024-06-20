import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmates/auth/firebase_auth/auth_util.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupInfo extends StatefulWidget {
  final memberIds;
  final memberName;
  final memberPhoto;
  const GroupInfo(
      {super.key,
      required this.memberIds,
      required this.memberName,
      required this.memberPhoto});

  @override
  State<GroupInfo> createState() => GroupInfoState();
}

class GroupInfoState extends State<GroupInfo> {
  final TextEditingController _nameController = TextEditingController();
  String? _profilePhotoUrl;
  File? image;
  bool isUploading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      _selectImage();
    }
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

  Future<void> createGroup() async {
    await _uploadProfilePhoto();
    if (_profilePhotoUrl == null) {
      setState(() {
        _profilePhotoUrl = '';
      });
    }
    // Assuming widget.memberIds is a List<String>
// Assuming widget.memberIds is a List<String>
widget.memberIds.insert(0, currentUserUid);

// Now, the 'users' list includes the current user ID at index 0
List<String> usersList = widget.memberIds;
    try {

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference messagesRef = firestore.collection('chatsGroup');
      DocumentReference documentRef = await messagesRef.add({
        'lastmessage': '$currentUserName created this group',
        'seenby': [],
        'sender': currentUserUid,
        'groupname': _nameController.text.trim(), // Image URL
        'groupAdmins': [currentUserUid],
        'superAdmin': currentUserUid,
        'description': '',
        'users': usersList,
        'profile': _profilePhotoUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      await documentRef.update({'id': documentRef.id});
      // print('--55533E3E3E34////////RRR: DONE');
    } catch (e) {
      // print('33E3E3E34////////RRR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primary),
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () async {
              final isValid = _formKey.currentState!.validate();
              if (isValid) {
                createGroup().whenComplete(() => Navigator.of(context).pop());
              }
            },
            child: Container(
                width: 60,
                color: FlutterFlowTheme.of(context).primary,
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: FlutterFlowTheme.of(context).tertiary,
                )),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                child: GestureDetector(
                  onTap: () {
                    requestStoragePermission();
                  },
                  child: CircleAvatar(
                    radius: 50,
                    foregroundImage: image != null ? FileImage(image!) : null,
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: TextFormField(
                  // border:
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.memberIds.length,
                itemBuilder: (BuildContext context, int index) {
                  String username = widget.memberName[index];
                  String userPhoto = widget.memberPhoto[index];
                  return Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: ListTile(
                      
                      leading: CircleAvatar(
                        radius: 25,
                        foregroundImage: userPhoto.isNotEmpty
                            ? NetworkImage(userPhoto)
                            : null,
                        child: const Icon(Icons.person),
                      ),
                      title: Text(username),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
