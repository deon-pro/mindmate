import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/pages/professionals/create_post.dart';

import 'edit_post.dart';

class ProfessionalPostWidget extends StatefulWidget {
  final profile;
  final name;
  final service;
  final docid;
  const ProfessionalPostWidget({
    super.key,
    required this.profile,
    required this.name,
    required this.service,
    required this.docid,
  });

  @override
  State<ProfessionalPostWidget> createState() => _ProfessionalPostWidgetState();
}

class _ProfessionalPostWidgetState extends State<ProfessionalPostWidget> {
  @override
  Widget build(BuildContext context) {
    String profilePic = widget.profile;
    return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('professional_posts')
                        .where('userId', isEqualTo: widget.docid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      //   return Center(
                      //     child: Container(
                      //         width: MediaQuery.of(context).size.width,
                      //         padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      //         alignment: Alignment.topCenter,
                      //         child: const Text('..')),
                      //   );
                      // }
                      // if (snapshot.error != null) {
                      //   return Center(
                      //     child: Container(
                      //         padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      //         child: const Text('Error loading posts...')),
                      //   );
                      // }
                      final postDocs = snapshot.data?.docs ?? [];

        return Scaffold(
          appBar: AppBar(
            actions: [
              postDocs.length > 12?
              Container()
              :GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfessionalPost()),
                  );
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 30,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                                  child: Text(
                                    'Mindmates Professional Team',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  height: 1.4,
                                  color: Colors.grey[200],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward_ios_outlined),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 12, 0, 5),
                                      child: Text(
                                          'As a professional your job is giving people hope and comfort. You are given chance to post up to 12 photos to support you.'),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward_ios_outlined),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Text(
                                          'You are given a chance to market your skills by posting great photos to give people hope and peace of mind.'),
                                    ),
                                  ],
                                ),
                               Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward_ios_outlined),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Text(
                                          'Make sure to keep you posts nice, helpful and abide by the rules to uphold morals.'),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                                  child: Text('******'),
                                ),
                                 Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Text(
                                          'You can add a post by using the add icon on the appbar.'),
                                    ),
                                  ],
                                ),
                               Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward),
                                    Container(
                                       width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Text(
                                          'You can edit a post by just clicking on it.'),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.arrow_forward),
                                    Container(
                                       width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Text(
                                          'You can delete a post by simply long-pressing on it.'),
                                    ),
                                  ],
                                ),
                               Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.star_half_outlined),
                                    Container(
                                       width: MediaQuery.of(context).size.width * 0.6, 
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      child: Text(
                                          'Remember we serve to help mental health issue and you are our ambassador.'),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 2),
                                  child: Text(' WE APPRECIATE YOU!!'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                  child: Icon(
                    Icons.help_outline_outlined,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: CircleAvatar(
                      radius: 60,
                      foregroundImage:
                          // ignore: unnecessary_null_comparison
                          profilePic != null ? NetworkImage(profilePic) : null,
                      child: const Icon(Icons.person),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 90),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(
                            widget.name,
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
                            widget.service,
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 8, 0, 8),
                        // width: MediaQuery.of(context).size.width,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Professional Posts',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),

                       Container(
                        padding: EdgeInsets.fromLTRB(10, 8, 20, 8),
                        // width: MediaQuery.of(context).size.width,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${postDocs.length.toString()} / 12' ,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(4))),
                          width: MediaQuery.of(context).size.width * .46,
    
                          // child: Text('Professional Posts'),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width * .54,
                          color: Colors.white,
                          // child: Text('Professional Posts'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: postDocs.isEmpty?
                    Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              alignment: Alignment.topCenter,
                              child: const Text('..',
                              style: TextStyle(
                                                  fontSize: 21,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                              )),
                        )
                    :GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: postDocs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final posts =
                                  postDocs[index].data() as Map<String, dynamic>;
    
                              final image = posts['imageUrl'] as String?;
                              final comment = posts['comment'] as String;
                              final time = posts['timestamp'] as Timestamp;
                              final docid = posts['id'] as String;
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProfessionalPostEdit(
                                            comment: comment,
                                            docid: docid,
                                            image: image,
                                          )));
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width *
                                              0.6,
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Delete Post',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'This will remove this post and cannot be undone',
                                                // style: TextStyle(fontSize: 14, color: Theme.of(context).shadowColor),
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
                                                  final collection =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'professional_posts');
                                                  collection
                                                      .doc(
                                                          docid) // <-- Doc ID to be deleted.
                                                      .delete() // <-- Delete
                                                      .then((_) => print('Deleted'))
                                                      .catchError((error) => print(
                                                          'Delete failed: $error'));
    
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(255, 255, 7, 201)
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
                                                child: Text(
                                                  'Cancel',
                                                  // style: TextStyle(color: Theme.of(context).shadowColor
                                                  //     // color: Colors
                                                  //     //     .black
                                                  //     )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: image != null
                                      ? Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(),
                                ),
                              );
                            },
                          ),
                       
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
