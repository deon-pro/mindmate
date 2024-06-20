import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindmates/auth/firebase_auth/auth_util.dart';
import 'package:mindmates/components/comments/comment_owner.dart';
import 'package:mindmates/flutter_flow/flutter_flow_media_display.dart';
import 'package:mindmates/flutter_flow/flutter_flow_video_player.dart';
import 'package:mindmates/pages/menu/reporting.dart';
import 'package:rxdart/rxdart.dart';

import '/backend/backend.dart';
import '/components/comments/comments_widget.dart';
import '/components/delete_story/delete_story_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// ignore: unused_import
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:share_plus/share_plus.dart';
import 'story_details_model.dart';
export 'story_details_model.dart';

class StoryDetailsWidget extends StatefulWidget {
  const StoryDetailsWidget({
    Key? key,
    this.initialStoryIndex,
    this.username,
    this.userId,
  }) : super(key: key);

  final int? initialStoryIndex;
  final String? userId;
  final String? username;

  @override
  _StoryDetailsWidgetState createState() => _StoryDetailsWidgetState();
}

class _StoryDetailsWidgetState extends State<StoryDetailsWidget> {
  late StoryDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final userAc = FirebaseAuth.instance.currentUser;
  int _currentStatusIndex = 0;
  List<int> progressList = [0];
  bool _isTimerPaused = false;
  Timer? _timer;
  int divideDuration = 6;
  int _timerSeconds = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StoryDetailsModel());
    Future.delayed(const Duration(milliseconds: 500), () {
      startTimer(); // Start the timer after a slight delay
    });
  }

  void _pauseTimer() {
    // Pause the timer
    setState(() {
      _isTimerPaused = true;
    });
  }

  void _unpauseTimer() {
    // Unpause the timer
    setState(() {
      _isTimerPaused = false;
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused) {
        if (_timerSeconds < divideDuration) {
          setState(() {
            _timerSeconds++;
            progressList.add(_timerSeconds);
          });
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _startTimer(List<UserStoriesRecord> statusUpdates) {
    int statusCount = statusUpdates.length;

    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      setState(() {
        if (!_isTimerPaused) {
          if (_currentStatusIndex < statusCount - 1) {
            _currentStatusIndex++;
            _model.pageViewController?.animateToPage(_currentStatusIndex,
                duration: const Duration(seconds: 1), curve: Curves.ease);
          } else {
            timer.cancel();

            if (_currentStatusIndex == statusCount - 1) {
              _popPage();
            }
          }
        }
      });
    });
    // }
  }

  // Function to pop the page
  void _popPage() {
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryDark,
      body: SafeArea(
        top: true,
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            // Expanded(
            //   child:
            StreamBuilder<List<UserStoriesRecord>>(
              stream: queryUserStoriesRecord(
                queryBuilder: (userStoriesRecord) => userStoriesRecord
                    .where('user',
                        isEqualTo: userRef) // Add the user ID filter here
                    .orderBy('storyPostedAt', descending: false),
                // limit: 20,
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  );
                }
                List<UserStoriesRecord> pageViewUserStoriesRecordList =
                    snapshot.data!;
                print(
                    'FCEDVF(LENGHT): ${pageViewUserStoriesRecordList.length}');
                return Container(
                  // width: double.infinity,
                  // height: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        height: 10,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: ListView.builder(
                            itemCount: pageViewUserStoriesRecordList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: (MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .9) /
                                          pageViewUserStoriesRecordList.length,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: index == _currentStatusIndex
                                          ? LinearProgressIndicator(
                                              value: _timerSeconds /
                                                  divideDuration, // Countdown from 6 seconds
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      115, 255, 255, 255),
                                              color: index ==
                                                      _currentStatusIndex
                                                  ? const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255) // Active dot color
                                                  : const Color.fromARGB(
                                                      115,
                                                      255,
                                                      255,
                                                      255), // Inactive dot color
                                            )
                                          : LinearProgressIndicator(
                                              value: 0,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      115, 255, 255, 255),
                                              color: index ==
                                                      _currentStatusIndex
                                                  ? const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255) // Active dot color
                                                  : const Color.fromARGB(
                                                      115,
                                                      255,
                                                      255,
                                                      255), // Inactive dot color
                                            ),
                                    ),
                                    const SizedBox(height: 5),
                                  ]));
                            }),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height - 50,
                        child: PageView.builder(
                          controller: _model.pageViewController ??=
                              PageController(
                                  initialPage: min(
                                      valueOrDefault<int>(
                                        widget.initialStoryIndex,
                                        0,
                                      ),
                                      pageViewUserStoriesRecordList.length -
                                          1)),
                          // scrollDirection: Axis.vertical,
                          onPageChanged: (index) {
                            // final docid = pageViewUserStoriesRecordList[index]
                            //     .reference
                            //     .id;
                            // final docid = status['id'] as String;
                            // // final type = status['type'] as String;
                            // // startTimer(); // Start the timer when the screen initializes
                            // print('45///////urguorbtuh445u096wu08h8h: $docid');
                            setState(() {
                              _currentStatusIndex = index;
                              _timerSeconds = 0;

                              _startTimer(pageViewUserStoriesRecordList);
                            });

                            // saveDocIdToSharedPreferences(docid);
                            // saveDocId(docid);
                          },
                          itemCount: pageViewUserStoriesRecordList.length,
                          itemBuilder: (context, pageViewIndex) {
                            final pageViewUserStoriesRecord =
                                pageViewUserStoriesRecordList[pageViewIndex];
                            if (_timer == null) {
                              _startTimer(pageViewUserStoriesRecordList);
                            }
                            widget.userId != currentUserUid
                                ? FirebaseFirestore.instance
                                    .collection('userStories')
                                    .doc(pageViewUserStoriesRecordList[
                                            pageViewIndex]
                                        .reference
                                        .id)
                                    .update({
                                    'views':
                                        FieldValue.arrayUnion([currentUserUid]),
                                  }).then((_) {
                                    print(
                                        'Successfully updated views for the first index');
                                  }).catchError((error) {
                                    print(
                                        'Error updating views for the first index: $error');
                                  })
                                : null;

                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.82,
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onLongPress: () {
                                          // Pause the timer when long-press starts
                                          _pauseTimer();
                                        },
                                        onLongPressEnd: (_) {
                                          // Unpause the timer when long-press ends
                                          _unpauseTimer();
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: FlutterFlowMediaDisplay(
                                            path: pageViewUserStoriesRecord
                                                .storyPhoto,
                                            imageBuilder: (path) =>
                                                CachedNetworkImage(
                                              imageUrl: path,
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              fit: BoxFit.cover,
                                            ),
                                            videoPlayerBuilder: (path) =>
                                                FlutterFlowVideoPlayer(
                                              path: path,
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              autoPlay: true,
                                              looping: false,
                                              showControls: false,
                                              allowFullScreen: true,
                                              allowPlaybackSpeedMenu: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 102.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    FlutterFlowTheme.of(context)
                                                        .primaryDark,
                                                    Color(0x001A1F24)
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                16.0,
                                                                12.0,
                                                                16.0,
                                                                36.0),
                                                    child: StreamBuilder<
                                                        UsersRecord>(
                                                      stream: UsersRecord
                                                          .getDocument(
                                                              pageViewUserStoriesRecord
                                                                  .user!),
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child: SizedBox(
                                                              width: 50.0,
                                                              height: 50.0,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        final userInfoUsersRecord =
                                                            snapshot.data!;
                                                        return Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
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
                                                                  Image.network(
                                                                valueOrDefault<
                                                                    String>(
                                                                  userInfoUsersRecord
                                                                      .photoUrl,
                                                                  'https://firebasestorage.googleapis.com/v0/b/mindmates-d4849.appspot.com/o/assets%2Fuser.png?alt=media&token=aae6bfd5-7111-4126-bbb8-a8a101e9a414&_gl=1*1hs28wm*_ga*MjI5MDQxMTIwLjE2OTc1MzAxNTE.*_ga_CW55HF8NVT*MTY5NzYxMzMwNi41LjEuMTY5NzYxNDA4NS44LjAuMA..',
                                                                ),
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
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
                                                                        userInfoUsersRecord
                                                                            .displayName,
                                                                        '',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            4.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      userInfoUsersRecord
                                                                          .userName,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            fontSize:
                                                                                12.0,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            if (pageViewUserStoriesRecord
                                                                .isOwner)
                                                              Card(
                                                                clipBehavior: Clip
                                                                    .antiAliasWithSaveLayer,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .dark600,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              60.0),
                                                                ),
                                                                child:
                                                                    FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      30.0,
                                                                  buttonSize:
                                                                      46.0,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .more_vert,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .grayIcon,
                                                                    size: 20.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    _pauseTimer();
                                                                    widget.userId !=
                                                                            userAc
                                                                                ?.uid
                                                                        ? await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Color(0x00000000),
                                                                            barrierColor:
                                                                                Color(0x00000000),
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WillPopScope(
                                                                                onWillPop: () async {
                                                                                  Navigator.pop(context); // Close the bottom sheet
                                                                                  _unpauseTimer(); // Call the unpausePlay function
                                                                                  return true;
                                                                                },
                                                                                child: Padding(
                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                  child: Container(
                                                                                      height: 240.0,
                                                                                      child: Container(
                                                                                        width: double.infinity,
                                                                                        height: double.infinity,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              InkWell(
                                                                                                onTap: () {
                                                                                                  Navigator.pop(context);
                                                                                                  print(widget.userId);
                                                                                                  print(pageViewUserStoriesRecord.reference.id);
                                                                                                  showModalBottomSheet<void>(
                                                                                                    context: context,
                                                                                                    builder: (BuildContext context) {
                                                                                                      //          Navigator.pop(
                                                                                                      // context);
                                                                                                      return GeneralReportingWidget(
                                                                                                        reporteeId: widget.userId,
                                                                                                        postId: pageViewUserStoriesRecord.reference,
                                                                                                        username: widget.username,
                                                                                                      );
                                                                                                    },
                                                                                                  );
                                                                                                },
                                                                                                child: Container(
                                                                                                  height: 60,
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                                        child: Row(
                                                                                                          children: [
                                                                                                            Container(
                                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                                                                                                                child: Icon(
                                                                                                                  Icons.report,
                                                                                                                  color: FlutterFlowTheme.of(context).mineIcon,
                                                                                                                )),
                                                                                                            Text('Report'),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                      Icon(
                                                                                                        Icons.arrow_forward_ios_rounded,
                                                                                                        color: FlutterFlowTheme.of(context).mineIcon,
                                                                                                      )
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Container(
                                                                                                color: FlutterFlowTheme.of(context).accent3,
                                                                                                height: 2,
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                            setState(
                                                                                () {}))
                                                                        : await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Color(0x00000000),
                                                                            barrierColor:
                                                                                Color(0x00000000),
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WillPopScope(
                                                                                onWillPop: () async {
                                                                                  Navigator.pop(context); // Close the bottom sheet
                                                                                  _unpauseTimer(); // Call the unpausePlay function
                                                                                  return true;
                                                                                },
                                                                                child: Padding(
                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                  child: Container(
                                                                                    height: 240.0,
                                                                                    child: DeleteStoryWidget(
                                                                                      storyDetails: pageViewUserStoriesRecord,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                            setState(() {}));
                                                                  },
                                                                ),
                                                              ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0x001A1F24),
                                                    FlutterFlowTheme.of(context)
                                                        .primaryDark
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                16.0,
                                                                16.0,
                                                                16.0,
                                                                16.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        pageViewUserStoriesRecord
                                                            .storyDescription,
                                                        '',
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                              ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 12.0, 16.0, 8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _pauseTimer();
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Color(0x00000000),
                                            barrierColor: Color(0x00000000),
                                            context: context,
                                            builder: (context) {
                                              return WillPopScope(
                                                onWillPop: () async {
                                                  Navigator.pop(
                                                      context); // Close the bottom sheet
                                                  _unpauseTimer(); // Call the unpausePlay function
                                                  return true;
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: Container(
                                                    height: 600.0,
                                                    child:
                                                        pageViewUserStoriesRecord
                                                                    .user?.id ==
                                                                currentUserUid
                                                            ? CommentsWidget(
                                                                story:
                                                                    pageViewUserStoriesRecord,
                                                              )
                                                            : commentsUserWidget(
                                                                story:
                                                                    pageViewUserStoriesRecord,
                                                              ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then((value) => setState(() {}));
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.mode_comment_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              size: 24.0,
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                pageViewUserStoriesRecord
                                                    .numComments
                                                    .toString(),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Urbanist',
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      widget.userId == currentUserUid
                                          ? Expanded(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          pageViewUserStoriesRecordList[
                                                                  pageViewIndex]
                                                              .views
                                                              .length
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .tertiary,
                                                          ),
                                                        ),
                                                      ),
                                                      Builder(
                                                        builder: (context) =>
                                                            FlutterFlowIconButton(
                                                          borderColor: Colors
                                                              .transparent,
                                                          borderRadius: 30.0,
                                                          buttonSize: 48.0,
                                                          icon: Icon(
                                                            Icons
                                                                .remove_red_eye,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .tertiary,
                                                            size: 30.0,
                                                          ),
                                                          onPressed: () async {
                                                            _pauseTimer();
                                                            showModalBottomSheet<
                                                                    void>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  //          Navigator.pop(
                                                                  // context);
                                                                  return WillPopScope(
                                                                      onWillPop:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            context); // Close the bottom sheet
                                                                        _unpauseTimer(); // Call the unpausePlay function
                                                                        return true;
                                                                      },
                                                                      child: StreamBuilder<
                                                                              DocumentSnapshot>(
                                                                          stream: FirebaseFirestore
                                                                              .instance
                                                                              .doc(
                                                                                  'userStories/${pageViewUserStoriesRecordList[pageViewIndex].reference.id}')
                                                                              .snapshots(),
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            if (!snapshot.hasData ||
                                                                                !snapshot.data!.exists) {
                                                                              return Container(
                                                                                child: const Text('..'),
                                                                              );
                                                                            }
                                                                            if (snapshot.error !=
                                                                                null) {
                                                                              return const Center(
                                                                                child: Text('Error loading data...'),
                                                                              );
                                                                            }

                                                                            final storyData =
                                                                                snapshot.data!.data() as Map<String, dynamic>; // Explicitly cast to the correct type
                                                                            int views =
                                                                                storyData['views'].length;

                                                                            final people =
                                                                                List<String>.from(storyData['views']);

                                                                            final List<Stream<QuerySnapshot>>
                                                                                queryStreams =
                                                                                [];
                                                                            const int
                                                                                batchSize =
                                                                                10;

                                                                            for (int i = 0;
                                                                                i < people.length;
                                                                                i += batchSize) {
                                                                              final batchIds = people.skip(i).take(batchSize).toList();
                                                                              final queryStream = FirebaseFirestore.instance.collection('users').where('uid', whereIn: batchIds).snapshots();

                                                                              queryStreams.add(queryStream);
                                                                              print(batchIds);
                                                                            }

                                                                            return StreamBuilder<List<QuerySnapshot>>(
                                                                                stream: CombineLatestStream.list(queryStreams),
                                                                                builder: (context, snapshot) {
                                                                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                                                    return Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Container(
                                                                                          color: Theme.of(context).primaryColor,
                                                                                          width: MediaQuery.of(context).size.width,
                                                                                          height: 50,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              Text(
                                                                                                'No Views yet',
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 12,
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                              ),
                                                                                              GestureDetector(
                                                                                                onTap: () async {
                                                                                                  await showModalBottomSheet(
                                                                                                    isScrollControlled: true,
                                                                                                    backgroundColor: Color(0x00000000),
                                                                                                    barrierColor: Color(0x00000000),
                                                                                                    context: context,
                                                                                                    builder: (context) {
                                                                                                      return WillPopScope(
                                                                                                        onWillPop: () async {
                                                                                                          Navigator.pop(context); // Close the bottom sheet
                                                                                                          _unpauseTimer(); // Call the unpausePlay function
                                                                                                          return true;
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: MediaQuery.viewInsetsOf(context),
                                                                                                          child: Container(
                                                                                                            height: 240.0,
                                                                                                            child: DeleteStoryWidget(
                                                                                                              storyDetails: pageViewUserStoriesRecord,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                  ).then((value) => setState(() {}));
                                                                                                },
                                                                                                child: const Icon(
                                                                                                  Icons.delete,
                                                                                                  color: Colors.white,
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          height: 200,
                                                                                          child: Text('..'),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  }

                                                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                    return Container();
                                                                                  }
                                                                                  if (snapshot.error != null) {
                                                                                    return const Center(
                                                                                      child: Text('Error loading.'),
                                                                                    );
                                                                                  }

                                                                                  final List<Viewers> listOfViewers = snapshot.data!
                                                                                      .expand((querySnapshot) {
                                                                                        return querySnapshot.docs.map((doc) {
                                                                                          return Viewers(
                                                                                            username: doc['userName'],
                                                                                            profile: doc['photo_url'],
                                                                                            userid: doc['uid'],
                                                                                          );
                                                                                        });
                                                                                      })
                                                                                      .cast<Viewers>()
                                                                                      .toList();

                                                                                  // Filter followers based on search text
                                                                                  // final List<Foll

                                                                                  return Container(
                                                                                    height: views > 0 ? MediaQuery.of(context).size.height * .4 + 50 : 210,
                                                                                    child: Column(
                                                                                      children: [
                                                                                        Container(
                                                                                          color: Theme.of(context).primaryColor,
                                                                                          width: MediaQuery.of(context).size.width,
                                                                                          height: 50,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              Text(
                                                                                                views == 1 ? '$views View' : '$views Views',
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 12,
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                              ),
                                                                                              GestureDetector(
                                                                                                onTap: () async {
                                                                                                  await showModalBottomSheet(
                                                                                                    isScrollControlled: true,
                                                                                                    backgroundColor: Color(0x00000000),
                                                                                                    barrierColor: Color(0x00000000),
                                                                                                    context: context,
                                                                                                    builder: (context) {
                                                                                                      return WillPopScope(
                                                                                                        onWillPop: () async {
                                                                                                          Navigator.pop(context); // Close the bottom sheet
                                                                                                          _unpauseTimer(); // Call the unpausePlay function
                                                                                                          return true;
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: MediaQuery.viewInsetsOf(context),
                                                                                                          child: Container(
                                                                                                            height: 240.0,
                                                                                                            child: DeleteStoryWidget(
                                                                                                              storyDetails: pageViewUserStoriesRecord,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                  ).then((value) => setState(() {}));
                                                                                                },
                                                                                                child: const Icon(
                                                                                                  Icons.delete,
                                                                                                  color: Colors.white,
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        views > 0
                                                                                            ? Container(
                                                                                                height: MediaQuery.of(context).size.height * .4,
                                                                                                color: Colors.white,
                                                                                                child: ListView.builder(
                                                                                                  itemCount: listOfViewers.length,
                                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                                    return ListTile(
                                                                                                      leading: CircleAvatar(
                                                                                                        radius: 22,
                                                                                                        foregroundImage: listOfViewers[index].profile.isNotEmpty ? NetworkImage(listOfViewers[index].profile) : null,
                                                                                                        child: const Icon(Icons.person),
                                                                                                      ),
                                                                                                      title: Text(
                                                                                                        listOfViewers[index].username,
                                                                                                        style: TextStyle(color: Theme.of(context).shadowColor, fontWeight: FontWeight.w500, fontSize: 12),
                                                                                                      ),
                                                                                                    );
                                                                                                  },
                                                                                                ),
                                                                                              )
                                                                                            : Container(
                                                                                                height: 160,
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                });
                                                                          }));
                                                                });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // ),
          ],
        ),
      ),
    );
  }
}

class Viewers {
  String username;
  String profile;
  String userid;

  Viewers({
    required this.username,
    required this.profile,
    required this.userid,
  });
}
