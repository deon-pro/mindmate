import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/flutter_flow/flutter_flow_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfessionalPost extends StatefulWidget {
  const ProfessionalPost({super.key});

  @override
  State<ProfessionalPost> createState() => _ProfessionalPostState();
}

class _ProfessionalPostState extends State<ProfessionalPost> {
  String? _professionalPhotoUrl;
  File? _professionalPhoto;
  bool isUploading = false;

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      _selectstoryPhoto();
    }
  }

  Future<void> _selectstoryPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1920,
      maxWidth: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _professionalPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadprofessionalPhoto() async {
    if (_professionalPhoto == null) {
      return;
    }
    setState(() {
      isUploading = true;
    });

    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('professional_post/${DateTime.now().toString()}');
    final uploadTask = storageRef.putFile(_professionalPhoto!);

    await uploadTask.whenComplete(() async {
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _professionalPhotoUrl = downloadUrl;
        isUploading = false;
      });
    });
  }

  Future<void> saveStoryToFirestore() async {
    await _uploadprofessionalPhoto();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference collectionRef =
        firestore.collection('professional_posts');

    // Add data to the collection
    DocumentReference documentRef = await collectionRef.add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'imageUrl': _professionalPhotoUrl,
      'timestamp': Timestamp.now(),
      'comment': _model.text.trim(),
      // 'comments': 0,
      // 'views': [],
    });
    // docid = documentRef.id;

    // Update the document to add the ID field
    await documentRef.update({'id': documentRef.id});

    Navigator.of(context).pop();
  }

  TextEditingController _model = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await requestStoragePermission();
                    },
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 350.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.asset(
                            'assets/images/emptyPost@2x.png',
                          ).image,
                        ),
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: _professionalPhoto != null
                          ? Image.file(_professionalPhoto!)
                          : null,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _model,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Comment....',
                              hintStyle: FlutterFlowTheme.of(context).bodySmall,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 20.0, 20.0, 12.0),
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium,
                            textAlign: TextAlign.start,
                            maxLines: 4,
                            // validator: _model
                            //     .textControllerValidator
                            //     .asValidator(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
              child: FFButtonWidget(
                onPressed: () async {
                  // ignore: unused_local_variable
                   isUploading?
                   null
                  :saveStoryToFirestore();
                },
                text: isUploading?
                'Uploading...'
                :'Create Post',
                options: FFButtonOptions(
                  width: 270.0,
                  height: 50.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                  elevation: 0.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
