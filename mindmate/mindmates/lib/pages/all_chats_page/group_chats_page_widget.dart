import 'package:mindmates/pages/messaging/group_chat_widget.dart';

import '/flutter_flow/chat/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'all_chats_page_model.dart';
export 'all_chats_page_model.dart';

class AllChatsPageWidget extends StatefulWidget {
  const AllChatsPageWidget({Key? key}) : super(key: key);

  @override
  _AllChatsPageWidgetState createState() => _AllChatsPageWidgetState();
}

class _AllChatsPageWidgetState extends State<AllChatsPageWidget> {
  late AllChatsPageModel _model;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          context.pushNamed('createGroupChat');
        },
        backgroundColor: FlutterFlowTheme.of(context).primary,
        elevation: 8.0,
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 36.0,
        ),
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chatsGroup')
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
                  id: doc['id'],
                  seenby: doc['seenby'],
                  time: doc['timestamp'],
                  message: doc['lastmessage'],
                  users: doc['users'],
                  name: doc['groupname'],
                  profile: doc['profile'],
                  senderId: doc['sender'],
                  admins: doc['groupAdmins'],

                  // Add other properties as needed
                );
              }).toList();
              // bool isUsernameTaken = false;

// Now, filteredChatsRecords contains only records where the group has more than 2 users

              if (listViewChatsRecordList.isEmpty) {
                return Center(
                  child: Image.asset(
                    'assets/images/MESSAGE.png',
                    width: MediaQuery.sizeOf(context).width * 0.76,
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemCount: listViewChatsRecordList.length,
                itemBuilder: (context, listViewIndex) {
                  final listViewChatsRecord =
                      listViewChatsRecordList[listViewIndex];
                  final List<dynamic> admins = listViewChatsRecord.admins;

                  bool isAdmin = admins.contains(currentUserUid);

                  return FFChatPreview(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GroupChatWidget(
                                groupId: listViewChatsRecord.id,
                                groupName: listViewChatsRecord.name,
                                groupProfile: listViewChatsRecord.profile,
                                isAdmin: isAdmin,
                              )));

                      FirebaseFirestore.instance
                          .collection('chatsGroup')
                          .doc(listViewChatsRecord.id)
                          .update({
                        'seenby': FieldValue.arrayUnion([currentUserUid]),
                        // 'timestamp':
                        //     FieldValue.serverTimestamp(),
                      });
                    },
                    
                    lastChatText: listViewChatsRecord.message,
                    lastChatTime: listViewChatsRecord.time.toDate(),
                    seen: !listViewChatsRecord.seenby.contains(currentUserUid),
                    title: listViewChatsRecord.name,
                    userProfilePic: listViewChatsRecord.profile,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    unreadColor: FlutterFlowTheme.of(context).primary,
                    titleTextStyle: GoogleFonts.getFont(
                      'Outfit',
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      fontStyle: FontStyle.normal,
                    ),
                    dateTextStyle: GoogleFonts.getFont(
                      'Urbanist',
                      color: FlutterFlowTheme.of(context).grayIcon,
                      fontWeight: FontWeight.normal,
                      fontSize: 9.0,
                    ),
                    previewTextStyle: GoogleFonts.getFont(
                      'Urbanist',
                      color: FlutterFlowTheme.of(context).grayIcon,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                    ),
                    contentPadding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 3.0, 3.0, 3.0),
                    borderRadius: BorderRadius.circular(0.0),
                    isProfessional: false,
                    seenState:
                        listViewChatsRecord.seenby.contains(currentUserUid),
                    isSender: listViewChatsRecord.senderId == currentUserUid,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class Chats {
  String id;
  List seenby;
  String message;
  Timestamp time;
  List users;
  String name;
  String profile;
  String senderId;
  List admins;

  Chats({
    required this.id,
    required this.seenby,
    required this.message,
    required this.time,
    required this.users,
    required this.name,
    required this.profile,
    required this.senderId,
    required this.admins,
  });
}
