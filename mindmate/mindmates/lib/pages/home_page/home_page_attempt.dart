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
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
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
  List<UserPostsRecord> postData = [];
  List<UserPostsRecord> shuffle = [];

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
   
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay
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
                width: 120.0,
                height: 50.0,
                fit: BoxFit.fitWidth,
              ),
            if (Theme.of(context).brightness == Brightness.dark)
              Image.asset(
                'assets/images/mindmate.png',
                width: 120.0,
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
                            builder: (context) => ChatBotScreen()),
                      );
                    },
                    child: Text(
                      'MindBot',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                  color: Colors.white,
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
                      height: 76.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Row(
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
                                            child:
                                                Text('Error loading stories...'),
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
                                            listViewUserStoriesRecordList.isEmpty
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
                                                          serializeParam(
                                                              0, ParamType.int),
                                                      'userId': serializeParam(
                                                          currentUser?.uid,
                                                          ParamType.String),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      kTransitionInfoKey:
                                                          TransitionInfo(
                                                        hasTransition: true,
                                                        transitionType:
                                                            PageTransitionType
                                                                .bottomToTop,
                                                        duration: Duration(
                                                            milliseconds: 200),
                                                      ),
                                                    },
                                                  );
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Stack(
                                                children: [
                                                  // Container(
                                                  //   width: 50.0,
                                                  //   height: 50.0,
                                                  //   clipBehavior: Clip.antiAlias,
                                                  //   decoration: BoxDecoration(
                                                  //     shape: BoxShape.circle,
                                                  //   ),
                                                  //   child:
                                                  CircleAvatar(
                                                    radius: 24,
                                                    foregroundImage:
                                                        userInfo['photo_url'] !=
                                                                null
                                                            ? NetworkImage(
                                                                userInfo[
                                                                    'photo_url']!)
                                                            : null,
                                                    child:
                                                        const Icon(Icons.person),
                                                  ),
                                                  // ),
                                                  listViewUserStoriesRecordList
                                                          .isEmpty
                                                      ? const Positioned(
                                                          bottom: 1,
                                                          right: 1,
                                                          child: CircleAvatar(
                                                            radius: 8,
                                                            backgroundColor:
                                                                Color.fromARGB(
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
                                              listViewUserStoriesRecordList
                                                      .isEmpty
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(0.0, 2.0,
                                                                  0.0, 0.0),
                                                      child: AutoSizeText(
                                                        valueOrDefault<String>(
                                                          '',
                                                          '',
                                                        ).maybeHandleOverflow(
                                                          maxChars: 8,
                                                          replacement: '…',
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 12.0,
                                                                ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        );
                                      });
                                }),
                          ),
                          Expanded(
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
                                      listViewUserStoriesRecordList =
                                      snapshot.data!;
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
      
                                  final List<Stream<QuerySnapshot>> queryStreams =
                                      [];
                                  const int batchSize = 10;
      
                                  for (int i = 0;
                                      i < people.length;
                                      i += batchSize) {
                                    final batchIds =
                                        people.skip(i).take(batchSize).toList();
      
                                    var queryStream = FirebaseFirestore.instance
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
                                      stream:
                                          CombineLatestStream.list(queryStreams),
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
      
                                        final List<Story> stories = snapshot.data!
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
      
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: stories.length,
                                          itemBuilder: (context, listViewIndex) {
                                            final listViewUserStoriesRecord =
                                                listViewUserStoriesRecordList[
                                                    listViewIndex];
                                            return stories[listViewIndex]
                                                        .userid ==
                                                    currentUser?.uid
                                                ? Container()
                                                : Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            8.0, 0.0, 8.0, 0.0),
                                                    child: StreamBuilder<
                                                        UsersRecord>(
                                                      stream: listViewUserStoriesRecord
                                                                  .user !=
                                                              null
                                                          ? UsersRecord.getDocument(
                                                              listViewUserStoriesRecord
                                                                  .user!)
                                                          : null,
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return Center();
                                                        }
                                                        // ignore: unused_local_variable
                                                        final columnUsersRecord =
                                                            snapshot.data!;
                                                        return InkWell(
                                                          splashColor:
                                                              Colors.transparent,
                                                          focusColor:
                                                              Colors.transparent,
                                                          hoverColor:
                                                              Colors.transparent,
                                                          highlightColor:
                                                              Colors.transparent,
                                                          onTap: () async {
                                                            // print(
                                                            //     'DEGBBTRG110101011: ${stories[listViewIndex].userid}');
                                                            // print(
                                                            //     'DEGBBTRG110101011: ${stories[listViewIndex].username}');
                                                            context.pushNamed(
                                                              'storyDetails',
                                                              queryParameters: {
                                                                'initialStoryIndex':
                                                                    serializeParam(
                                                                        0,
                                                                        ParamType
                                                                            .int),
                                                                'userId': serializeParam(
                                                                    stories[listViewIndex]
                                                                        .userid,
                                                                    ParamType
                                                                        .String),
                                                                'userName': serializeParam(
                                                                    stories[listViewIndex]
                                                                        .username,
                                                                    ParamType
                                                                        .String),
                                                              }.withoutNulls,
                                                              extra: <String,
                                                                  dynamic>{
                                                                kTransitionInfoKey:
                                                                    TransitionInfo(
                                                                  hasTransition:
                                                                      true,
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
                                                            mainAxisSize:
                                                                MainAxisSize.max,
                                                            children: [
                                                              Container(
                                                                width: 40.0,
                                                                height: 40.0,
                                                                clipBehavior: Clip
                                                                    .antiAlias,
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
                                                                    stories[listViewIndex]
                                                                        .profile,
                                                                    'https://firebasestorage.googleapis.com/v0/b/mindmates-d4849.appspot.com/o/assets%2Fuser.png?alt=media&token=aae6bfd5-7111-4126-bbb8-a8a101e9a414&_gl=1*8lrrcz*_ga*MTE4Mzc0MjA2Ni4xNjc1NDE5OTQw*_ga_CW55HF8NVT*MTY5NjQzMzM4Ni4xNDUuMS4xNjk2NDMzNDA1LjQxLjAuMA..',
                                                                  ),
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            4.0,
                                                                            0.0,
                                                                            0.0),
                                                                child: Text(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    stories[listViewIndex]
                                                                        .username,
                                                                    '',
                                                                  ).maybeHandleOverflow(
                                                                    maxChars: 8,
                                                                    replacement:
                                                                        '…',
                                                                  ),
                                                                  // style: TextStyle(
                                                                  //   fontSize: 6,
                                                                  //   fontFamily:
                                                                  //           'Urbanist'
                                                                  // )
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            10.0,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
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
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                child: StreamBuilder<List<UserPostsRecord>>(
                  stream: queryUserPostsRecord(
                    queryBuilder: (userPostsRecord) => userPostsRecord
                        .where('timePosted', isGreaterThan: tenDaysAgoTimestamp),
                    limit: 50,
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center();
                    }
                    List<UserPostsRecord> socialFeedUserPostsRecordList =
                        snapshot.data!;
      
                    if (socialFeedUserPostsRecordList.isEmpty) {
                      return Center(
                        child: Image.asset(
                          'assets/images/emptyPosts@2x.png',
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          height: 400.0,
                        ),
                      );
                    }
                    // Fetch the list of following IDs
                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('uid', isEqualTo: currentUser?.uid)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Container(
                                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                                  child: const Text('No posted.')),
                            );
                          }
      
                          // List<String> followingIDs = followingSnapshot.data!;
                          final doc = snapshot.data!.docs
                              .firstWhere((doc) => doc.id == currentUser?.uid);
      
                          final data = doc.data() as Map<String, dynamic>;
      
                          final followIds = data['minding'];
                          print(
                              '99844All dvjfninf dfsgifn:  ${followIds.length}');
      
                          // Fetch the list of random IDs
      
                          // final List<Stream<QuerySnapshot>> queryStreams = [];
                          // final int batchSize = 10;
      
                          // for (int i = 0; i < followIds.length; i += batchSize) {
                          //   final batchIds =
                          //       followIds.skip(i).take(batchSize).toList();
                          //   final queryStream = FirebaseFirestore.instance
                          //       .collection('users')
                          //       // .where('uid', whereNotIn: batchIds)
                          //       .snapshots();
      
                          //   queryStreams.add(queryStream);
                          //   print(batchIds);
                          // }
      
                          return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  // .where('uid', isEqualTo: currentUser?.uid)
                                  .snapshots(),
                              builder:
                                  (BuildContext context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 30, 0, 0),
                                        child: const Text('No posted.')),
                                  );
                                }
      
                                // List<String> followingIDs = snapshot.data!;
                                final docs = snapshot.data!.docs;
                                final random = Random();
                                docs.shuffle(random);
      
                                List<String> randomIDs = [];
                                num limit = 40 - followIds.length;
      
                                if (followIds.length < 30)
                                  for (final doc in docs.take(limit)) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final userID = data['uid']
                                        as String; // Assuming 'uid' is the field name containing a single user ID
      
                                    // Add the user ID from the current document to the randomIDs list
                                    randomIDs.add(userID);
                                  }
      
                                print(
                                    '99844All dvjfninf dfsgifn:  ${randomIDs.length}');
                                // final List<String> randomIDs =
                                //     snapshot.data!.take(20).map((querySnapshot) {
                                //   // Extract the desired data from the querySnapshot and return it as a String
                                //   // Replace `field` with the appropriate field or property you want to extract from the querySnapshot
                                //   return querySnapshot.toString();
                                // }).toList();
                                print(
                                    'All dvjfninf dfsgifn:  ${randomIDs.length}');
                                // Print the length of the initial data
                                print(
                                    'Initial List Length: ${socialFeedUserPostsRecordList.length}');
      
      //                              List<UserPostsRecord> socialFeedUserPostsRecordList = ... // Your data source
      // List<String> followIds = ... // Your list of following IDs
      // List<String> randomIDs = ... // Your list of random IDs
      
      // Filter records based on followIds
                                List<UserPostsRecord> followRecords =
                                    socialFeedUserPostsRecordList
                                        .where((record) => followIds
                                            .contains(record.postUser?.id))
                                        .toList();
      
      // Filter records based on randomIDs and not in followIds
                                List<UserPostsRecord> randomRecords =
                                    socialFeedUserPostsRecordList
                                        .where((record) =>
                                            randomIDs
                                                .contains(record.postUser?.id) &&
                                            !followIds
                                                .contains(record.postUser?.id))
                                        .toList();
      
      // Combine the filtered records
                                List<UserPostsRecord> combinedList = [
                                  ...followRecords,
                                  ...randomRecords
                                ];
      
      // Shuffle the combined list
      
                                combinedList.shuffle();
                                socialFeedUserPostsRecordList = combinedList;
      
                                print(
                                    'Combined and Shuffled List Length: ${combinedList.length}');
      
                                print(
                                    'Filtered and Shuffled List Length: ${socialFeedUserPostsRecordList.length}');
      
                                // print(
                                //     '66666666666666666666666666666666666666666666666666All dvjfninf dfsgifn:  ${uniqueFilteredList.length}');
      
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: List.generate(
                                      socialFeedUserPostsRecordList.length,
                                      (socialFeedIndex) {
                                    final socialFeedUserPostsRecord =
                                        socialFeedUserPostsRecordList[
                                            socialFeedIndex];
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 8.0),
                                      child: StreamBuilder<UsersRecord>(
                                        stream:
                                            socialFeedUserPostsRecord.postUser !=
                                                    null
                                                ? UsersRecord.getDocument(
                                                    socialFeedUserPostsRecord
                                                        .postUser!)
                                                : null,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center();
                                          }
                                          final userPostUsersRecord =
                                              snapshot.data!;
                                          final userid = userPostUsersRecord.uid;
      
                                          List? friendsList = userPostUsersRecord
                                                      .minders !=
                                                  null
                                              ? List.from(userPostUsersRecord
                                                  .minders as Iterable)
                                              : <String>[]; // Initialize to an empty list if 'friends' is null
                                          bool isFriend = friendsList
                                              .contains(currentUser?.uid);
      
                                          return Container(
                                            width:
                                                MediaQuery.sizeOf(context).width *
                                                    1.0,
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
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
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
                                                    'postReference':
                                                        serializeParam(
                                                      socialFeedUserPostsRecord
                                                          .reference,
                                                      ParamType.DocumentReference,
                                                    ),
                                                  }.withoutNulls,
                                                  extra: <String, dynamic>{
                                                    'userRecord':
                                                        userPostUsersRecord,
                                                  },
                                                );
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 8.0, 2.0, 4.0),
                                                    child: StreamBuilder<
                                                            QuerySnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'mental_health_professionals')
                                                            // .where('isUser', isEqualTo: true)
                                                            // .where('userid', isEqualTo: userid)
                                                            .snapshots(),
                                                        builder:
                                                            (context, snapshot) {
                                                          if (!snapshot.hasData ||
                                                              snapshot.data!.docs
                                                                  .isEmpty) {
                                                            return const Center();
                                                          }
                                                          if (snapshot.error !=
                                                              null) {
                                                            return const Center(
                                                              child: Text(
                                                                  'Error loading data...'),
                                                            );
                                                          }
                                                          final userdata =
                                                              snapshot.data!.docs;
                                                          // bool isUsernameTaken = false;
      
                                                          final existingUser =
                                                              Set<String>.from(
                                                                  userdata.map(
                                                            (doc) => (doc.data()
                                                                    as Map<String,
                                                                        dynamic>)['id']
                                                                .toString(),
                                                          ));
                                                          bool isProfessional =
                                                              existingUser
                                                                  .contains(
                                                                      userid);
      
                                                          return Row(
                                                            mainAxisSize:
                                                                MainAxisSize.max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(
                                                                          builder: (context) => PublicProfile(
                                                                                userid: userid,
                                                                                isProfessional: isProfessional,
                                                                              )));
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              8.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                      child: Card(
                                                                        clipBehavior:
                                                                            Clip.antiAliasWithSaveLayer,
                                                                        color: Color(
                                                                            0xFF4B39EF),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20.0),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              1.0,
                                                                              1.0,
                                                                              1.0,
                                                                              1.0),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                40.0,
                                                                            height:
                                                                                40.0,
                                                                            clipBehavior:
                                                                                Clip.antiAlias,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape:
                                                                                  BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              imageUrl:
                                                                                  valueOrDefault<String>(
                                                                                userPostUsersRecord.photoUrl,
                                                                                'https://firebasestorage.googleapis.com/v0/b/mindmates-d4849.appspot.com/o/assets%2Fuser.png?alt=media&token=aae6bfd5-7111-4126-bbb8-a8a101e9a414&_gl=1*8lrrcz*_ga*MTE4Mzc0MjA2Ni4xNjc1NDE5OTQw*_ga_CW55HF8NVT*MTY5NjQzMzM4Ni4xNDUuMS4xNjk2NDMzNDA1LjQxLjAuMA..',
                                                                              ),
                                                                              fit:
                                                                                  BoxFit.fitWidth,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              12.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                      child: Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          userPostUsersRecord
                                                                              .userName,
                                                                          '',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(
                                                                                context)
                                                                            .titleMedium,
                                                                      ),
                                                                    ),
                                                                    isProfessional
                                                                        ? Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                6.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.verified,
                                                                              color:
                                                                                  Color(0xFF12CCEE),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                  ],
                                                                ),
                                                              ),
                                                              FlutterFlowIconButton(
                                                                borderColor: Colors
                                                                    .transparent,
                                                                borderRadius:
                                                                    30.0,
                                                                buttonSize: 46.0,
                                                                icon: Icon(
                                                                  Icons
                                                                      .keyboard_control,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                                  size: 20.0,
                                                                ),
                                                                onPressed: () {
                                                                  showModalBottomSheet<
                                                                      void>(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      //          Navigator.pop(
                                                                      // context);
                                                                      return socialFeedUserPostsRecord.postUser?.id ==
                                                                              currentUser?.uid
                                                                          ? UserPostMenu(
                                                                              canComment:
                                                                                  socialFeedUserPostsRecord.canComment,
                                                                              docid:
                                                                                  socialFeedUserPostsRecord.reference,
                                                                              username:
                                                                                  userPostUsersRecord.userName,
                                                                            )
                                                                          : PostMenu(
                                                                              canComment:
                                                                                  socialFeedUserPostsRecord.canComment,
                                                                              docid:
                                                                                  socialFeedUserPostsRecord.reference,
                                                                              username:
                                                                                  userPostUsersRecord.userName,
                                                                              isFriend:
                                                                                  isFriend,
                                                                              userid:
                                                                                  socialFeedUserPostsRecord.postUser?.id,
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
                                                    path:
                                                        socialFeedUserPostsRecord
                                                            .postPhoto,
                                                    imageBuilder: (path) =>
                                                        CachedNetworkImage(
                                                      imageUrl: path,
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1.0,
                                                      autoPlay: true,
                                                      looping: false,
                                                      showControls: false,
                                                      allowFullScreen: false,
                                                      allowPlaybackSpeedMenu:
                                                          false,
                                                      height: 300,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            8.0, 4.0, 8.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Container(
                                                                    width: 41.0,
                                                                    height: 41.0,
                                                                    child: Stack(
                                                                      children: [
                                                                        if (!socialFeedUserPostsRecord
                                                                            .likes
                                                                            .contains(
                                                                                currentUserReference))
                                                                          Align(
                                                                            alignment: AlignmentDirectional(
                                                                                0.0,
                                                                                0.25),
                                                                            child: InkWell(
                                                                                splashColor: Colors.transparent,
                                                                                focusColor: Colors.transparent,
                                                                                hoverColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  print(currentUserReference);
                                                                                  await socialFeedUserPostsRecord.reference.update({
                                                                                    'likes': FieldValue.arrayUnion([
                                                                                      currentUserReference
                                                                                    ]),
                                                                                  });
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.favorite_outline_outlined,
                                                                                  color: Color.fromARGB(255, 244, 246, 248),
                                                                                  size: 24.0,
                                                                                )),
                                                                          ),
                                                                        if (socialFeedUserPostsRecord
                                                                            .likes
                                                                            .contains(
                                                                                currentUserReference))
                                                                          Align(
                                                                            alignment: AlignmentDirectional(
                                                                                0.0,
                                                                                0.25),
                                                                            child: InkWell(
                                                                                splashColor: Colors.transparent,
                                                                                focusColor: Colors.transparent,
                                                                                hoverColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  await socialFeedUserPostsRecord.reference.update({
                                                                                    'likes': FieldValue.arrayRemove([
                                                                                      currentUserReference
                                                                                    ]),
                                                                                  });
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.favorite,
                                                                                  color: Color(0xFF4B39EF),
                                                                                  size: 24.0,
                                                                                )),
                                                                          ),
                                                                        //     Align(
                                                                        //   alignment:
                                                                        //       AlignmentDirectional(
                                                                        //           0.0,
                                                                        //           0.25),
                                                                        //   child: InkWell(
                                                                        //     splashColor: Colors
                                                                        //         .blue,
                                                                        //     focusColor: Colors
                                                                        //         .blue,
                                                                        //     hoverColor: Colors
                                                                        //         .blue,
                                                                        //     highlightColor:
                                                                        //         Colors
                                                                        //             .blue,
                                                                        //     onTap:
                                                                        //         () async {
                                                                        //       await socialFeedUserPostsRecord
                                                                        //           .reference
                                                                        //           .update({
                                                                        //         'likes':
                                                                        //             FieldValue
                                                                        //                 .arrayRemove([
                                                                        //           currentUserReference
                                                                        //         ]),
                                                                        //       });
                                                                        //     },
                                                                        //     child: Icon(Icons.favorite,
                                                                        //       color: Color(
                                                                        //           0xFF4B39EF),
                                                                        //       size: 24.0,
                                                                        //     )
      
                                                                        //   )
      
                                                                        // ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            4.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        functions
                                                                            .likes(
                                                                                socialFeedUserPostsRecord)
                                                                            .toString(),
                                                                        '0',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Lexend Deca',
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                244,
                                                                                246,
                                                                                248),
                                                                            fontSize:
                                                                                14.0,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .mode_comment_outlined,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          244,
                                                                          246,
                                                                          248),
                                                                  size: 24.0,
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
                                                                    socialFeedUserPostsRecord
                                                                        .numComments
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Lexend Deca',
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              244,
                                                                              246,
                                                                              248),
                                                                          fontSize:
                                                                              14.0,
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
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          2.0,
                                                                          8.0,
                                                                          0.0),
                                                              child: Text(
                                                                dateTimeFormat(
                                                                    'relative',
                                                                    socialFeedUserPostsRecord
                                                                        .timePosted!),
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .bodyMedium,
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.ios_share,
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      246,
                                                                      247,
                                                                      248),
                                                              size: 24.0,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            2.0, 4.0, 0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        12.0),
                                                            child: Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                socialFeedUserPostsRecord
                                                                    .postDescription,
                                                                ' ',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                );
                              });
                        });
                  },
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
