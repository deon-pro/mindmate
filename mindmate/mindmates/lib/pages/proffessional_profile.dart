import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


class MentalHealthProfessionalProfilePage extends StatefulWidget {
  @override
  _MentalHealthProfessionalProfilePageState createState() =>
      _MentalHealthProfessionalProfilePageState();
}

class _MentalHealthProfessionalProfilePageState
    extends State<MentalHealthProfessionalProfilePage> {
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

  String? _profileImageUrl;
  String? _uploadedDocumentUrl;
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

  void _saveProfile() async {
    final name = nameController.text.trim();
    final aboutMe = aboutMeController.text.trim();
    final education = educationController.text.trim();
    final servicesOffered = servicesOfferedController.text.trim();
    final license = professionalProfileController.text.trim();
    final documentUrl = _uploadedDocumentUrl;
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    if (_uploadedDocumentUrl == null) {
      _uploadedDocumentUrl = '';
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

    FirebaseFirestore.instance.collection('professional_verification').doc(userAc?.uid).set({
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
      'verified': false,
      'id': userAc?.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your profile has been saved successfully. Wait for approval. This can take up to 48 hours.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Profile'),
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
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
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
      return 'Please enter a name!';
    } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value)) {
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
      return 'Please enter an institution!';
    } else if (!RegExp(r"^[a-zA-Z0-9.\-_\s]+$").hasMatch(value)) {
      return 'Please enter a valid name!';
    }
    return null;
  },
),
SizedBox(height: 10.0),
TextFormField(
  controller: servicesOfferedController,
  decoration: InputDecoration(labelText: 'Services Offered'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a service!';
    } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value)) {
      return 'Please enter a valid option!';
    }
    return null;
  },
),

              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () => _uploadDocument(context),
                child: Text('Upload Document'),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: professionalProfileController,
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
                  hintText: 'e.g., mindmate@gmail.com',
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
  }
}
