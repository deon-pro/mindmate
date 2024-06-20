import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/pages/professionals/professional_requests.dart';

class VerifyProfesional extends StatefulWidget {
  final ProfessionalData data;
  const VerifyProfesional({super.key, required this.data});

  @override
  State<VerifyProfesional> createState() => _VerifyProfesionalState();
}

class _VerifyProfesionalState extends State<VerifyProfesional> {
  @override
  Widget build(BuildContext context) {
   // String profilePic = widget.data.profile;
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Do you really want to approve user ${widget.data.userEmail} to become a professional?',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Container(
                            height: 1.4,
                            color: Colors.grey[200],
                          ),
                          TextButton(
                            onPressed: () async {
                              // Implement delete functionality here
                              // For example, delete the image from Firestore
                              // Then close the dialog
                           
                                FirebaseFirestore.instance.collection('mental_health_professionals').doc(widget.data.userid).set({
                                'name': widget.data.name,
                                'aboutMe': widget.data.about,
                                'education': widget.data.education,
                                'servicesOffered': widget.data.service,
                                'license': widget.data.license,
                                'documentUrl': widget.data.docUrl,
                                'email': widget.data.email,
                                'phone': widget.data.phone,
                                'profileImageUrl': widget.data.profile,
                                'userEmail': widget.data.userEmail,
                                'rate': widget.data.rate,
                                'verified': true,
                                'id': widget.data.userid,
                                'professional': 'professional', //PLEASE DON'T REMOVE THIS
                                'codec': 101 //PLEASE DON'T REMOVE THIS
                              });

                              // Update the document to add the ID field
                              // await documentRef.update({'id': documentRef.id});

                              await FirebaseFirestore.instance.collection('professional_verification').doc(widget.data.docid).update({'verified': true}).then((_) => print('Deleted')).catchError((error) => print('Delete failed: $error'));

                              Navigator.pop(context);
                              Navigator.of(context).pop();
                            },
                            child: Text('Approve',
                                style: TextStyle(color: Color(0xFF12CCEE)
                                    // color: Colors
                                    //     .red
                                    )),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            height: 1.4,
                            color: Colors.grey[200],
                          ),
                          TextButton(
                            onPressed: () {
                              // Close the dialog without deleting
                              Navigator.pop(context);
                            },
                            child: Text('Cancel',
                                style: TextStyle(
                                    // color: Colors
                                    //     .black
                                    )),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
               padding: const EdgeInsets.fromLTRB(10, 15, 20, 10),
              child: Text(
                'Approve',
                style: TextStyle(
                  fontSize: 13,
                  // color:
                  //     Theme.of(context).shadowColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        // SizedBox(height: 30,),
        margin: EdgeInsets.fromLTRB(0, 75, 0, 0),

        child: FloatingActionButton(
          backgroundColor: widget.data.rate < 10
              ? Colors.green
              : widget.data.rate < 50
                  ? Color(0xFF12CCEE)
                  : widget.data.rate < 100
                      ? const Color.fromARGB(255, 217, 1, 255)
                      : widget.data.rate >= 100
                          ? Colors.yellow
                          : Colors.greenAccent,
          onPressed: () {
            // Handle the FloatingActionButton onPressed event
          },
          child: Text(
            '\$${widget.data.rate.toString()}',
            style: TextStyle(
              fontSize: 11,
              // color:
              //     Theme.of(context).shadowColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: SingleChildScrollView(
        child: Container(
          // constraints: BoxConstraints(
          //   maxHeight: (MediaQuery.of(context).size.height),
          // ),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CircleAvatar(
  radius: 60,
  foregroundImage: widget.data.profile.isNotEmpty
      ? NetworkImage(widget.data.profile)
      : null,
  child: const Icon(Icons.person),
),

              ),
              Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        widget.data.name,
                        style: TextStyle(
                          // fontSize: 11,
                          // color:
                          //     Theme.of(context).shadowColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        widget.data.service,
                        style: TextStyle(
                          fontSize: 11,
                          // color:
                          //     Theme.of(context).shadowColor,
                          // fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Column(
                      
                      children: [
                        Container(
                         
                          child: Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 12,
                              // color:
                              //     Theme.of(context).shadowColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                           width: MediaQuery.of(context).size.width * .88,
                          child: Text(
                            widget.data.about,
                            style: TextStyle(
                              fontSize: 11,
                              // color:
                              //     Theme.of(context).shadowColor,
                              // fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Column(
                        children: [
                          Icon(Icons.school),
                          Container(
                             alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * .88,
                            child: Text(
                              widget.data.education,
                              style: TextStyle(
                                fontSize: 11,
                                // color:
                                //     Theme.of(context).shadowColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                     Container(
                      child: Column(
                        children: [
                          Icon(Icons.email),
                          Container(
                             alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * .88,
                            child: Text(
                              widget.data.email,
                              style: TextStyle(
                                fontSize: 11,
                                // color:
                                //     Theme.of(context).shadowColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .7,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              backgroundColor: Colors.grey[500]),
                          onPressed: () {},
                          child:  Text(
                            'View License(${widget.data.license})',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )),
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .7,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              backgroundColor: Colors.grey[500]),
                          onPressed: () {},
                          child:  Text(
                            'Message(${widget.data.phone})',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                // child: Text('Professional Posts'),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
