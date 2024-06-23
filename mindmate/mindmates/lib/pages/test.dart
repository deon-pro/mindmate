  // Container(
                            //   child: Padding(
                            //     padding: EdgeInsetsDirectional.fromSTEB(
                            //         0.0, 4.0, 0.0, 8.0),
                            //     child: StreamBuilder<List<UserStoriesRecord>>(
                            //       stream: getStoriesStream(userRefs),
                            //       builder: (context, snapshot) {
                            //         // Customize what your widget looks like when it's loading.
                            //         if (!snapshot.hasData) {
                            //           return Center(
                            //             child: Container(
                            //               padding: EdgeInsets.all(10),
                            //               child: Text('..'),
                            //             ),
                            //           );
                            //         }
                            //         List<UserStoriesRecord>
                            //             listViewUserStoriesRecord =
                            //             snapshot.data!;

                            //         final List<UserStoriesRecord>
                            //             unviewedStories = [];
                            //         final List<UserStoriesRecord>
                            //             viewedStories = [];

                            //         for (final listViewUserStoriesRecord
                            //             in listViewUserStoriesRecord) {
                            //           if (listViewUserStoriesRecord.views
                            //               .contains(currentUserUid)) {
                            //             viewedStories
                            //                 .add(listViewUserStoriesRecord);
                            //           } else {
                            //             unviewedStories
                            //                 .add(listViewUserStoriesRecord);
                            //           }
                            //         }

                            //         // Combine unviewed and viewed stories in the desired order
                            //         final List<UserStoriesRecord>
                            //             listViewUserStoriesRecordList = [
                            //           ...unviewedStories,
                            //           ...viewedStories
                            //         ];

                            //         //STREAMS
                            //         final userData = snapshot.data!;
                            //         final people = userData.isNotEmpty
                            //             ? userData.map((userRecord) {
                            //                 if (userRecord.user != null &&
                            //                     userRecord.user
                            //                         is DocumentReference) {
                            //                   return userRecord.user!.id;
                            //                 }
                            //                 return '';
                            //               }).toList()
                            //             : [];

                            //         final List<Stream<QuerySnapshot>>
                            //             queryStreams = [];
                            //         const int batchSize = 10;

                            //         for (int i = 0;
                            //             i < people.length;
                            //             i += batchSize) {
                            //           final batchIds = people
                            //               .skip(i)
                            //               .take(batchSize)
                            //               .toList();

                            //           var queryStream = FirebaseFirestore
                            //               .instance
                            //               .collection('users')
                            //               .where('uid', whereIn: batchIds)
                            //               .snapshots();

                            //           queryStreams.add(queryStream);
                            //           print(batchIds);
                            //         }
                            //         // STREAMS

                            //         if (listViewUserStoriesRecordList.isEmpty) {
                            //           return Center(
                            //             child: Image.asset(
                            //               'assets/images/y20dh_',
                            //               width: 60.0,
                            //             ),
                            //           );
                            //         }
                            //         return StreamBuilder<List<QuerySnapshot>>(
                            //             stream: CombineLatestStream.list(
                            //                 queryStreams),
                            //             builder: (context, snapshot) {
                            //               if (!snapshot.hasData ||
                            //                   snapshot.data!.isEmpty) {
                            //                 return const Center(
                            //                   child: Text('No Stories updates'),
                            //                 );
                            //               }
                            //               if (snapshot.connectionState ==
                            //                   ConnectionState.waiting) {
                            //                 return Container();
                            //               }
                            //               if (snapshot.error != null) {
                            //                 return const Center(
                            //                   child: Text('Error.'),
                            //                 );
                            //               }

                            //               final List<Story> stories = snapshot
                            //                   .data!
                            //                   .expand((querySnapshot) {
                            //                     return querySnapshot.docs
                            //                         .map((doc) {
                            //                       return Story(
                            //                         username: doc['userName'],
                            //                         profile: doc['photo_url'],
                            //                         userid: doc['uid'],
                            //                       );
                            //                     });
                            //                   })
                            //                   .cast<Story>()
                            //                   .toList();

                            //               // Sort the stories based on whether they have been viewed

                            //               return ListView.builder(
                            //                 padding: EdgeInsets.zero,
                            //                 scrollDirection: Axis.horizontal,
                            //                 shrinkWrap: true,
                            //                 itemCount: stories.length,
                            //                 physics:
                            //                     NeverScrollableScrollPhysics(),
                            //                 itemBuilder:
                            //                     (context, listViewIndex) {
                            //                   final listViewUserStoriesRecord =
                            //                       listViewUserStoriesRecordList[
                            //                           listViewIndex];
                            //                   return stories[listViewIndex]
                            //                               .userid ==
                            //                           currentUser?.uid
                            //                       ? Container()
                            //                       : Padding(
                            //                           padding:
                            //                               EdgeInsetsDirectional
                            //                                   .fromSTEB(
                            //                                       8.0,
                            //                                       0.0,
                            //                                       8.0,
                            //                                       0.0),
                            //                           child: StreamBuilder<
                            //                               UsersRecord>(
                            //                             stream: listViewUserStoriesRecord
                            //                                         .user !=
                            //                                     null
                            //                                 ? UsersRecord
                            //                                     .getDocument(
                            //                                         listViewUserStoriesRecord
                            //                                             .user!)
                            //                                 : null,
                            //                             builder: (context,
                            //                                 snapshot) {
                            //                               // Customize what your widget looks like when it's loading.
                            //                               if (!snapshot
                            //                                   .hasData) {
                            //                                 return Center();
                            //                               }
                            //                               // ignore: unused_local_variable
                            //                               final columnUsersRecord =
                            //                                   snapshot.data!;
                            //                               DocumentReference
                            //                                   userRef =
                            //                                   FirebaseFirestore
                            //                                       .instance
                            //                                       .collection(
                            //                                           'users')
                            //                                       .doc(stories[
                            //                                               listViewIndex]
                            //                                           .userid);
                            //                               return StreamBuilder<
                            //                                       QuerySnapshot>(
                            //                                   stream: FirebaseFirestore
                            //                                       .instance
                            //                                       .collection(
                            //                                           'userStories')
                            //                                       // .where(
                            //                                       //     'storyPostedAt',
                            //                                       //     isGreaterThan:
                            //                                       //         tenDaysAgoTimestamp)
                            //                                       .where('user',
                            //                                           isEqualTo:
                            //                                               userRef)
                            //                                       .orderBy(
                            //                                           'storyPostedAt',
                            //                                           descending:
                            //                                               true) // Sort by timestamp in descending order
                            //                                       .limit(
                            //                                           1) // Limit the result to only the latest document
                            //                                       .snapshots(),
                            //                                   builder: (context,
                            //                                       snapshot) {
                            //                                     if (!snapshot
                            //                                             .hasData ||
                            //                                         snapshot
                            //                                             .data!
                            //                                             .docs
                            //                                             .isEmpty) {
                            //                                       return const Center(
                            //                                         child: Text(
                            //                                             '..'),
                            //                                       );
                            //                                     }
                            //                                     if (snapshot
                            //                                             .error !=
                            //                                         null) {
                            //                                       return const Center(
                            //                                         child: Text(
                            //                                             'Error loading data...'),
                            //                                       );
                            //                                     }

                            //                                     final latestStoryDoc =
                            //                                         snapshot
                            //                                             .data!
                            //                                             .docs
                            //                                             .first;
                            //                                     final latestStoryData =
                            //                                         latestStoryDoc
                            //                                                 .data()
                            //                                             as Map<
                            //                                                 String,
                            //                                                 dynamic>;

                            //                                     final List<
                            //                                             String>
                            //                                         viewList =
                            //                                         [];
                            //                                     if (latestStoryData[
                            //                                             'views'] !=
                            //                                         null) {
                            //                                       viewList.addAll(List<
                            //                                               String>.from(
                            //                                           latestStoryData[
                            //                                               'views']));
                            //                                     }

                            //                                     bool isViewed =
                            //                                         viewList.contains(
                            //                                             currentUser
                            //                                                 ?.uid);

                            //                                     return InkWell(
                            //                                       splashColor:
                            //                                           Colors
                            //                                               .transparent,
                            //                                       focusColor: Colors
                            //                                           .transparent,
                            //                                       hoverColor: Colors
                            //                                           .transparent,
                            //                                       highlightColor:
                            //                                           Colors
                            //                                               .transparent,
                            //                                       onTap:
                            //                                           () async {
                            //                                         // print(
                            //                                         //     'DEGBBTRG110101011: ${stories[listViewIndex].userid}');
                            //                                         // print(
                            //                                         //     'DEGBBTRG110101011: ${stories[listViewIndex].username}');
                            //                                         context
                            //                                             .pushNamed(
                            //                                           'storyDetails',
                            //                                           queryParameters:
                            //                                               {
                            //                                             'initialStoryIndex': serializeParam(
                            //                                                 0,
                            //                                                 ParamType.int),
                            //                                             'userId': serializeParam(
                            //                                                 stories[listViewIndex].userid,
                            //                                                 ParamType.String),
                            //                                             'userName': serializeParam(
                            //                                                 stories[listViewIndex].username,
                            //                                                 ParamType.String),
                            //                                           }.withoutNulls,
                            //                                           extra: <String,
                            //                                               dynamic>{
                            //                                             kTransitionInfoKey:
                            //                                                 TransitionInfo(
                            //                                               hasTransition:
                            //                                                   true,
                            //                                               transitionType:
                            //                                                   PageTransitionType.bottomToTop,
                            //                                               duration:
                            //                                                   Duration(milliseconds: 200),
                            //                                             ),
                            //                                           },
                            //                                         );
                            //                                       },
                            //                                       child: Column(
                            //                                         mainAxisSize:
                            //                                             MainAxisSize
                            //                                                 .max,
                            //                                         children: [
                            //                                           Stack(
                            //                                             children: [
                            //                                               CircleAvatar(
                            //                                                 radius:
                            //                                                     30,
                            //                                                 backgroundColor: !isViewed
                            //                                                     ? Color(0xFF4B39EF)
                            //                                                     : const Color.fromARGB(0, 255, 193, 7),
                            //                                               ),
                            //                                               Positioned(
                            //                                                 bottom:
                            //                                                     2,
                            //                                                 right:
                            //                                                     2,
                            //                                                 child:
                            //                                                     CircleAvatar(
                            //                                                   radius: 28,
                            //                                                   backgroundColor: Theme.of(context).cardColor,
                            //                                                 ),
                            //                                               ),
                            //                                               Positioned(
                            //                                                 bottom:
                            //                                                     4,
                            //                                                 right:
                            //                                                     4,
                            //                                                 child:
                            //                                                     CircleAvatar(
                            //                                                   radius: 26,
                            //                                                   foregroundImage: stories[listViewIndex].profile.isNotEmpty ? NetworkImage(stories[listViewIndex].profile) : null,
                            //                                                   child: const Icon(Icons.person),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                           Padding(
                            //                                             padding: EdgeInsetsDirectional.fromSTEB(
                            //                                                 0.0,
                            //                                                 4.0,
                            //                                                 0.0,
                            //                                                 0.0),
                            //                                             child:
                            //                                                 Text(
                            //                                               valueOrDefault<
                            //                                                   String>(
                            //                                                 stories[listViewIndex].username,
                            //                                                 '',
                            //                                               ).maybeHandleOverflow(
                            //                                                 maxChars:
                            //                                                     8,
                            //                                                 replacement:
                            //                                                     '…',
                            //                                               ),
                            //                                               // style: TextStyle(
                            //                                               //   fontSize: 6,
                            //                                               //   fontFamily:
                            //                                               //           'Urbanist'
                            //                                               // )
                            //                                               style: FlutterFlowTheme.of(context)
                            //                                                   .bodyMedium
                            //                                                   .override(
                            //                                                     fontFamily: 'Urbanist',
                            //                                                     fontSize: 10.0,
                            //                                                   ),
                            //                                             ),
                            //                                           ),
                            //                                         ],
                            //                                       ),
                            //                                     );
                            //                                   });
                            //                             },
                            //                           ),
                            //                         );
                            //                 },
                            //               );
                            //             });
                            //       },
                            //     ),
                            //   ),
                            // ),