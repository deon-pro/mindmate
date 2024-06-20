import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/professionals/post_widget.dart';

class ProfessionalProfileUpdate extends StatefulWidget {
  @override
  _ProfessionalProfileUpdateState createState() =>
      _ProfessionalProfileUpdateState();
}

class _ProfessionalProfileUpdateState extends State<ProfessionalProfileUpdate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController servicesOfferedController = TextEditingController();
  TextEditingController professionalProfileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final userAc = FirebaseAuth.instance.currentUser;

  String _profileImageUrl = ''; // Initialize as empty string
  String _uploadedDocumentUrl = ''; // Initialize as empty string

  var id;

  Future<void> _uploadImage(BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      // ignore: unnecessary_null_comparison
      if (imageFile == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('professional_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(imageFile);

      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong while uploading the image.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _uploadDocument(BuildContext context) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      // ignore: unnecessary_null_comparison
      if (imageFile == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('professional_documents')
          .child('document_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await storageRef.putFile(imageFile);

      final documentUrl = await storageRef.getDownloadURL();

      setState(() {
        _uploadedDocumentUrl = documentUrl;
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong while uploading the document.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mental_health_professionals')
            .where('id', isEqualTo: userAc!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent, //<-- SEE HERE
                backgroundColor: Colors.grey,
              ),
            );
          }
          if (snapshot.error != null) {
            return const Center(
              child: Text('Error loading data...'),
            );
          }

          final profData = snapshot.data!.docs.first;
          final info = profData.data()
              as Map<String, dynamic>; // Explicitly cast to the correct type

          TextEditingController nameController =
              TextEditingController(text: info['name']);
          TextEditingController aboutMeController =
              TextEditingController(text: info['aboutMe']);
          TextEditingController educationController =
              TextEditingController(text: info['education']);
          TextEditingController servicesOfferedController =
              TextEditingController(text: info['servicesOffered']);
          TextEditingController professionalProfileController =
              TextEditingController(text: info['license']);
          TextEditingController emailController =
              TextEditingController(text: info['email']);
          TextEditingController phoneController =
              TextEditingController(text: info['phone']);
          TextEditingController rateController =
              TextEditingController(text: info['rate'].toString());

          if (_uploadedDocumentUrl == null && _uploadedDocumentUrl.isEmpty) {
            _uploadedDocumentUrl = info['documentUrl'];
          }

          void _saveProfile() async {
            final name = nameController.text.trim();
            final aboutMe = aboutMeController.text.trim();
            final education = educationController.text.trim();
            final servicesOffered = servicesOfferedController.text.trim();
            final license = professionalProfileController.text.trim();
            final documentUrl = _uploadedDocumentUrl;
            final email = emailController.text.trim();
            final phone = phoneController.text.trim();
            // final rate = rateController.text.trim();
            if (_profileImageUrl == null || _profileImageUrl.isEmpty) {
              setState(() {
                _profileImageUrl = info['profileImageUrl'];
              });
            }

            final emailRegex =
                RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
            final phoneRegex = RegExp(r'^[0-9]{10}$');

            if (!emailRegex.hasMatch(email.trim())) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Invalid Email'),
                  content: Text('Please enter a valid email address.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }

            if (!phoneRegex.hasMatch(phone.trim())) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Invalid Phone Number'),
                  content: Text('Please enter a valid phone number.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }

            await FirebaseFirestore.instance
                .collection('mental_health_professionals')
                .doc(info['id'])
                .update({
              'name': name,
              'aboutMe': aboutMe,
              'education': education,
              'servicesOffered': servicesOffered,
              'license': license,
              'documentUrl': documentUrl,
              'email': email,
              'phone': phone,
              'profileImageUrl': _profileImageUrl,
              'userEmail': userAc?.email,
              'rate': int.parse(rateController.text.trim()),
              // 'verified': false,
            });

            Navigator.of(context).pop();
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Professional Profile',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              actions: [
                Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 16.0, 10.0),
                    child: Container(
                      width: 80,
                      // height: 20,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(2),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            backgroundColor:
                                FlutterFlowTheme.of(context).secondary,
                            // maximumSize: Size(40, 20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfessionalPostWidget( name: info['name'], profile: info['profileImageUrl'], service: info['servicesOffered'], docid: info['id'],)),
                            );
                          },
                          child: Text(
                            'POSTS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    )),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 60.0,
                      backgroundImage: _profileImageUrl != null &&
                              _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : info['profileImageUrl'] != null &&
                                  info['profileImageUrl'] != ''
                              ? NetworkImage(info['profileImageUrl']!)
                              : AssetImage('assets/images/doctor.png')
                                  as ImageProvider<Object>,
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () => _uploadImage(context),
                      child: Text('Change Profile Picture'),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name!!';
                        } else if (!RegExp(r"^[a-zA-Z0-9.\-_\s]+$")
                            .hasMatch(value)) {
                          return 'Please enter a valid name!';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: aboutMeController,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(labelText: 'About Me'),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: educationController,
                      decoration: InputDecoration(labelText: 'Education'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an institution!!';
                        } else if (!RegExp(r"^[a-zA-Z0-9.\-_\s]+$")
                            .hasMatch(value)) {
                          return 'Please enter a valid name!';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: servicesOfferedController,
                      decoration:
                          InputDecoration(labelText: 'Services Offered'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service call!!';
                        } else if (!RegExp(r"^[a-zA-Z0-9.\-_\s]+$")
                            .hasMatch(value)) {
                          return 'Please enter a valid option!';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),
                    // ElevatedButton(
                    //   onPressed: () => _uploadDocument(context),
                    //   child: Text('Upload Document'),
                    // ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: professionalProfileController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'License number',
                        hintText: 'e.g,Wa234e54R',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a license number!!';
                        } else if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value)) {
                          return 'Please enter a valid option!!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'e.g., deniskyalo28@gmail.com',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email!!';
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return 'Please enter a valid email!!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        hintText: 'e.g., 0712345678',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a phone number';
                        } else if (value.length > 10 || value.length < 10) {
                          return 'Phone must be 10 numbers long';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: rateController,
                      decoration: InputDecoration(
                        labelText: 'Estimated Hourly Rate(in USDs)',
                        hintText: '5',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a rate';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        if (isValid) {
                          _saveProfile();
                        }
                      },
                      child: Text('Save Profile'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
