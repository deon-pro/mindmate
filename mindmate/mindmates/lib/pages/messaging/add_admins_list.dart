import 'package:mindmates/pages/messaging/single_chat_widget.dart';
import 'package:rxdart/rxdart.dart';

import '/flutter_flow/chat/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class CreateAdminWidget extends StatefulWidget {
  final groupId;
  const CreateAdminWidget({Key? key, required this.groupId}) : super(key: key);

  @override
  _CreateAdminWidgetState createState() => _CreateAdminWidgetState();
}

class _CreateAdminWidgetState extends State<CreateAdminWidget> {
  // late CreateGroupChatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    // _model = createModel(context, () => CreateGroupChatModel());

    // _model.textController ??= TextEditingController();
  }

  @override
  void dispose() {
    // _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 24.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add admin ',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            Text(
              'Select a member to become an admin.',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ],
        ),
        actions: [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            height: 50.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3.0,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  offset: Offset(0.0, 2.0),
                )
              ],
              borderRadius: BorderRadius.circular(0.0),
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 0.0, 1.0),
              child: TextFormField(
                // controller: _model.textController,
                onChanged: (value) {
                  setState(() {
                    searchText = value
                        .toLowerCase(); // Update the searchText on text changes
                  });
                },

                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Search for members...',
                  hintStyle: FlutterFlowTheme.of(context).bodySmall,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                    ),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  contentPadding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 14.0, 0.0, 0.0),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium,
                // validator: _model.textControllerValidator.asValidator(context),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatsGroup')
                    .where('id', isEqualTo: widget.groupId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      child: const Text('..'),
                    );
                  }
                  if (snapshot.error != null) {
                    return const Center(
                      child: Text('Error loading data...'),
                    );
                  }

                  final userData = snapshot.data!.docs;
                  final people = userData.isNotEmpty
                      ? List<String>.from(userData.first['users'])
                      : [];

                  final List<Stream<QuerySnapshot>> queryStreams = [];
                  const int batchSize = 10;

                  for (int i = 0; i < people.length; i += batchSize) {
                    final batchIds = people.skip(i).take(batchSize).toList();
                    final queryStream = FirebaseFirestore.instance
                        .collection('users')
                        .where('uid', whereIn: batchIds)
                        .snapshots();

                    queryStreams.add(queryStream);
                    print(batchIds);
                  }

                  return StreamBuilder<List<QuerySnapshot>>(
                    stream: CombineLatestStream.list(queryStreams),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container();
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      if (snapshot.error != null) {
                        return const Center(
                          child: Text('Error loading.'),
                        );
                      }

                      final List<Members> listViewUsersRecordLists =
                          snapshot.data!
                              .expand((querySnapshot) {
                                return querySnapshot.docs.map((doc) {
                                  return Members(
                                    username: doc['userName'],
                                    profile: doc['photo_url'],
                                    userid: doc['uid'],
                                  );
                                });
                              })
                              .cast<Members>()
                              .toList();
                      // List<UsersRecord> listViewUsersRecordLists = snapshot.data!;

                      final List<Members> listViewUsersRecordList =
                          listViewUsersRecordLists.where((follower) {
                        final username = follower.username.toLowerCase();
                        final searchQuery = searchText.toLowerCase();
                        return username.contains(searchQuery);
                      }).toList();

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: listViewUsersRecordList.length,
                        itemBuilder: (context, listViewIndex) {
                          final listViewUsersRecord =
                              listViewUsersRecordList[listViewIndex];
                          return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('mental_health_professionals')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center();
                                }
                                if (snapshot.error != null) {
                                  return const Center(
                                    child: Text('Error loading data...'),
                                  );
                                }
                                final userdata = snapshot.data!.docs;
                                // bool isUsernameTaken = false;

                                final existingUser =
                                    Set<String>.from(userdata.map(
                                  (doc) =>
                                      (doc.data() as Map<String, dynamic>)['id']
                                          .toString(),
                                ));
                                bool isProfessional = existingUser
                                    .contains(listViewUsersRecord.userid);

                                return GestureDetector(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('chatsGroup')
                                        .doc(widget.groupId)
                                        .update({
                                          'groupAdmins': FieldValue.arrayUnion([
                                            listViewUsersRecord.userid,
                                          ]),
                                        })
                                        .then((_) {})
                                        .catchError((error) {
                                          print('Error adminig user: $error');
                                        });
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 2.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 70.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 0.0,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            offset: Offset(0.0, 2.0),
                                          )
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Card(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              color: Color(0xFF4E39F9),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        2.0, 2.0, 2.0, 2.0),
                                                child: Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: listViewUsersRecord
                                                          .profile.isNotEmpty
                                                      ? Image.network(
                                                          listViewUsersRecord
                                                              .profile,
                                                        )
                                                      : Icon(Icons.person),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        2.0, 0.0, 0.0, 0.0),
                                                child: Theme(
                                                  data: ThemeData(
                                                    unselectedWidgetColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                  ),
                                                  child: ListTile(
                                                    title: Row(
                                                      children: [
                                                        Text(
                                                          listViewUsersRecord
                                                              .username,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium,
                                                        ),
                                                        isProfessional
                                                            ? Padding(
                                                                padding: EdgeInsets
                                                                    .fromLTRB(
                                                                        10.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .verified,
                                                                  color: Color(
                                                                      0xFF12CCEE),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class Members {
  String username;
  String profile;
  String userid;

  Members({
    required this.username,
    required this.profile,
    required this.userid,
  });
}
