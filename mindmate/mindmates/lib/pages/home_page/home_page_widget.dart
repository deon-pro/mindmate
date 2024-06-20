import 'dart:math';

import 'package:mindmates/pages/menu/public_post_menu.dart';
import 'package:mindmates/pages/menu/user_post_menu.dart';
import 'package:mindmates/pages/sos/sos.dart';
import 'package:mindmates/pages/notifications/notifications.dart';
import 'package:mindmates/pages/home_page/chatbot.dart';
import 'package:mindmates/pages/public_profile/public_profile.dart';
import 'package:rxdart/rxdart.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/create_modal/create_modal_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_media_display.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key, required String searchQuery})
      : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  late HomePageModel _model;
  List<String> followingUserIds =
      []; // Track the user IDs being followed by the current user
  List<DocumentReference> userRefs = [];
  List<DocumentReference> postIds = [];
  List<UserPostsRecord> socialFeedUserPostsRecordList = [];
  List<UserPostsRecord> socialFeedUserPostsData = [];
  List<UserPostsRecord> shuffle = [];
  List followIds = [];
  List randomIDs = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasIconTriggered = false;
  final animationsMap = {
    'iconOnActionTriggerAnimation': AnimationInfo(
      trigger: AnimationTrigger.onActionTrigger,
      applyInitialState: false,
      effects: [
        ScaleEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(1.2, 0.0),
          end: Offset(0.0, 1.0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    fetchFollowingUserIds();
    loadPostData();
    _model = createModel(context, () => HomePageModel());

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _refreshHomePage() async {
    //  Implement the refresh logic for the homepage

    await Future.delayed(Duration(seconds: 2))
        .then((value) => loadPostData()); // Simulating a delay
  }

  void fetchFollowingUserIds() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    final followingList = userSnapshot.get('minding') as List<dynamic>?;
    // print('user refdgd: $followingList');
    if (followingList != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference usersCollection = firestore.collection('users');

      List<DocumentReference> userReferences = followingList.map((userId) {
        return usersCollection.doc(userId);
      }).toList();
      print('user refdgd: $userReferences');

      setState(() {
        userRefs = userReferences;
      });
    }
  }

  static Future<List<DocumentReference>> getFollowingUserReferences() async {
    final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get();

    if (!userSnapshot.exists) {
      // Handle the case where the current user's document doesn't exist
      return [];
    }

    final List<String> followingUserIds =
        List<String>.from(userSnapshot['minding'] ?? []);
    final List<DocumentReference> followingUserReferences =
        followingUserIds.map((userId) {
      return FirebaseFirestore.instance.collection('users').doc(userId);
    }).toList();

    return followingUserReferences;
  }

  static Future<List<DocumentReference>> getRandomUserReferences(
      List<DocumentReference> followingReferences) async {
    if (followingReferences.length < 40) {
      final int limit = 40 - followingReferences.length;

      followingReferences.add(FirebaseFirestore.instance.collection('users').doc(
          currentUserUid)); // Add the current user's reference to the list of following references

      final batchSize = 10; // Set the batch size according to your needs
      List<DocumentReference> allUserReferences = [];

      for (int i = 0; i < followingReferences.length; i += batchSize) {
        List<DocumentReference> batch =
            followingReferences.skip(i).take(batchSize).toList();

        QuerySnapshot batchSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereNotIn: batch.map((ref) => ref.id))
            .get();

        List<DocumentReference> batchUserReferences =
            batchSnapshot.docs.map((doc) => doc.reference).toList();
        allUserReferences.addAll(batchUserReferences);
      }

      // Exclude the current user's reference from the list of allUserReferences
      allUserReferences.remove(
          FirebaseFirestore.instance.collection('users').doc(currentUserUid));

      final random = Random();
      allUserReferences.shuffle(random);
      print('Random User References: $allUserReferences');
      print('Length: ${allUserReferences.length}');
      return allUserReferences.take(limit).toList();
    }
    return <DocumentReference>[];
  }

  Future<void> loadPostData() async {
    
    final tenDaysAgo = DateTime.now().subtract(Duration(days: 30));
   
    final Timestamp tenDaysAgoTimestamp = Timestamp.fromDate(tenDaysAgo);

    final List<DocumentReference> followingUserReferences =
        await getFollowingUserReferences();
    print('Follows dvjfninf dfsgifn:  $followingUserReferences');

    // final List<String> blockedUserIds = await getBlockedUserIds(currentUserId);
    // print('Blocked Users: $blockedUserIds');

    final List<DocumentReference> randomUserReferences =
        await getRandomUserReferences(followingUserReferences);
    print('Random dvjfninf dfsgifn:  $randomUserReferences');

    // final List<String> allUserIds = [...followingUserIds, ...randomUserIds];
    // Initialize a Set to keep track of processed user IDs
    Set<DocumentReference> processedUserReferences = Set<DocumentReference>();

// Create a List to store all user IDs, filtering out duplicates
    List<DocumentReference> allUserReferences = [
      ...followingUserReferences,
      ...randomUserReferences,
    ].where((userReference) {
      // Check if the user has been processed before
      final userId = userReference.id;
      if (!processedUserReferences.contains(
          FirebaseFirestore.instance.collection('users').doc(userId))) {
        processedUserReferences
            .add(FirebaseFirestore.instance.collection('users').doc(userId));
        // Mark the user as processed
        return true; // Include the user reference in the list
      }
      return false; // Exclude the user reference from the list
    }).toList();

    print('All dvjfninf dfsgifn:  $allUserReferences');

    final batches = [];
    for (int i = 0; i < allUserReferences.length; i += 10) {
      batches.add(allUserReferences.skip(i).take(10).toList());
    }

    final snapshots = [];
    for (var batch in batches) {
      snapshots.add(
        FirebaseFirestore.instance
            .collection('userPosts')
            .where('postUser', whereIn: batch)
            // .where('timePosted', isGreaterThan: tenDaysAgoTimestamp)
            .get(),
      );
    }

// Merge query snapshots
    final mergedSnapshots = await Future.wait<QuerySnapshot>(
        snapshots.cast<Future<QuerySnapshot>>());

// Extract the document snapshots from the merged snapshots
    final documentSnapshots =
        mergedSnapshots.expand((snapshot) => snapshot.docs).toList();

// Parse the Firestore data into your UserPostsRecord class or model
    List<UserPostsRecord> shuffle = documentSnapshots
        .map((doc) => UserPostsRecord.fromSnapshot(doc))
        .toList();

    // print('POST---All dvjfninf dfsgifn:  $shuffle');

    // Shuffle the postData list randomly once when you load the data
    final random = Random();
    socialFeedUserPostsRecordList = List.from(shuffle);
    socialFeedUserPostsRecordList.shuffle(random);

    // print('POST..All dvjfninf dfsgifn:  $socialFeedUserPostsData');

    // Update the UI with the fetched and shuffled data
    setState(() {});
  }

  
  Stream<List<UserStoriesRecord>> getStoriesStream(
    List<DocumentReference> userReference,
  ) {
    if (userReference.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('userStories')
          .where('user', whereIn: userReference)
          .orderBy('storyPostedAt', descending: false)
          .snapshots()
          .map((querySnapshot) {
        // Convert the QuerySnapshot to a List of UserStoriesRecord
        return querySnapshot.docs.map((doc) {
          return UserStoriesRecord.fromSnapshot(doc);
        }).toList();
      });
    } else {
      return Stream.empty();
    }
  }

  DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

  @override
  Widget build(BuildContext context) {
    final tenDaysAgo = DateTime.now().subtract(Duration(days: 20));
    
    final Timestamp tenDaysAgoTimestamp = Timestamp.fromDate(tenDaysAgo);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Color(0x00000000),
            barrierColor: Color(0x00000000),
            context: context,
            builder: (context) {
              return Padding(
                padding: MediaQuery.viewInsetsOf(context),
                child: Container(
                  height: 240.0,
                  child: CreateModalWidget(),
                ),
              );
            },
          ).then((value) => setState(() {}));
        },
        backgroundColor: Color(0xFF4B39EF),
        elevation: 8.0,
        child: Icon(
          Icons.create_rounded,
          color: Colors.white,
          size: 24.0,
        ),
      ),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (Theme.of(context).brightness == Brightness.light)
              Image.asset(
                'assets/images/mindmate.png',
                width: 100.0,
                height: 50.0,
                fit: BoxFit.fitWidth,
              ),
            if (Theme.of(context).brightness == Brightness.dark)
              Image.asset(
                'assets/images/mindmate.png',
                width: 100.0,
                height: 50.0,
                fit: BoxFit.fitWidth,
              ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
            child: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              buttonSize: 46.0,
              icon: Icon(
                Icons.notifications_outlined,
                color: Color.fromARGB(255, 75, 57, 239),
                size: 24.0,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationPage()));
              },
            ),
          ),
          Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 16.0, 10.0),
              child: Container(
                width: 60,
                // height: 20,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      backgroundColor: Color.fromARGB(255, 75, 57, 239),
                      // maximumSize: Size(40, 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SosButtonPage()),
                      );
                    },
                    child: Text(
                      'SOS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              )),
          Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 16.0, 10.0),
              child: Container(
                width: 70,
                // height: 20,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      backgroundColor: Color.fromARGB(255, 75, 57, 239),

                      // maximumSize: Size(40, 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatBotScreen()),
                      );
                    },
                    child: Text(
                      'MindBot',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    )),
              )),
        ],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHomePage,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Color(0x3A000000),
                      offset: Offset(0.0, 1.0),
                    )
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  6.0, 4.0, 0.0, 2.0),
                              child: StreamBuilder<List<UserStoriesRecord>>(
                                  stream: queryUserStoriesRecord(
                                    queryBuilder: (userStoriesRecord) =>
                                        userStoriesRecord
                                            .where('user', isEqualTo: userRef)
                                            .orderBy('storyPostedAt',
                                                descending: true),
                                    limit: 20,
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center();
                                    }
                                    List<UserStoriesRecord>
                                        listViewUserStoriesRecordList =
                                        snapshot.data!;

                                    return StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .where('uid',
                                                isEqualTo: currentUser?.uid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Container();
                                          }
                                          if (snapshot.error != null) {
                                            return const Center(
                                              child: Text(
                                                  'Error loading stories...'),
                                            );
                                          }

                                          final userdata =
                                              snapshot.data!.docs.first;
                                          final userInfo = userdata.data() as Map<
                                              String,
                                              dynamic>; // Explicitly cast to the correct type

                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              listViewUserStoriesRecordList
                                                      .isEmpty
                                                  ? context.pushNamed(
                                                      'createStory',
                                                      extra: <String, dynamic>{
                                                        kTransitionInfoKey:
                                                            TransitionInfo(
                                                          hasTransition: true,
                                                          transitionType:
                                                              PageTransitionType
                                                                  .bottomToTop,
                                                          duration: Duration(
                                                              milliseconds: 20),
                                                        ),
                                                      },
                                                    )
                                                  : context.pushNamed(
                                                      'storyDetails',
                                                      queryParameters: {
                                                        'initialStoryIndex':
                                                            serializeParam(0,
                                                                ParamType.int),
                                                        'userId':
                                                            serializeParam(
                                                                currentUser
                                                                    ?.uid,
                                                                ParamType
                                                                    .String),
                                                      }.withoutNulls,
                                                      extra: <String, dynamic>{
                                                        kTransitionInfoKey:
                                                            TransitionInfo(
                                                          hasTransition: true,
                                                          transitionType:
                                                              PageTransitionType
                                                                  .bottomToTop,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  200),
                                                        ),
                                                      },
                                                    );
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 33,
                                                          backgroundColor:
                                                              Colors.grey[400],
                                                        ),
                                                        Positioned(
                                                          right: 1,
                                                          bottom: 1,
                                                          child: CircleAvatar(
                                                            radius: 32,
                                                            foregroundImage: userInfo[
                                                                        'photo_url'] !=
                                                                    null
                                                                ? NetworkImage(
                                                                    userInfo[
                                                                        'photo_url']!)
                                                                : null,
                                                            child: const Icon(
                                                                Icons.person),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // ),
                                                    listViewUserStoriesRecordList
                                                            .isEmpty
                                                        ? const Positioned(
                                                            bottom: 2,
                                                            right: 2,
                                                            child: CircleAvatar(
                                                              radius: 8,
                                                              backgroundColor:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          6,
                                                                          130,
                                                                          231),
                                                              child: Icon(
                                                                Icons.add,
                                                                size: 16,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }),
                            ),
                            Container(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 4.0, 0.0, 8.0),
                                child: StreamBuilder<List<UserStoriesRecord>>(
                                  stream: getStoriesStream(userRefs),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text('..'),
                                        ),
                                      );
                                    }
                                    List<UserStoriesRecord>
                                        listViewUserStoriesRecord =
                                        snapshot.data!;

                                    final List<UserStoriesRecord>
                                        unviewedStories = [];
                                    final List<UserStoriesRecord>
                                        viewedStories = [];

                                    for (final listViewUserStoriesRecord
                                        in listViewUserStoriesRecord) {
                                      if (listViewUserStoriesRecord.views
                                          .contains(currentUserUid)) {
                                        viewedStories
                                            .add(listViewUserStoriesRecord);
                                      } else {
                                        unviewedStories
                                            .add(listViewUserStoriesRecord);
                                      }
                                    }

                                    // Combine unviewed and viewed stories in the desired order
                                    final List<UserStoriesRecord>
                                        listViewUserStoriesRecordList = [
                                      ...unviewedStories,
                                      ...viewedStories
                                    ];

                                    //STREAMS
                                    final userData = snapshot.data!;
                                    final people = userData.isNotEmpty
                                        ? userData.map((userRecord) {
                                            if (userRecord.user != null &&
                                                userRecord.user
                                                    is DocumentReference) {
                                              return userRecord.user!.id;
                                            }
                                            return '';
                                          }).toList()
                                        : [];

                                    final List<Stream<QuerySnapshot>>
                                        queryStreams = [];
                                    const int batchSize = 10;

                                    for (int i = 0;
                                        i < people.length;
                                        i += batchSize) {
                                      final batchIds = people
                                          .skip(i)
                                          .take(batchSize)
                                          .toList();

                                      var queryStream = FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .where('uid', whereIn: batchIds)
                                          .snapshots();

                                      queryStreams.add(queryStream);
                                      print(batchIds);
                                    }
                                    // STREAMS

                                    if (listViewUserStoriesRecordList.isEmpty) {
                                      return Center(
                                        child: Image.asset(
                                          'assets/images/y20dh_',
                                          width: 60.0,
                                        ),
                                      );
                                    }
                                    return StreamBuilder<List<QuerySnapshot>>(
                                        stream: CombineLatestStream.list(
                                            queryStreams),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return const Center(
                                              child: Text('No Stories updates'),
                                            );
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          }
                                          if (snapshot.error != null) {
                                            return const Center(
                                              child: Text('Error.'),
                                            );
                                          }

                                          final List<Story> stories = snapshot
                                              .data!
                                              .expand((querySnapshot) {
                                                return querySnapshot.docs
                                                    .map((doc) {
                                                  return Story(
                                                    username: doc['userName'],
                                                    profile: doc['photo_url'],
                                                    userid: doc['uid'],
                                                  );
                                                });
                                              })
                                              .cast<Story>()
                                              .toList();

                                          // Sort the stories based on whether they have been viewed

                                          return ListView.builder(
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: stories.length,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder:
                                                (context, listViewIndex) {
                                              final listViewUserStoriesRecord =
                                                  listViewUserStoriesRecordList[
                                                      listViewIndex];
                                              return stories[listViewIndex]
                                                          .userid ==
                                                      currentUser?.uid
                                                  ? Container()
                                                  : Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  0.0,
                                                                  8.0,
                                                                  0.0),
                                                      child: StreamBuilder<
                                                          UsersRecord>(
                                                        stream: listViewUserStoriesRecord
                                                                    .user !=
                                                                null
                                                            ? UsersRecord
                                                                .getDocument(
                                                                    listViewUserStoriesRecord
                                                                        .user!)
                                                            : null,
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center();
                                                          }
                                                          // ignore: unused_local_variable
                                                          final columnUsersRecord =
                                                              snapshot.data!;
                                                          DocumentReference
                                                              userRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(stories[
                                                                          listViewIndex]
                                                                      .userid);
                                                          return StreamBuilder<
                                                                  QuerySnapshot>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'userStories')
                                                                  // .where(
                                                                  //     'storyPostedAt',
                                                                  //     isGreaterThan:
                                                                  //         tenDaysAgoTimestamp)
                                                                  .where('user',
                                                                      isEqualTo:
                                                                          userRef)
                                                                  .orderBy(
                                                                      'storyPostedAt',
                                                                      descending:
                                                                          true) // Sort by timestamp in descending order
                                                                  .limit(
                                                                      1) // Limit the result to only the latest document
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                        .hasData ||
                                                                    snapshot
                                                                        .data!
                                                                        .docs
                                                                        .isEmpty) {
                                                                  return const Center(
                                                                    child: Text(
                                                                        '..'),
                                                                  );
                                                                }
                                                                if (snapshot
                                                                        .error !=
                                                                    null) {
                                                                  return const Center(
                                                                    child: Text(
                                                                        'Error loading data...'),
                                                                  );
                                                                }

                                                                final latestStoryDoc =
                                                                    snapshot
                                                                        .data!
                                                                        .docs
                                                                        .first;
                                                                final latestStoryData =
                                                                    latestStoryDoc
                                                                            .data()
                                                                        as Map<
                                                                            String,
                                                                            dynamic>;

                                                                final List<
                                                                        String>
                                                                    viewList =
                                                                    [];
                                                                if (latestStoryData[
                                                                        'views'] !=
                                                                    null) {
                                                                  viewList.addAll(List<
                                                                          String>.from(
                                                                      latestStoryData[
                                                                          'views']));
                                                                }

                                                                bool isViewed =
                                                                    viewList.contains(
                                                                        currentUser
                                                                            ?.uid);

                                                                return InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    // print(
                                                                    //     'DEGBBTRG110101011: ${stories[listViewIndex].userid}');
                                                                    // print(
                                                                    //     'DEGBBTRG110101011: ${stories[listViewIndex].username}');
                                                                    context
                                                                        .pushNamed(
                                                                      'storyDetails',
                                                                      queryParameters:
                                                                          {
                                                                        'initialStoryIndex': serializeParam(
                                                                            0,
                                                                            ParamType.int),
                                                                        'userId': serializeParam(
                                                                            stories[listViewIndex].userid,
                                                                            ParamType.String),
                                                                        'userName': serializeParam(
                                                                            stories[listViewIndex].username,
                                                                            ParamType.String),
                                                                      }.withoutNulls,
                                                                      extra: <String,
                                                                          dynamic>{
                                                                        kTransitionInfoKey:
                                                                            TransitionInfo(
                                                                          hasTransition:
                                                                              true,
                                                                          transitionType:
                                                                              PageTransitionType.bottomToTop,
                                                                          duration:
                                                                              Duration(milliseconds: 200),
                                                                        ),
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Stack(
                                                                        children: [
                                                                          CircleAvatar(
                                                                            radius:
                                                                                30,
                                                                            backgroundColor: !isViewed
                                                                                ? Color(0xFF4B39EF)
                                                                                : const Color.fromARGB(0, 255, 193, 7),
                                                                          ),
                                                                          Positioned(
                                                                            bottom:
                                                                                2,
                                                                            right:
                                                                                2,
                                                                            child:
                                                                                CircleAvatar(
                                                                              radius: 28,
                                                                              backgroundColor: Theme.of(context).cardColor,
                                                                            ),
                                                                          ),
                                                                          Positioned(
                                                                            bottom:
                                                                                4,
                                                                            right:
                                                                                4,
                                                                            child:
                                                                                CircleAvatar(
                                                                              radius: 26,
                                                                              foregroundImage: stories[listViewIndex].profile.isNotEmpty ? NetworkImage(stories[listViewIndex].profile) : null,
                                                                              child: const Icon(Icons.person),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            4.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            stories[listViewIndex].username,
                                                                            '',
                                                                          ).maybeHandleOverflow(
                                                                            maxChars:
                                                                                8,
                                                                            replacement:
                                                                                '…',
                                                                          ),
                                                                          // style: TextStyle(
                                                                          //   fontSize: 6,
                                                                          //   fontFamily:
                                                                          //           'Urbanist'
                                                                          // )
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Urbanist',
                                                                                fontSize: 10.0,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              });
                                                        },
                                                      ),
                                                    );
                                            },
                                          );
                                        });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(socialFeedUserPostsRecordList.length,
                      (socialFeedIndex) {
                    final socialFeedUserPostsRecord =
                        socialFeedUserPostsRecordList[socialFeedIndex];

                    return Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 8.0),
                      child: StreamBuilder<UsersRecord>(
                        stream: socialFeedUserPostsRecord.postUser != null
                            ? UsersRecord.getDocument(
                                socialFeedUserPostsRecord.postUser!)
                            : null,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center();
                          }
                          final userPostUsersRecord = snapshot.data!;
                          final userid = userPostUsersRecord.uid;

                          List? friendsList = userPostUsersRecord.minders !=
                                  null
                              ? List.from(
                                  userPostUsersRecord.minders as Iterable)
                              : <String>[]; // Initialize to an empty list if 'friends' is null
                          bool isFriend =
                              friendsList.contains(currentUser?.uid);

                          return Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x32000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  'postDetails',
                                  queryParameters: {
                                    'userRecord': serializeParam(
                                      userPostUsersRecord,
                                      ParamType.Document,
                                    ),
                                    'postReference': serializeParam(
                                      socialFeedUserPostsRecord.reference,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                  extra: <String, dynamic>{
                                    'userRecord': userPostUsersRecord,
                                  },
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 2.0, 4.0),
                                    child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection(
                                                'mental_health_professionals')
                                            // .where('isUser', isEqualTo: true)
                                            // .where('userid', isEqualTo: userid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Center();
                                          }
                                          if (snapshot.error != null) {
                                            return const Center(
                                              child:
                                                  Text('Error loading data...'),
                                            );
                                          }
                                          final userdata = snapshot.data!.docs;
                                          // bool isUsernameTaken = false;

                                          final existingUser =
                                              Set<String>.from(userdata.map(
                                            (doc) => (doc.data() as Map<String,
                                                    dynamic>)['id']
                                                .toString(),
                                          ));
                                          bool isProfessional =
                                              existingUser.contains(userid);

                                          return Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PublicProfile(
                                                                userid: userid,
                                                                isProfessional:
                                                                    isProfessional,
                                                              )));
                                                },
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Card(
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        color:
                                                            Color(0xFF4B39EF),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      1.0,
                                                                      1.0,
                                                                      1.0,
                                                                      1.0),
                                                          child: Container(
                                                            width: 40.0,
                                                            height: 40.0,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  valueOrDefault<
                                                                      String>(
                                                                userPostUsersRecord
                                                                    .photoUrl,
                                                                'https://firebasestorage.googleapis.com/v0/b/mindmates-d4849.appspot.com/o/assets%2Fuser.png?alt=media&token=aae6bfd5-7111-4126-bbb8-a8a101e9a414&_gl=1*vljsel*_ga*MjI5MDQxMTIwLjE2OTc1MzAxNTE.*_ga_CW55HF8NVT*MTY5NzYzMDI0Ni43LjEuMTY5NzYzMDI3Ni4zMC4wLjA.',
                                                              ),
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Text(
                                                        valueOrDefault<String>(
                                                          userPostUsersRecord
                                                              .userName,
                                                          '',
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium,
                                                      ),
                                                    ),
                                                    isProfessional
                                                        ? Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        6.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Icon(
                                                              Icons.verified,
                                                              color: Color(
                                                                  0xFF12CCEE),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                              FlutterFlowIconButton(
                                                borderColor: Colors.transparent,
                                                borderRadius: 30.0,
                                                buttonSize: 46.0,
                                                icon: Icon(
                                                  Icons.keyboard_control,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .time,
                                                  size: 20.0,
                                                ),
                                                onPressed: () {
                                                  showModalBottomSheet<void>(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      //          Navigator.pop(
                                                      // context);
                                                      return socialFeedUserPostsRecord
                                                                  .postUser
                                                                  ?.id ==
                                                              currentUser?.uid
                                                          ? UserPostMenu(
                                                              canComment:
                                                                  socialFeedUserPostsRecord
                                                                      .canComment,
                                                              docid:
                                                                  socialFeedUserPostsRecord
                                                                      .reference,
                                                              username:
                                                                  userPostUsersRecord
                                                                      .userName,
                                                            )
                                                          : PostMenu(
                                                              canComment:
                                                                  socialFeedUserPostsRecord
                                                                      .canComment,
                                                              docid:
                                                                  socialFeedUserPostsRecord
                                                                      .reference,
                                                              username:
                                                                  userPostUsersRecord
                                                                      .userName,
                                                              isFriend:
                                                                  isFriend,
                                                              userid:
                                                                  socialFeedUserPostsRecord
                                                                      .postUser
                                                                      ?.id,
                                                            );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                  FlutterFlowMediaDisplay(
                                    path: socialFeedUserPostsRecord.postPhoto,
                                    imageBuilder: (path) => CachedNetworkImage(
                                      imageUrl: path,
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 300.0,
                                      fit: BoxFit.cover,
                                    ),
                                    videoPlayerBuilder: (path) =>
                                        FlutterFlowVideoPlayer(
                                      // aspectRatio:  _videoPlayerController
                                      //               .value
                                      //               .aspectRatio ??
                                      //           16 / 9,
                                      path: path,
                                      width: MediaQuery.of(context).size.width *
                                          1.0,
                                      autoPlay: true,
                                      looping: false,
                                      showControls: false,
                                      allowFullScreen: false,
                                      allowPlaybackSpeedMenu: false,
                                      height: 300,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 4.0, 8.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .doc(
                                                        'userPosts/${socialFeedUserPostsRecord.reference.id}')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData ||
                                                      !snapshot.data!.exists) {
                                                    return Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 30, 0, 0),
                                                        child: const Text('0'),
                                                      ),
                                                    );
                                                  }
                                                  if (snapshot.error != null) {
                                                    return Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 30, 0, 0),
                                                        child:
                                                            const Text('...'),
                                                      ),
                                                    );
                                                  }

                                                  final likesInfo = snapshot
                                                          .data!
                                                          .data()
                                                      as Map<String, dynamic>;
                                                  int likes =
                                                      likesInfo['likes'].length;

                                                  bool isLiked = likesInfo[
                                                          'likes']
                                                      .contains(
                                                          currentUserReference);
                                                  // Your widget code here using 'isLiked' or other data.

                                                  return Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                16.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 41.0,
                                                          height: 41.0,
                                                          child: Stack(
                                                            children: [
                                                              if (!isLiked)
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.25),
                                                                  child: InkWell(
                                                                      splashColor: Colors.transparent,
                                                                      focusColor: Colors.transparent,
                                                                      hoverColor: Colors.transparent,
                                                                      highlightColor: Colors.transparent,
                                                                      onTap: () async {
                                                                        print(
                                                                            currentUserReference);
                                                                        print(socialFeedUserPostsRecord
                                                                            .reference);
                                                                        await socialFeedUserPostsRecord
                                                                            .reference
                                                                            .update({
                                                                          'likes':
                                                                              FieldValue.arrayUnion([
                                                                            currentUserReference
                                                                          ]),
                                                                        });
                                                                        // setState(() {
                                                                        //   isLiked =
                                                                        //       true;
                                                                        // });
                                                                      },
                                                                      child: Icon(
                                                                        isLiked
                                                                            ? Icons.favorite
                                                                            : Icons.favorite_outline_outlined,
                                                                        color: isLiked
                                                                            ? Color(0xFF4B39EF)
                                                                            : FlutterFlowTheme.of(context).mineIcon,
                                                                        size:
                                                                            24.0,
                                                                      )),
                                                                ),
                                                              if (isLiked)
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.25),
                                                                  child: InkWell(
                                                                      splashColor: Colors.transparent,
                                                                      focusColor: Colors.transparent,
                                                                      hoverColor: Colors.transparent,
                                                                      highlightColor: Colors.transparent,
                                                                      onTap: () async {
                                                                        await socialFeedUserPostsRecord
                                                                            .reference
                                                                            .update({
                                                                          'likes':
                                                                              FieldValue.arrayRemove([
                                                                            currentUserReference
                                                                          ]),
                                                                        });
                                                                        // setState(() {
                                                                        //   isLiked =
                                                                        //       false;
                                                                        // });
                                                                      },
                                                                      child: Icon(
                                                                        isLiked
                                                                            ? Icons.favorite
                                                                            : Icons.favorite_outline_outlined,
                                                                        color: isLiked
                                                                            ? Color(0xFF4B39EF)
                                                                            : FlutterFlowTheme.of(context).mineIcon,
                                                                        size:
                                                                            24.0,
                                                                      )),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      4.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            valueOrDefault<
                                                                String>(
                                                              // functions
                                                              //     .likes(
                                                              //         socialFeedUserPostsRecord)
                                                              //     .toString(),
                                                              likes.toString(),
                                                              '0',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Lexend Deca',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .time,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.mode_comment_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .mineIcon,
                                                  size: 24.0,
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          4.0, 0.0, 0.0, 0.0),
                                                  child: Text(
                                                    socialFeedUserPostsRecord
                                                        .numComments
                                                        .toString(),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              'Lexend Deca',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .time,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 2.0, 8.0, 0.0),
                                              child: Text(
                                                dateTimeFormat(
                                                    'relative',
                                                    socialFeedUserPostsRecord
                                                        .timePosted!),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium,
                                              ),
                                            ),
                                            Icon(
                                              Icons.ios_share,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .time,
                                              size: 24.0,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        2.0, 4.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    12.0, 0.0, 12.0, 12.0),
                                            child: Text(
                                              valueOrDefault<String>(
                                                socialFeedUserPostsRecord
                                                    .postDescription,
                                                ' ',
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Story {
  final String username;
  final String profile;
  final String userid;

  Story({
    required this.username,
    required this.profile,
    required this.userid,
  });
}

class userPostsRecord {
  userPostsRecord();
}
