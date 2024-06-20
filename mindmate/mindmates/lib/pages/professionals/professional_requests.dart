import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/pages/professionals/professional_verification.dart';

class ProfessionalsRequests extends StatelessWidget {
  const ProfessionalsRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFESSIONAL Verification',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            // fontWeight: FontWeight.bold,
            // color: Color.fromARGB(255, 2, 219, 92)
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('professional_verification')
              .where('verified', isEqualTo: false)
              // .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    alignment: Alignment.topCenter,
                    child: const Text('No requests yet..')),
              );
            }
            if (snapshot.error != null) {
              return Center(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: const Text('Error loading posts...')),
              );
            }

            List<ProfessionalData> professionalData =
                snapshot.data!.docs.map((doc) {
              return ProfessionalData(
                about: doc['aboutMe'],
                education: doc['education'],
                email: doc['email'],
                name: doc['name'],
                phone: doc['phone'],
                license: doc['license'],
                docid: doc['id'],
                userEmail: doc['userEmail'],
                profile: doc['profileImageUrl'] ??
                    '', // Use an empty string as a default
                service: doc['servicesOffered'],
                docUrl: doc['documentUrl'],
                rate: doc['rate'],
                userid: doc['id'],
              );
            }).toList();

            return ListView.builder(
              itemCount: professionalData.length,
              itemBuilder: (BuildContext context, int index) {
                String profilePic = professionalData[index].profile;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VerifyProfesional(
                              data: professionalData[index],
                            )));
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(14, 10, 10, 10),
                        height: 100,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 14, 0),
                              child: CircleAvatar(
                                radius: 34,
                                foregroundImage: profilePic != ''
                                    ? NetworkImage(profilePic)
                                    : null,
                                child: const Icon(Icons.person),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(professionalData[index].name),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  professionalData[index].service,
                                  style: TextStyle(
                                      fontSize: 12,
                                      // fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 2, 219, 92)),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Hourly rate: \$${professionalData[index].rate.toString()} ',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 151, 2, 219)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: .6,
                        color: const Color.fromARGB(255, 112, 112, 112),
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}

class ProfessionalData {
  String about;
  String docid;
  String education;
  String email;
  String name;
  String phone;
  String license;
  String profile;
  String service;
  String userEmail;
  String docUrl;
  String userid;
  int rate;

  ProfessionalData({
    required this.about,
    required this.userid,
    required this.docUrl,
    required this.userEmail,
    required this.rate,
    required this.docid,
    required this.education,
    required this.email,
    required this.name,
    required this.phone,
    required this.license,
    required this.profile,
    required this.service,
  });
}
