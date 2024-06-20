import 'package:mindmates/pages/chat_page_remake/create_chat_widget.dart';
import 'package:mindmates/pages/messaging/single_chat_widget.dart';

import '/flutter_flow/chat/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'all_chats_page_model.dart';
export 'all_chats_page_model.dart';

class ChatsPageWidget extends StatefulWidget {
  const ChatsPageWidget({Key? key}) : super(key: key);

  @override
  _ChatsPageWidgetState createState() => _ChatsPageWidgetState();
}

class _ChatsPageWidgetState extends State<ChatsPageWidget> {
  late AllChatsPageModel _model;
  String otherUserId = '';
  List<String> otherUserIds = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllChatsPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<List<String>> getOtherUserIds(List<Chats> chats) async {
    List<String> userIds = [];
    final userId = currentUserUid;

    for (var chat in chats) {
      // Check if the current user's ID is repeated in the chat's users list
      int currentUserCount =
          chat.users.where((userid) => userid == userId).length;
      if (currentUserCount > 1) {
        // The current user's ID is repeated, select it
        userIds.add(userId);
      } else {
        // Iterate through the chat's users and add the other user's ID
        for (String userid in chat.users) {
          if (userid != userId) {
            userIds.add(userid);
            break; // Stop the loop once the other user ID is found
          }
        }
      }
    }
    print('tytyytytyytyt: ${userIds}');
    return userIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CreateChatWidget()));
          // context.pushNamed('createChat');
        },
        backgroundColor: FlutterFlowTheme.of(context).primary,
        elevation: 8.0,
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 36.0,
        ),
      ),
      // appBar: AppBar(
      //   backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'Messages',
      //     style: FlutterFlowTheme.of(context).headlineMedium,
      //   ),
      //   actions: [],
      //   centerTitle: false,
      //   elevation: 0.0,
      // ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chatsNew')
                .where('users', arrayContains: currentUserUid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Image.asset(
                    'assets/images/MESSAGE.png',
                    width: MediaQuery.sizeOf(context).width * 0.76,
                  ),
                );
              }
              if (snapshot.error != null) {
                return Center(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: const Text('Error loading chats...')),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Handle loading state
                return const Center();
              }

              List<Chats> listViewChatsRecordList =
                  snapshot.data!.docs.map((doc) {
                return Chats(
                  id: doc['chatId'],
                  seen: doc['seen'],
                  time: doc['timestamp'],
                  message: doc['lastmessage'],
                  users: doc['users'],
                  receiver: doc['receiverId'],
                  senderId: doc['senderId'],

                  // Add other properties as needed
                );
              }).toList();

// Now, filteredChatsRecords contains only records where the group has more than 2 users

              if (listViewChatsRecordList.isEmpty) {
                return Center(
                  child: Image.asset(
                    'assets/images/MESSAGE.png',
                    width: MediaQuery.sizeOf(context).width * 0.76,
                  ),
                );
              }
              return FutureBuilder<List<String>>(
                  future: getOtherUserIds(listViewChatsRecordList),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Handle loading state
                      return const Center();
                    } else if (!snapshot.hasData) {
                      // Handle loading state
                      print('errrrrrgor');
                      return const Center();
                    } else if (snapshot.hasError) {
                      // Handle error state
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Data is available
                      otherUserIds = snapshot.data!;
                      // print('errrrrrgor: $otherUserIds');
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemCount: listViewChatsRecordList.length,
                        itemBuilder: (context, listViewIndex) {
                          String otherUserId = otherUserIds[listViewIndex];
                          print('errrrrrgor: $otherUserId');

                          final listViewChatsRecord =
                              listViewChatsRecordList[listViewIndex];
                          // return StreamBuilder<FFChatInfo>(
                          //   stream: FFChatManager.instance
                          //       .getChatInfo(chatRecord: listViewChatsRecord),
                          //   builder: (context, snapshot) {
                          // final chatInfo =
                          //     snapshot.data ?? FFChatInfo(listViewChatsRecord);
                          return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('messages')
                                  .where('chatId',
                                      isEqualTo: listViewChatsRecord.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final chatDocs = snapshot.data?.docs ?? [];

                                if (chatDocs.isEmpty) {
                                  return Container();
                                }

                                return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .where('uid', isEqualTo: otherUserId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return Container();
                                      }
                                      if (snapshot.error != null) {
                                        return const Center(
                                          child: Text('Error loading data...'),
                                        );
                                      }

                                      final userdata =
                                          snapshot.data!.docs.first;
                                      final userInfo = userdata.data() as Map<
                                          String,
                                          dynamic>; // Explicitly cast to the correct type

                                      return StreamBuilder<QuerySnapshot>(
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
                                                child: Text(
                                                    'Error loading data...'),
                                              );
                                            }
                                            final userdata =
                                                snapshot.data!.docs;
                                            // bool isUsernameTaken = false;

                                            final existingUser =
                                                Set<String>.from(userdata.map(
                                              (doc) => (doc.data() as Map<
                                                      String, dynamic>)['id']
                                                  .toString(),
                                            ));
                                            bool isProfessional = existingUser
                                                .contains(otherUserId);

                                            return FFChatPreview(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SingleChatWidget(
                                                              receiverId:
                                                                  otherUserId,
                                                              userImage: userInfo[
                                                                  'photo_url'],
                                                              username: userInfo[
                                                                  'userName'],
                                                              professional:
                                                                  isProfessional, token: userInfo[
                                                                  'token'],
                                                            )));
                                                if (listViewChatsRecord
                                                        .receiver ==
                                                    currentUserUid) {
                                                  FirebaseFirestore.instance
                                                      .collection('chatsNew')
                                                      .doc(listViewChatsRecord
                                                          .id)
                                                      .update({
                                                    'seen': true,
                                                    // 'timestamp':
                                                    //     FieldValue.serverTimestamp(),
                                                  });
                                                }
                                              },
                                              // onTap: () => context.pushNamed(
                                              //   'chatPage',
                                              //   queryParameters: {
                                              //     'chatUser': serializeParam(
                                              //       chatInfo.otherUsers.length == 1
                                              //           ? chatInfo.otherUsersList.first
                                              //           : null,
                                              //       ParamType.Document,
                                              //     ),
                                              //     'chatRef': serializeParam(
                                              //       listViewChatsRecord,
                                              //       ParamType.DocumentReference,
                                              //     ),
                                              //   }.withoutNulls,
                                              //   extra: <String, dynamic>{
                                              //     'chatUser': chatInfo.otherUsers.length == 1
                                              //         ? chatInfo.otherUsersList.first
                                              //         : null,
                                              //   },
                                              // ),
                                              lastChatText:
                                                  listViewChatsRecord.message,
                                              lastChatTime: listViewChatsRecord
                                                  .time
                                                  .toDate(),
                                              seen: listViewChatsRecord.seen &&
                                                  listViewChatsRecord
                                                          .receiver ==
                                                      currentUserUid,
                                              title: userInfo['userName'],
                                              userProfilePic:
                                                  userInfo['photo_url'],
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              unreadColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              titleTextStyle:
                                                  GoogleFonts.getFont(
                                                'Outfit',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                fontStyle: FontStyle.normal,
                                              ),
                                              dateTextStyle:
                                                  GoogleFonts.getFont(
                                                'Urbanist',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .grayIcon,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 9.0,
                                              ),
                                              previewTextStyle:
                                                  GoogleFonts.getFont(
                                                'Urbanist',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .grayIcon,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 3.0, 3.0, 3.0),
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              isProfessional: isProfessional,
                                              seenState:
                                                  listViewChatsRecord.seen ==
                                                          true &&
                                                      listViewChatsRecord
                                                              .receiver !=
                                                          currentUserUid,
                                              isSender: listViewChatsRecord
                                                      .senderId ==
                                                  currentUserUid,
                                            );
                                          });
                                    });
                              });
                          //   },
                          // );
                        },
                      );
                    }
                  });
            },
          ),
        ),
      ),
    );
  }
}

class Chats {
  String id;
  bool seen;
  String message;
  Timestamp time;
  List users;
  String receiver;
  String senderId;

  Chats({
    required this.id,
    required this.seen,
    required this.message,
    required this.time,
    required this.users,
    required this.receiver,
    required this.senderId,
  });
}
