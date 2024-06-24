import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/backend/backend.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/flutter_flow/flutter_flow_util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtherStories extends StatefulWidget {
  const OtherStories({super.key});

  @override
  State<OtherStories> createState() => _OtherStoriesState();
}

class _OtherStoriesState extends State<OtherStories> {
  final userAc = FirebaseAuth.instance.currentUser;
  List<String> followingUserIds =
      []; // Track the user IDs being followed by the current user
  SharedPreferences? _prefs;
  int days = 1;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    getDuration();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void getDuration() async {
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      var data = remoteConfig.getInt('STORYDURATION');
      setState(() {
        days = data;
      });
      print("Remote Config value for POSTDURATION: $days");
    } catch (e) {
      print("Error fetching Remote Config: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = userAc?.uid;
    final tenDaysAgo = DateTime.now().subtract(Duration(days: 1000));
    final Timestamp tenDaysAgoTimestamp = Timestamp.fromDate(tenDaysAgo);

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: userAc?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.error),
                  Text('Something went wrong.'),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: const Text(
                    '..',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 112, 111, 111),
                    ),
                  )),
            );
          }

          final doc =
              snapshot.data!.docs.firstWhere((doc) => doc.id == userAc?.uid);

          final data = doc.data() as Map<String, dynamic>;

          final followIds = data['minding'];

          final queryStreams = followIds
              .map((id) {
                return FirebaseFirestore.instance
                    .collection('userStories')
                    .where('storyPostedAt', isGreaterThan: tenDaysAgoTimestamp)
                    .where('user',
                        isEqualTo: FirebaseFirestore.instance
                            .collection('users')
                            .doc(id)) // Convert id to document reference
                    .orderBy('storyPostedAt',
                        descending:
                            true) // Sort by timestamp in descending order
                    .limit(1)
                    .snapshots();
              })
              .cast<Stream<QuerySnapshot>>()
              .toList();

          return StreamBuilder<List<QuerySnapshot>>(
            stream: CombineLatestStream.list(queryStreams),
            builder: (BuildContext context,
                AsyncSnapshot<List<QuerySnapshot>> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.error),
                      Text('Something went wrong.'),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text('..'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('..'),
                );
              }

              //final items = snapshot.requireData;
              final List<Story> story = snapshot.data!
                  .expand((querySnapshot) {
                    return querySnapshot.docs.take(20).map((doc) {
                      // Limit to 20 stories
                      return Story(
                        userid: doc['user'],
                        image: doc['storyPhoto'],
                        // time: doc['StoryPostedAt'],
                        // docid: doc['id'],
                        views: doc['views'],
                        // Add other properties as needed
                      );
                    });
                  })
                  .cast<Story>()
                  .toList();

              // Sort the stories based on whether they have been viewed
              final List<Story> unviewedStories = [];
              final List<Story> viewedStories = [];

              for (final story in story) {
                if (story.views.contains(userId)) {
                  viewedStories.add(story);
                } else {
                  unviewedStories.add(story);
                }
              }
// Combine unviewed and viewed stories in the desired order
              final List<Story> combinedStories = [
                ...unviewedStories,
                ...viewedStories
              ];

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: combinedStories.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('uid',
                              isEqualTo: combinedStories[index].userid.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              //  child: Text('.tt.'),
                              );
                        }
                        if (snapshot.error != null) {
                          return const Center(
                            child: Text('Error loading data...'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              // child: Text('.xhtcduukg.'),
                              );
                        }

                        final userdata = snapshot.data!.docs.first;
                        final userInfo = userdata.data() as Map<String,
                            dynamic>; // Explicitly cast to the correct type

                        if (userInfo['uid'] == userId) {
                          return Container();
                        }
                        final useId = userInfo['uid'];
                        final usename = userInfo['userName'];

                        return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('userStories')
                                .where('user',
                                    isEqualTo: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userInfo[
                                            'uid'])) // Convert id to document reference
                                .where('storyPostedAt',
                                    isGreaterThan: tenDaysAgoTimestamp)
                                .orderBy('storyPostedAt',
                                    descending:
                                        true) // Sort by timestamp in descending order
                                .limit(
                                    1) // Limit the result to only the latest document
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text('..'),
                                );
                              }
                              if (snapshot.error != null) {
                                return const Center(
                                  child: Text('Error loading data...'),
                                );
                              }

                              final latestStoryDoc = snapshot.data!.docs.first;
                              final latestStoryData =
                                  latestStoryDoc.data() as Map<String, dynamic>;

                              final List<String> viewList = [];
                              if (latestStoryData['views'] != null) {
                                viewList.addAll(List<String>.from(
                                    latestStoryData['views']));
                              }

                              bool isViewed = viewList.contains(userAc?.uid);

                              return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('userStories')
                                      .where('storyPostedAt',
                                          isGreaterThan: tenDaysAgoTimestamp)
                                      .where('user',
                                          isEqualTo: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userInfo[
                                                  'uid'])) // Convert id to document reference
                                      .orderBy('storyPostedAt',
                                          descending:
                                              false) // Sort by timestamp in descending order

                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                        child: Text('..'),
                                      );
                                    }
                                    // if (snapshot.hasData) {
                                    final docs = snapshot.data!.docs;
                                    final key = userInfo['uid'];
                                    final storedDocId =
                                        _prefs?.getString(key) ?? '';

                                    // Find the index of the stored docId in the query snapshot
                                    int index = docs.indexWhere(
                                        (doc) => doc.id == storedDocId);
                                    print('gjgj94ngn: $index');
                                    print('88uuijijij: $key');
                                    print('9uhhy6gt: ${docs.length}');
                                    if (isViewed || index == -1) index = 0;

                                    return GestureDetector(
                                      onTap: () {
                                        context.pushNamed(
                                          'storyDetails',
                                          queryParameters: {
                                            'initialStoryIndex': serializeParam(
                                                0, ParamType.int),
                                            'userId': serializeParam(
                                                useId, ParamType.String),
                                            'userName': serializeParam(
                                                usename, ParamType.String),
                                          }.withoutNulls,
                                          extra: <String, dynamic>{
                                            kTransitionInfoKey: TransitionInfo(
                                              hasTransition: true,
                                              transitionType: PageTransitionType
                                                  .bottomToTop,
                                              duration:
                                                  Duration(milliseconds: 200),
                                            ),
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 32,
                                                  backgroundColor: !isViewed
                                                      ?  FlutterFlowTheme.of(context).primary
                                                      : const Color.fromARGB(
                                                          0, 255, 193, 7),
                                                ),
                                                Positioned(
                                                  bottom: 2,
                                                  right: 2, 
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .cardColor,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 4,
                                                  right: 4,
                                                  child: CircleAvatar(
                                                    radius: 28,
                                                    foregroundImage: userInfo[
                                                                'photo_url'] !=
                                                            null
                                                        ? NetworkImage(userInfo[
                                                            'photo_url']!)
                                                        : null,
                                                    child: const Icon(
                                                        Icons.person),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 4, 0, 0),
                                              width: 46,
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Wrap(
                                                      children: [
                                                        Text(
                                                          userInfo['userName'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            });
                      });
                },
              );
            },
          );
        });
  }
}

class Story {
  String image;
  DocumentReference userid;
  // Timestamp time;
  List views;

  Story({
    required this.image,
    required this.userid,
    // required this.time,
    required this.views,
  });
}
