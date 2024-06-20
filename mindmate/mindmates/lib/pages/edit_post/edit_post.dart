
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
// ignore: unused_import
import 'package:video_player/video_player.dart';

class PostEdit extends StatefulWidget {
  final postId;
  const PostEdit({super.key, required this.postId});

  @override
  State<PostEdit> createState() => _PostEditState();
}

class _PostEditState extends State<PostEdit> {
  @override
  Widget build(BuildContext context) {
    // Map<String, VideoPlayerController> _videoPlayers = {};

    return StreamBuilder<DocumentSnapshot>(
       stream: FirebaseFirestore.instance
      .collection('userPosts')
      .doc(widget.postId) // Use .doc to reference the specific document by ID
      .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ) {
            return Center();
          }
          if (snapshot.error != null) {
            return Center(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: const Text('Error loading posts...')),
            );
          }

         final postdata = snapshot.data!;
    final post = postdata.data()
        as Map<String, dynamic>; // Explicitly cast to the correct type
          final TextEditingController comment =
              TextEditingController(text: post['postDescription']);
          final image = post['postPhoto'];
          // final type = post['type'];
          // String videoUrl = image[0];

          // Check if the video player is already initialized
          // if (!_videoPlayers.containsKey(videoUrl)) {
          //   // Initialize video player for the post
          //   VideoPlayerController videoPlayerController =
          //       VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          //   videoPlayerController.setVolume(0.0); // Set volume to 0 (sound off)
          //   _videoPlayers[videoUrl] = videoPlayerController;
          //   videoPlayerController.initialize().then((_) {
          //     setState(() {
          //       videoPlayerController.play();
          //     });
          //   });
          // }

          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).accent1),
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              title: Text('Edit Post'),
              actions: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('userPosts')
                            .doc(widget.postId)
                            .update({'postDescription': comment.text.trim()}).then((_) {
                          Navigator.pop(context);
                        }).catchError((error) {
                          print('Error update: $error');
                        });
                      },
                      child: CircleAvatar(
                          backgroundColor: Color(0xFF12CCEE),
                          child: Icon(
                            Icons.check,
                            size: 36,
                            color: Colors.white,
                          ))),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .92,
                    padding: EdgeInsets.fromLTRB(10, 60, 10, 40),
                    child: TextField(
                      maxLines: 4,
                      minLines: 1,
                      controller: comment,
                    ),
                  ),
                  Container(
                    height: 400,
                    child:
                    //  type == 'video'
                    //     ? AspectRatio(
                    //         aspectRatio:
                    //             _videoPlayers[videoUrl]?.value.aspectRatio ??
                    //                 16 / 9,
                    //         child: VideoPlayer(_videoPlayers[videoUrl]!),
                    //       )
                    //     :
                    //      PageView.builder(
                    //         scrollDirection: Axis.horizontal,
                    //         controller: PageController(
                    //           initialPage: 0,
                    //           viewportFraction: 1.0,
                    //           keepPage: false,
                    //         ),
                    //         itemCount: image.length,
                    //         // onPageChanged: (int page) {
                    //         //   setState(() {
                    //         //     _currentPage = page;
                    //         //   });
                    //         // },
                    //         itemBuilder: (BuildContext context, int indice) {
                    //           return 
                              IntrinsicHeight(
                                child: Container(
                                  // height: 240,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    // image[indice],
                                    image,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                          //   },
                          // ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
