// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:mindmates/flutter_flow/flutter_flow_media_display.dart';
// import 'package:mindmates/flutter_flow/flutter_flow_video_player.dart';
// import 'package:mindmates/pages/menu/reporting.dart';

// import '/backend/backend.dart';
// import '/components/comments/comments_widget.dart';
// import '/components/delete_story/delete_story_widget.dart';
// import '/flutter_flow/flutter_flow_icon_button.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart'
//     as smooth_page_indicator;
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'story_details_model.dart';
// export 'story_details_model.dart';

// class StoryDetailsWidget extends StatefulWidget {
//   const StoryDetailsWidget({
//     Key? key,
//     this.initialStoryIndex,
//     this.username,
//     this.userId,
//   }) : super(key: key);

//   final int? initialStoryIndex;
//   final String? userId;
//   final String? username;

//   @override
//   _StoryDetailsWidgetState createState() => _StoryDetailsWidgetState();
// }

// class _StoryDetailsWidgetState extends State<StoryDetailsWidget> {
//   late StoryDetailsModel _model;

//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   final userAc = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => StoryDetailsModel());
//   }

//   @override
//   void dispose() {
//     _model.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     DocumentReference userRef =
//         FirebaseFirestore.instance.collection('users').doc(widget.userId);

//     return Scaffold(
//       key: scaffoldKey,
//       backgroundColor: FlutterFlowTheme.of(context).primaryDark,
//       body: SafeArea(
//         top: true,
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Expanded(
//               child: StreamBuilder<List<UserStoriesRecord>>(
//                 stream: queryUserStoriesRecord(
//                   queryBuilder: (userStoriesRecord) => userStoriesRecord
//                       .where('user',
//                           isEqualTo: userRef) // Add the user ID filter here
//                       .orderBy('storyPostedAt', descending: true),
//                   // limit: 20,
//                 ),
//                 builder: (context, snapshot) {
//                   // Customize what your widget looks like when it's loading.
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: SizedBox(
//                         width: 50.0,
//                         height: 50.0,
//                         child: CircularProgressIndicator(
//                           color: FlutterFlowTheme.of(context).primary,
//                         ),
//                       ),
//                     );
//                   }
//                   List<UserStoriesRecord> pageViewUserStoriesRecordList =
//                       snapshot.data!;
//                   print(
//                       'FCEDVF(LENGHT): ${pageViewUserStoriesRecordList.length}');
//                   return Container(
//                     width: double.infinity,
//                     height: double.infinity,
//                     child: Stack(
//                       children: [
//                         PageView.builder(
//                           controller: _model.pageViewController ??=
//                               PageController(
//                                   initialPage: min(
//                                       valueOrDefault<int>(
//                                         widget.initialStoryIndex,
//                                         0,
//                                       ),
//                                       pageViewUserStoriesRecordList.length -
//                                           1)),
//                           // scrollDirection: Axis.vertical,
//                           itemCount: pageViewUserStoriesRecordList.length,
//                           itemBuilder: (context, pageViewIndex) {
//                             final pageViewUserStoriesRecord =
//                                 pageViewUserStoriesRecordList[pageViewIndex];
//                             return Column(
//                               mainAxisSize: MainAxisSize.max,
//                               children: [
//                                 Container(
//                                   height:
//                                       MediaQuery.sizeOf(context).height * 0.82,
//                                   child: Stack(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(8.0),
//                                         child: FlutterFlowMediaDisplay(
//                                           path: pageViewUserStoriesRecord
//                                               .storyPhoto,
//                                           imageBuilder: (path) =>
//                                               CachedNetworkImage(
//                                             imageUrl: path,
//                                             width: MediaQuery.sizeOf(context)
//                                                     .width *
//                                                 1.0,
//                                             height: MediaQuery.of(context)
//                                                 .size
//                                                 .height,
//                                             fit: BoxFit.cover,
//                                           ),
//                                           videoPlayerBuilder: (path) =>
//                                               FlutterFlowVideoPlayer(
//                                             path: path,
//                                             width: MediaQuery.sizeOf(context)
//                                                     .width *
//                                                 1.0,
//                                             autoPlay: true,
//                                             looping: false,
//                                             showControls: false,
//                                             allowFullScreen: true,
//                                             allowPlaybackSpeedMenu: false,
//                                           ),
//                                         ),
//                                       ),
//                                       Align(
//                                         alignment:
//                                             AlignmentDirectional(0.0, 0.0),
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.max,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Container(
//                                               width: double.infinity,
//                                               height: 102.0,
//                                               decoration: BoxDecoration(
//                                                 gradient: LinearGradient(
//                                                   colors: [
//                                                     FlutterFlowTheme.of(context)
//                                                         .primaryDark,
//                                                     Color(0x001A1F24)
//                                                   ],
//                                                   stops: [0.0, 1.0],
//                                                   begin: AlignmentDirectional(
//                                                       0.0, -1.0),
//                                                   end: AlignmentDirectional(
//                                                       0, 1.0),
//                                                 ),
//                                               ),
//                                               child: Column(
//                                                 mainAxisSize: MainAxisSize.max,
//                                                 children: [
//                                                   Padding(
//                                                     padding:
//                                                         EdgeInsetsDirectional
//                                                             .fromSTEB(
//                                                                 16.0,
//                                                                 12.0,
//                                                                 16.0,
//                                                                 36.0),
//                                                     child: StreamBuilder<
//                                                         UsersRecord>(
//                                                       stream: UsersRecord
//                                                           .getDocument(
//                                                               pageViewUserStoriesRecord
//                                                                   .user!),
//                                                       builder:
//                                                           (context, snapshot) {
//                                                         // Customize what your widget looks like when it's loading.
//                                                         if (!snapshot.hasData) {
//                                                           return Center(
//                                                             child: SizedBox(
//                                                               width: 50.0,
//                                                               height: 50.0,
//                                                               child:
//                                                                   CircularProgressIndicator(
//                                                                 color: FlutterFlowTheme.of(
//                                                                         context)
//                                                                     .primary,
//                                                               ),
//                                                             ),
//                                                           );
//                                                         }
//                                                         final userInfoUsersRecord =
//                                                             snapshot.data!;
//                                                         return Row(
//                                                           mainAxisSize:
//                                                               MainAxisSize.max,
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             Container(
//                                                               width: 40.0,
//                                                               height: 40.0,
//                                                               clipBehavior: Clip
//                                                                   .antiAlias,
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 shape: BoxShape
//                                                                     .circle,
//                                                               ),
//                                                               child:
//                                                                   Image.network(
//                                                                 valueOrDefault<
//                                                                     String>(
//                                                                   userInfoUsersRecord
//                                                                       .photoUrl,
//                                                                   'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/sample-app-social-app-tx2kqp/assets/gu4akoa3hju1/victor-grabarczyk-N04FIfHhv_k-unsplash.jpg',
//                                                                 ),
//                                                                 fit: BoxFit
//                                                                     .fitHeight,
//                                                               ),
//                                                             ),
//                                                             Expanded(
//                                                               child: Column(
//                                                                 mainAxisSize:
//                                                                     MainAxisSize
//                                                                         .max,
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   Padding(
//                                                                     padding: EdgeInsetsDirectional
//                                                                         .fromSTEB(
//                                                                             12.0,
//                                                                             0.0,
//                                                                             0.0,
//                                                                             0.0),
//                                                                     child: Text(
//                                                                       valueOrDefault<
//                                                                           String>(
//                                                                         userInfoUsersRecord
//                                                                             .displayName,
//                                                                         'Good Post',
//                                                                       ),
//                                                                       style: FlutterFlowTheme.of(
//                                                                               context)
//                                                                           .bodyMedium
//                                                                           .override(
//                                                                             fontFamily:
//                                                                                 'Urbanist',
//                                                                             color:
//                                                                                 FlutterFlowTheme.of(context).tertiary,
//                                                                           ),
//                                                                     ),
//                                                                   ),
//                                                                   Padding(
//                                                                     padding: EdgeInsetsDirectional
//                                                                         .fromSTEB(
//                                                                             12.0,
//                                                                             4.0,
//                                                                             0.0,
//                                                                             0.0),
//                                                                     child: Text(
//                                                                       userInfoUsersRecord
//                                                                           .userName,
//                                                                       style: FlutterFlowTheme.of(
//                                                                               context)
//                                                                           .bodyMedium
//                                                                           .override(
//                                                                             fontFamily:
//                                                                                 'Urbanist',
//                                                                             color:
//                                                                                 FlutterFlowTheme.of(context).tertiary,
//                                                                             fontSize:
//                                                                                 12.0,
//                                                                           ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                             if (pageViewUserStoriesRecord
//                                                                 .isOwner)
//                                                               Card(
//                                                                 clipBehavior: Clip
//                                                                     .antiAliasWithSaveLayer,
//                                                                 color: FlutterFlowTheme.of(
//                                                                         context)
//                                                                     .dark600,
//                                                                 shape:
//                                                                     RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               60.0),
//                                                                 ),
//                                                                 child:
//                                                                     FlutterFlowIconButton(
//                                                                   borderColor:
//                                                                       Colors
//                                                                           .transparent,
//                                                                   borderRadius:
//                                                                       30.0,
//                                                                   buttonSize:
//                                                                       46.0,
//                                                                   icon: Icon(
//                                                                     Icons
//                                                                         .more_vert,
//                                                                     color: FlutterFlowTheme.of(
//                                                                             context)
//                                                                         .grayIcon,
//                                                                     size: 20.0,
//                                                                   ),
//                                                                   onPressed:
//                                                                       () async {
//                                                                     widget.userId !=
//                                                                             userAc
//                                                                                 ?.uid
//                                                                         ? await showModalBottomSheet(
//                                                                             isScrollControlled:
//                                                                                 true,
//                                                                             backgroundColor:
//                                                                                 Color(0x00000000),
//                                                                             barrierColor:
//                                                                                 Color(0x00000000),
//                                                                             context:
//                                                                                 context,
//                                                                             builder:
//                                                                                 (context) {
//                                                                               return Padding(
//                                                                                 padding: MediaQuery.viewInsetsOf(context),
//                                                                                 child: Container(
//                                                                                     height: 240.0,
//                                                                                     child: Container(
//                                                                                       width: double.infinity,
//                                                                                       height: double.infinity,
//                                                                                       decoration: BoxDecoration(
//                                                                                         color: FlutterFlowTheme.of(context).secondaryBackground,
//                                                                                       ),
//                                                                                       child: Padding(
//                                                                                         padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
//                                                                                         child: Column(
//                                                                                           mainAxisSize: MainAxisSize.max,
//                                                                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                           children: [
//                                                                                             InkWell(
//                                                                                               onTap: () {
//                                                                                                 Navigator.pop(context);
//                                                                                                 print(widget.userId);
//                                                                                                 print(pageViewUserStoriesRecord.reference.id);
//                                                                                                 showModalBottomSheet<void>(
//                                                                                                   context: context,
//                                                                                                   builder: (BuildContext context) {
//                                                                                                     //          Navigator.pop(
//                                                                                                     // context);
//                                                                                                     return GeneralReportingWidget(
//                                                                                                       reporteeId: widget.userId,
//                                                                                                       postId: pageViewUserStoriesRecord.reference,
//                                                                                                       username: widget.username,
//                                                                                                     );
//                                                                                                   },
//                                                                                                 );
//                                                                                               },
//                                                                                               child: Container(
//                                                                                                 height: 60,
//                                                                                                 child: Row(
//                                                                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                   children: [
//                                                                                                     Container(
//                                                                                                       padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
//                                                                                                       child: Row(
//                                                                                                         children: [
//                                                                                                           Container(
//                                                                                                               padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
//                                                                                                               child: Icon(
//                                                                                                                 Icons.report,
//                                                                                                                 color: FlutterFlowTheme.of(context).mineIcon,
//                                                                                                               )),
//                                                                                                           Text('Report'),
//                                                                                                         ],
//                                                                                                       ),
//                                                                                                     ),
//                                                                                                     Icon(
//                                                                                                       Icons.arrow_forward_ios_rounded,
//                                                                                                       color: FlutterFlowTheme.of(context).mineIcon,
//                                                                                                     )
//                                                                                                   ],
//                                                                                                 ),
//                                                                                               ),
//                                                                                             ),
//                                                                                             Container(
//                                                                                               color: FlutterFlowTheme.of(context).accent3,
//                                                                                               height: 2,
//                                                                                             )
//                                                                                           ],
//                                                                                         ),
//                                                                                       ),
//                                                                                     )),
//                                                                               );
//                                                                             },
//                                                                           ).then((value) =>
//                                                                             setState(
//                                                                                 () {}))
//                                                                         : await showModalBottomSheet(
//                                                                             isScrollControlled:
//                                                                                 true,
//                                                                             backgroundColor:
//                                                                                 Color(0x00000000),
//                                                                             barrierColor:
//                                                                                 Color(0x00000000),
//                                                                             context:
//                                                                                 context,
//                                                                             builder:
//                                                                                 (context) {
//                                                                               return Padding(
//                                                                                 padding: MediaQuery.viewInsetsOf(context),
//                                                                                 child: Container(
//                                                                                   height: 240.0,
//                                                                                   child: DeleteStoryWidget(
//                                                                                     storyDetails: pageViewUserStoriesRecord,
//                                                                                   ),
//                                                                                 ),
//                                                                               );
//                                                                             },
//                                                                           ).then((value) =>
//                                                                             setState(() {}));
//                                                                   },
//                                                                 ),
//                                                               ),
//                                                             Card(
//                                                               clipBehavior: Clip
//                                                                   .antiAliasWithSaveLayer,
//                                                               color: FlutterFlowTheme
//                                                                       .of(context)
//                                                                   .dark600,
//                                                               shape:
//                                                                   RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             60.0),
//                                                               ),
//                                                               child:
//                                                                   FlutterFlowIconButton(
//                                                                 borderColor: Colors
//                                                                     .transparent,
//                                                                 borderRadius:
//                                                                     30.0,
//                                                                 buttonSize:
//                                                                     46.0,
//                                                                 icon: Icon(
//                                                                   Icons
//                                                                       .close_rounded,
//                                                                   color: FlutterFlowTheme.of(
//                                                                           context)
//                                                                       .grayIcon,
//                                                                   size: 20.0,
//                                                                 ),
//                                                                 onPressed:
//                                                                     () async {
//                                                                   context.pop();
//                                                                 },
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         );
//                                                       },
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Container(
//                                               width: double.infinity,
//                                               height: 100.0,
//                                               decoration: BoxDecoration(
//                                                 gradient: LinearGradient(
//                                                   colors: [
//                                                     Color(0x001A1F24),
//                                                     FlutterFlowTheme.of(context)
//                                                         .primaryDark
//                                                   ],
//                                                   stops: [0.0, 1.0],
//                                                   begin: AlignmentDirectional(
//                                                       0.0, -1.0),
//                                                   end: AlignmentDirectional(
//                                                       0, 1.0),
//                                                 ),
//                                               ),
//                                               child: Column(
//                                                 mainAxisSize: MainAxisSize.max,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.end,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Padding(
//                                                     padding:
//                                                         EdgeInsetsDirectional
//                                                             .fromSTEB(
//                                                                 16.0,
//                                                                 16.0,
//                                                                 16.0,
//                                                                 16.0),
//                                                     child: Text(
//                                                       valueOrDefault<String>(
//                                                         pageViewUserStoriesRecord
//                                                             .storyDescription,
//                                                         'MINDMATES',
//                                                       ),
//                                                       textAlign:
//                                                           TextAlign.start,
//                                                       style:
//                                                           FlutterFlowTheme.of(
//                                                                   context)
//                                                               .bodyMedium
//                                                               .override(
//                                                                 fontFamily:
//                                                                     'Urbanist',
//                                                                 color: FlutterFlowTheme.of(
//                                                                         context)
//                                                                     .tertiary,
//                                                               ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       16.0, 12.0, 16.0, 8.0),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.max,
//                                     children: [
//                                       InkWell(
//                                         splashColor: Colors.transparent,
//                                         focusColor: Colors.transparent,
//                                         hoverColor: Colors.transparent,
//                                         highlightColor: Colors.transparent,
//                                         onTap: () async {
//                                           await showModalBottomSheet(
//                                             isScrollControlled: true,
//                                             backgroundColor: Color(0x00000000),
//                                             barrierColor: Color(0x00000000),
//                                             context: context,
//                                             builder: (context) {
//                                               return Padding(
//                                                 padding:
//                                                     MediaQuery.viewInsetsOf(
//                                                         context),
//                                                 child: Container(
//                                                   height: 600.0,
//                                                   child: CommentsWidget(
//                                                     story:
//                                                         pageViewUserStoriesRecord,
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ).then((value) => setState(() {}));
//                                         },
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.max,
//                                           children: [
//                                             Icon(
//                                               Icons.mode_comment_outlined,
//                                               color:
//                                                   FlutterFlowTheme.of(context)
//                                                       .tertiary,
//                                               size: 24.0,
//                                             ),
//                                             Padding(
//                                               padding: EdgeInsetsDirectional
//                                                   .fromSTEB(8.0, 0.0, 0.0, 0.0),
//                                               child: Text(
//                                                 pageViewUserStoriesRecord
//                                                     .numComments
//                                                     .toString(),
//                                                 style: FlutterFlowTheme.of(
//                                                         context)
//                                                     .bodyMedium
//                                                     .override(
//                                                       fontFamily: 'Urbanist',
//                                                       color:
//                                                           FlutterFlowTheme.of(
//                                                                   context)
//                                                               .tertiary,
//                                                     ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.max,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             Builder(
//                                               builder: (context) =>
//                                                   FlutterFlowIconButton(
//                                                 borderColor: Colors.transparent,
//                                                 borderRadius: 30.0,
//                                                 buttonSize: 48.0,
//                                                 icon: Icon(
//                                                   Icons.ios_share,
//                                                   color: FlutterFlowTheme.of(
//                                                           context)
//                                                       .tertiary,
//                                                   size: 30.0,
//                                                 ),
//                                                 onPressed: () async {
//                                                   await Share.share(
//                                                     'This post is really awesome!',
//                                                     sharePositionOrigin:
//                                                         getWidgetBoundingBox(
//                                                             context),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                         Align(
//                           alignment: AlignmentDirectional(0.95, 0.7),
//                           child: Padding(
//                             padding: EdgeInsetsDirectional.fromSTEB(
//                                 0.0, 0.0, 0.0, 10.0),
//                             child: smooth_page_indicator.SmoothPageIndicator(
//                               controller: _model.pageViewController ??=
//                                   PageController(
//                                       // initialPage: min(
//                                       //     valueOrDefault<int>(
//                                       //       widget.initialStoryIndex,
//                                       //       0,
//                                       //     ),
//                                       //     pageViewUserStoriesRecordList.length -
//                                       //         1)
//                                       ),
//                               count: pageViewUserStoriesRecordList.length,
//                               axisDirection: Axis.vertical,
//                               onDotClicked: (i) async {
//                                 await _model.pageViewController!.animateToPage(
//                                   i,
//                                   duration: Duration(milliseconds: 500),
//                                   curve: Curves.ease,
//                                 );
//                               },
//                               effect: smooth_page_indicator.ExpandingDotsEffect(
//                                 expansionFactor: 2.0,
//                                 spacing: 8.0,
//                                 radius: 16.0,
//                                 dotWidth: 8.0,
//                                 dotHeight: 4.0,
//                                 dotColor: Color(0x65DBE2E7),
//                                 activeDotColor:
//                                     FlutterFlowTheme.of(context).tertiary,
//                                 paintStyle: PaintingStyle.fill,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
