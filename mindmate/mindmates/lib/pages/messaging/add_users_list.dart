import 'package:mindmates/flutter_flow/flutter_flow_widgets.dart';
import 'package:rxdart/rxdart.dart';
import '/flutter_flow/chat/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class AddusersWidget extends StatefulWidget {
  final groupId;
  final member;
  const AddusersWidget({Key? key, required this.groupId, required this.member})
      : super(key: key);

  @override
  _AddusersWidgetState createState() => _AddusersWidgetState();
}

class _AddusersWidgetState extends State<AddusersWidget> {
  // late CreateGroupChatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String searchText = '';
  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    selectedUsers = widget.member;
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
              'Add users ',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            Text(
              'Select users to add to group.',
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
                  final groupData = snapshot.data!.docs.first;
                  final groupInfo = groupData.data() as Map<String,
                      dynamic>; // Explicitly cast to the correct type
                  List<dynamic> dynamicUsers = groupInfo['users'];
                  List<String> members = List<String>.from(
                      dynamicUsers.map((user) => user.toString()));

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
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
                      final List<Members> listViewUsersRecordLists =
                          snapshot.data!.docs.map((doc) {
                        return Members(
                          username: doc['userName'],
                          profile: doc['photo_url'],
                          userid: doc['uid'],
                        );
                      }).toList();

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

                                return Container(
                                  // onTap: () async {
                                  //   // await FirebaseFirestore.instance
                                  //   //     .collection('chatsGroup')
                                  //   //     .doc(widget.groupId)
                                  //   //     .update({
                                  //   //   'groupAdmins': FieldValue.arrayUnion([
                                  //   //     listViewUsersRecord.userid,
                                  //   //   ]),
                                  //   // }).then((_) {
                                  //   //   Navigator.of(context).pop();
                                  //   // }).catchError((error) {
                                  //   //   print('Error adminig user: $error');
                                  //   // });
                                  // },
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
                                                  child: Container(
                                                    // color: selectedUsers.contains(
                                                    //         listViewUsersRecord
                                                    //             .userid)
                                                    //     ? Colors.amber
                                                    //     : Colors.blue,
                                                    child: ListTile(
                                                      onTap: () {
                                                        if (selectedUsers.contains(
                                                            listViewUsersRecord
                                                                .userid)) {
                                                          print(
                                                              "Before: selectedUsers = $selectedUsers");
                                                          // setState(() {
                                                          // Add the user id to the selectedUsers list
                                                          selectedUsers.remove(
                                                              listViewUsersRecord
                                                                  .userid);
                                                          // setState(() {
                                                          //   selectedUsers =
                                                          //       selectedUsers;
                                                          // });
                                                          // });
                                                        } else {
                                                          print(
                                                              "After: selectedUsers = $selectedUsers");
                                                          // setState(() {
                                                          // Remove the user id from the selectedUsers list
                                                          selectedUsers.add(
                                                              listViewUsersRecord
                                                                  .userid);
                                                          setState(() {
                                                            selectedUsers =
                                                                selectedUsers;
                                                          });
                                                          // });
                                                        }
                                                      },
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
                                                      trailing: Checkbox(
                                                        value: selectedUsers
                                                            .contains(
                                                                listViewUsersRecord
                                                                    .userid),
                                                        onChanged:
                                                            (bool? value) {
                                                          if (value != null) {
                                                            setState(() {
                                                              if (selectedUsers
                                                                  .contains(
                                                                      listViewUsersRecord
                                                                          .userid)) {
                                                                selectedUsers.remove(
                                                                    listViewUsersRecord
                                                                        .userid);
                                                              } else {
                                                                selectedUsers.add(
                                                                    listViewUsersRecord
                                                                        .userid);
                                                              }
                                                              // Update the widget state after modifying the selectedUsers list
                                                            });
                                                          }
                                                        },
                                                      ),
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
          Container(
            width: double.infinity,
            height: 100.0,
            decoration: BoxDecoration(
              color: Color(0xFF4E39F9),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x3314181B),
                  offset: Offset(0.0, -2.0),
                )
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 34.0),
              child: FFButtonWidget(
                onPressed: () async {
                  print('66666666679hgv: $selectedUsers');

                  // Reunite the selectedUserIds with groupMembers
                  List<String> updatedUserIds = [
                    ...widget.member,
                    ...selectedUsers
                  ];
                  List<String> selectedUserIds =
                      updatedUserIds.toSet().toList(); // Remove duplicate IDs

                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    await firestore
                        .collection('chatsGroup')
                        .doc(widget.groupId)
                        .update({
                      'users': FieldValue.arrayUnion(selectedUserIds),
                    });
                  } catch (error) {
                    print('Error saving data to Firestore: $error');
                  }

                  context.pop();

                  setState(() {});
                },
                text: 'Invite to Chat',
                options: FFButtonOptions(
                  width: 130.0,
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Color(0xFF4E39F9),
                  textStyle:
                      FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Lexend Deca',
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                  elevation: 2.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
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
