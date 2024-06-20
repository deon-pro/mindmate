import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/edit_post/edit_post.dart';
import 'package:share_plus/share_plus.dart';

class UserPostMenu extends StatefulWidget {
  final canComment;
  final docid;
  final username;
  
  const UserPostMenu(
      {super.key,
      required this.canComment,
      required this.docid,
      this.username});

  @override
  State<UserPostMenu> createState() => _UserPostMenuState();
}

class _UserPostMenuState extends State<UserPostMenu> {
  @override
  Widget build(BuildContext context) {
    bool isCommentOn = widget.canComment == true;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text(
              'Share link',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            onTap: () {
              final String text =
                  'https:/mindmate.net/%fs%101/?user=${widget.username}%post=??';
              Share.share(text);

              // Handle option 1
              Navigator.pop(context);
            },
          ),
          isCommentOn
              ? ListTile(
                  title: const Text(
                    'Turn off commenting',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
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
                                  'Turn Off Commenting',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                       color: FlutterFlowTheme.of(context)
                                   .accent1,),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'By turning off comments users will not be able to post comments on this post.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: FlutterFlowTheme.of(context)
                                   .accent1,),
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
                                    final collection = FirebaseFirestore
                                        .instance
                                        .collection('userPosts')
                                        .doc(widget.docid.id)
                                        .update({'canComment': false})
                                        .then((_) => print('Deleted'))
                                        .catchError((error) =>
                                            print('Delete failed: $error'));

                                    Navigator.pop(context);
                                  },
                                  child: Text('Turn Off',
                                      style: TextStyle(
                                          
                                          color:
                                              Theme.of(context).indicatorColor
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
                                          color: FlutterFlowTheme.of(context)
                                   .accent1,
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
                    // Handle option 1
                  },
                )
              : ListTile(
                  title: const Text(
                    'Turn on commenting',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
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
                                  'Turn On Commenting',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                       color: FlutterFlowTheme.of(context)
                                   .accent1,),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'By turning on comments users will be able to post comments on this post.',
                                  style: TextStyle(
                                      fontSize: 14,
                                       color: FlutterFlowTheme.of(context)
                                   .accent1,),
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
                                    final collection = FirebaseFirestore
                                        .instance
                                        .collection('userPosts')
                                        .doc(widget.docid.id)
                                        .update({'canComment': true})
                                        .then((_) => print('Deleted'))
                                        .catchError((error) =>
                                            print('Delete failed: $error'));

                                    Navigator.pop(context);
                                  },
                                  child: Text('Turn On',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).indicatorColor
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
                                           color: FlutterFlowTheme.of(context)
                                   .accent1,
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
                    // Handle option 1
                  },
                ),
          ListTile(
            title: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostEdit(
                        postId: widget.docid.id,
                      )));

              // Handle option 1
              // Navigator.pop(
              //     context);
            },
          ),
          ListTile(
            title: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
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
                            'Delete Post',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context)
                                   .accent1,),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'This will remove this post and cannot be undone',
                            style: TextStyle(
                                fontSize: 14,
                                 color: FlutterFlowTheme.of(context)
                                   .accent1,),
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
                              final collection = FirebaseFirestore.instance
                                  .collection('userPosts');
                              collection
                                 .doc(widget.docid.id)// <-- Doc ID to be deleted.
                                  .delete() // <-- Delete
                                  .then((_) => print('Deleted'))
                                  .catchError((error) =>
                                      print('Delete failed: $error'));

                              Navigator.pop(context);
                            },
                            child: Text('Delete',
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor
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
                                    color: FlutterFlowTheme.of(context)
                                   .accent1,
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
          ),
        ],
      ),
    );
  }
}
