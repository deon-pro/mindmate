import 'package:mindmates/pages/messaging/single_chat_widget.dart';

import '/flutter_flow/chat/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
// ignore: unused_import
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

class CreateChatWidget extends StatefulWidget {
  const CreateChatWidget({Key? key}) : super(key: key);

  @override
  _CreateChatWidgetState createState() => _CreateChatWidgetState();
}

class _CreateChatWidgetState extends State<CreateChatWidget> {
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
              'Start a Chat',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            Text(
              'Select a friend to start a chat.',
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
                  hintText: 'Search for friends...',
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
            child: StreamBuilder<List<UsersRecord>>(
              stream: queryUsersRecord(
                  // limit: 50,
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
                List<UsersRecord> listViewUsersRecordLists = snapshot.data!;

                final List<UsersRecord> listViewUsersRecordList =
                    listViewUsersRecordLists.where((follower) {
                  final username = follower.userName.toLowerCase();
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
                              child: Text('Error loading data...'),
                            );
                          }
                          final userdata = snapshot.data!.docs;
                          // bool isUsernameTaken = false;

                          final existingUser = Set<String>.from(userdata.map(
                            (doc) => (doc.data() as Map<String, dynamic>)['id']
                                .toString(),
                          ));
                          bool isProfessional =
                              existingUser.contains(listViewUsersRecord.uid);

                          return GestureDetector(
                            onTap: () async {
                              // context.pushNamed(
                              //   'chatPage',
                              //   queryParameters: {
                              //     'chatUser': serializeParam(
                              //      listViewUsersRecordList[listViewIndex],
                              //       ParamType.Document,
                              //     ),
                              //   }.withoutNulls,
                              //   extra: <String, dynamic>{
                              //     'chatUser':
                              //         listViewUsersRecordList[listViewIndex],
                              //   },
                              // );
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SingleChatWidget(
                                        receiverId: listViewUsersRecord.uid,
                                        userImage: listViewUsersRecord.photoUrl,
                                        username: listViewUsersRecord.userName,
                                        professional: isProfessional, token: listViewUsersRecord.token,
                                      )));
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
                                  borderRadius: BorderRadius.circular(0.0),
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
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  2.0, 2.0, 2.0, 2.0),
                                          child: Container(
                                            width: 50.0,
                                            height: 50.0,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: listViewUsersRecord
                                                    .photoUrl.isNotEmpty
                                                ? Image.network(
                                                    listViewUsersRecord
                                                        .photoUrl,
                                                  )
                                                : Icon(Icons.person),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  2.0, 0.0, 0.0, 0.0),
                                          child: Theme(
                                            data: ThemeData(
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: ListTile(
                                              // value: _model.checkboxListTileValueMap[
                                              //     listViewUsersRecord] ??= false,
                                              // onChanged: (newValue) async {
                                              //   setState(() => _model
                                              //           .checkboxListTileValueMap[
                                              //       listViewUsersRecord] = newValue!);
                                              // },
                                              title: Row(
                                                children: [
                                                  Text(
                                                    listViewUsersRecord
                                                        .userName,
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                            Icons.verified,
                                                            color: Color(
                                                                0xFF12CCEE),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),

                                              // activeColor:
                                              //     FlutterFlowTheme.of(context).primary,
                                              // checkColor:
                                              //     FlutterFlowTheme.of(context).tertiary,
                                              // dense: false,
                                              // controlAffinity:
                                              //     ListTileControlAffinity.trailing,
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
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   height: 100.0,
          //   decoration: BoxDecoration(
          //     color: Color(0xFF4E39F9),
          //     boxShadow: [
          //       BoxShadow(
          //         blurRadius: 4.0,
          //         color: Color(0x3314181B),
          //         offset: Offset(0.0, -2.0),
          //       )
          //     ],
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(0.0),
          //       bottomRight: Radius.circular(0.0),
          //       topLeft: Radius.circular(16.0),
          //       topRight: Radius.circular(16.0),
          //     ),
          //   ),
          //   child: Padding(
          //     padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 34.0),
          //     child: FFButtonWidget(
          //       onPressed: () async {
          //         _model.groupChat = await FFChatManager.instance.createChat(
          //           _model.checkboxListTileCheckedItems
          //               .map((e) => e.reference)
          //               .toList(),
          //         );
          //         context.pushNamed(
          //           'chatPage',
          //           queryParameters: {
          //             'chatRef': serializeParam(
          //               _model.groupChat?.reference,
          //               ParamType.DocumentReference,
          //             ),
          //           }.withoutNulls,
          //         );

          //         setState(() {});
          //       },
          //       text: 'Create Community Chat',
          //       options: FFButtonOptions(
          //         width: 130.0,
          //         height: 40.0,
          //         padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          //         iconPadding:
          //             EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          //         color: Color(0xFF4E39F9),
          //         textStyle:
          //             FlutterFlowTheme.of(context).headlineSmall.override(
          //                   fontFamily: 'Lexend Deca',
          //                   color: Colors.white,
          //                   fontSize: 20.0,
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //         elevation: 2.0,
          //         borderSide: BorderSide(
          //           color: Colors.transparent,
          //           width: 1.0,
          //         ),
          //         borderRadius: BorderRadius.circular(12.0),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}