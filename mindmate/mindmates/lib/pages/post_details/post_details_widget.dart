import 'package:mindmates/flutter_flow/flutter_flow_media_display.dart';
import 'package:mindmates/flutter_flow/flutter_flow_video_player.dart';
import 'package:mindmates/pages/menu/public_post_menu.dart';
import 'package:mindmates/pages/menu/user_post_menu.dart';
import 'package:mindmates/pages/post_details/post_view.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
// ignore: unused_import
import '/components/delete_post/delete_post_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'post_details_model.dart';
export 'post_details_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsWidget extends StatefulWidget {
  const PostDetailsWidget({
    Key? key,
    this.postReference,
    this.userRecord,
  }) : super(key: key);

  final DocumentReference? postReference;
  final UsersRecord? userRecord;

  @override
  _PostDetailsWidgetState createState() => _PostDetailsWidgetState();
}

class _PostDetailsWidgetState extends State<PostDetailsWidget> {
  late PostDetailsModel _model;
  FocusNode _commentFocusNode = FocusNode();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showUserSuggestions = false;
  List<String> _userSuggestions = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PostDetailsModel());
    _fetchUserSuggestions();

    _model.textController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  String formattedDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (dateTime.isAfter(now.subtract(const Duration(minutes: 1)))) {
      return timeago.format(dateTime);
    }
    if (today == day) {
      return DateFormat.jm().format(dateTime);
    }
    if (yesterday == day) {
      return 'Yesterday';
    }
    return DateFormat.MMMd().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    List? friendsList = widget.userRecord!.minders != null
        ? List.from(widget.userRecord!.minders as Iterable)
        : <String>[]; // Initialize to an empty list if 'friends' is null
    bool isFriend = friendsList.contains(currentUser?.uid);
    return StreamBuilder<UserPostsRecord>(
      stream: UserPostsRecord.getDocument(widget.postReference!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final postDetailsUserPostsRecord = snapshot.data!;
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: FlutterFlowMediaDisplay(
                                path: postDetailsUserPostsRecord.postPhoto,
                                imageBuilder: (path) => GestureDetector(
                                  onTap: () =>  Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewPost(photo: path, page: 'Post',),
                          )),
                                  child: CachedNetworkImage(
                                    imageUrl: path,
                                    width: MediaQuery.sizeOf(context).width * 1.0,
                                    height: 300.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                videoPlayerBuilder: (path) =>
                                    FlutterFlowVideoPlayer(
                                  // aspectRatio: 16 / 9,
                                  path: path,
                                  width:
                                      MediaQuery.of(context).size.width * 1.0,
                                  autoPlay: true,
                                  looping: false,
                                  showControls: true,
                                  allowFullScreen: false,
                                  allowPlaybackSpeedMenu: true,
                                  // height: 300,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 12.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    color: Color(0x3F000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    child: FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30.0,
                                      buttonSize: 46.0,
                                      icon: Icon(
                                        Icons.arrow_back_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        context.pop();
                                      },
                                    ),
                                  ),
                                  if (postDetailsUserPostsRecord.postOwner)
                                    FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30.0,
                                      borderWidth: 1.0,
                                      buttonSize: 44.0,
                                      fillColor: Color(0x41000000),
                                      icon: Icon(
                                        Icons.more_vert_sharp,
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            //          Navigator.pop(
                                            // context);
                                            return postDetailsUserPostsRecord
                                                        .postUser?.id ==
                                                    currentUser?.uid
                                                ? UserPostMenu(
                                                    canComment:
                                                        postDetailsUserPostsRecord
                                                            .canComment,
                                                    docid:
                                                        postDetailsUserPostsRecord
                                                            .reference,
                                                    username: widget
                                                        .userRecord!.userName,
                                                  )
                                                : PostMenu(
                                                    canComment:
                                                        postDetailsUserPostsRecord
                                                            .canComment,
                                                    docid:
                                                        postDetailsUserPostsRecord
                                                            .reference,
                                                    username: widget
                                                        .userRecord!.userName,
                                                    isFriend: isFriend,
                                                    userid:
                                                        postDetailsUserPostsRecord
                                                            .postUser?.id,
                                                  );
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 8.0, 16.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                color: Color(0xFF4B39EF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      1.0, 1.0, 1.0, 1.0),
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.network(
                                      widget.userRecord!.photoUrl,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        widget.userRecord!.userName,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        formattedDate(postDetailsUserPostsRecord
                                            .timePosted!),
                                        // dateTimeFormat(
                                        //     'relative',
                                        //     postDetailsUserPostsRecord
                                        //         .timePosted!),
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
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
                              16.0, 4.0, 16.0, 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  postDetailsUserPostsRecord.postDescription
                                      .maybeHandleOverflow(
                                    maxChars: 200,
                                    replacement: '…',
                                  ),
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 4.0, 16.0, 6.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        ToggleIcon(
                                          onPressed: () async {
                                            final likesElement =
                                                currentUserReference;
                                            final likesUpdate =
                                                postDetailsUserPostsRecord.likes
                                                        .contains(likesElement)
                                                    ? FieldValue.arrayRemove(
                                                        [likesElement])
                                                    : FieldValue.arrayUnion(
                                                        [likesElement]);
                                            await postDetailsUserPostsRecord
                                                .reference
                                                .update({
                                              'likes': likesUpdate,
                                            });
                                          },
                                          value: postDetailsUserPostsRecord
                                              .likes
                                              .contains(currentUserReference),
                                          onIcon: Icon(
                                            Icons.favorite_border_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 25.0,
                                          ),
                                          offIcon: Icon(
                                            Icons.favorite_border_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            size: 25.0,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  4.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            functions
                                                .likes(
                                                    postDetailsUserPostsRecord)
                                                .toString(),
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.mode_comment_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        size: 24.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          postDetailsUserPostsRecord.numComments
                                              .toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.ios_share,
                                    color: FlutterFlowTheme.of(context)
                                        .tertiary,
                                    size: 24.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 12.0, 16.0, 12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Comments',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily: 'Urbanist',
                                            fontSize: 12.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder<List<PostCommentsRecord>>(
                                stream: queryPostCommentsRecord(
                                  queryBuilder: (postCommentsRecord) =>
                                      postCommentsRecord
                                          .where('post',
                                              isEqualTo:
                                                  postDetailsUserPostsRecord
                                                      .reference)
                                          .orderBy('timePosted',
                                              descending: true),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                      ),
                                    );
                                  }
                                  List<PostCommentsRecord>
                                      commentListPostCommentsRecordList =
                                      snapshot.data!;
                                  if (commentListPostCommentsRecordList
                                      .isEmpty) {
                                    return Center(
                                      child: Image.asset(
                                        'assets/images/commentsEmpty@2x.png',
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.7,
                                        height: 270.0,
                                      ),
                                    );
                                  }
                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(
                                        commentListPostCommentsRecordList
                                            .length, (commentListIndex) {
                                      final commentListPostCommentsRecord =
                                          commentListPostCommentsRecordList[
                                              commentListIndex];
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 2.0),
                                        child: StreamBuilder<UsersRecord>(
                                          stream: UsersRecord.getDocument(
                                              commentListPostCommentsRecord
                                                  .user!),
                                          builder: (context, snapshot) {
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
                                            final commentUsersRecord =
                                                snapshot.data!;
                                            return Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    offset: Offset(0.0, 1.0),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 12.0, 8.0, 12.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.network(
                                                        valueOrDefault<String>(
                                                          commentUsersRecord
                                                              .photoUrl,
                                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/sample-app-social-app-tx2kqp/assets/pbp73skqv1ru/shayna-douglas-lgILhKUELg4-unsplash.jpg',
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                commentUsersRecord
                                                                    .userName,
                                                                '',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleMedium,
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
                                                                commentListPostCommentsRecord
                                                                    .comment,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium,
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
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            4.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      'Posted',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    dateTimeFormat(
                                                                        'relative',
                                                                        commentListPostCommentsRecord
                                                                            .timePosted!),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_showUserSuggestions)
                          UserSuggestions(
                            suggestions: _userSuggestions,
                            onSuggestionSelected: _onUserSuggestionSelected,
                          ),
                      ],
                    ),
                  ),
                ),
                postDetailsUserPostsRecord.canComment == false
                    ? Container(
                        alignment: Alignment.center,
                        height: 60,
                        width: MediaQuery.of(context).size.width * .88,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x3A000000), //New
                                blurRadius: 3.0,
                                offset: Offset(0, 1))
                          ],
                        ),
                        child: Text(
                          'Comments are turned off for this post.',
                          style: TextStyle(
                            fontSize: 12,
                            color: FlutterFlowTheme.of(context).accent1,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 12.0, 12.0, 12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 12.0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3.0,
                                      color: Color(0x3A000000),
                                      offset: Offset(0.0, 1.0),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 4.0, 0.0, 4.0),
                                        child: TextFormField(
                                          controller: _model.textController,
                                          focusNode: _commentFocusNode,
                                          obscureText: false,
                                          onChanged: _onCommentChanged,
                                          decoration: InputDecoration(
                                            hintText: 'Comment here...',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                            errorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0x00000000),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4.0),
                                                topRight: Radius.circular(4.0),
                                              ),
                                            ),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium,
                                          validator: _model
                                              .textControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 4.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          _model.textController.text.isNotEmpty
                                              ? await PostCommentsRecord
                                                  .collection
                                                  .doc()
                                                  .set(
                                                      createPostCommentsRecordData(
                                                    timePosted:
                                                        getCurrentTimestamp,
                                                    comment: _model
                                                        .textController.text,
                                                    user: currentUserReference,
                                                    post:
                                                        postDetailsUserPostsRecord
                                                            .reference,
                                                  ))
                                              : null;

                                          await postDetailsUserPostsRecord
                                              .reference
                                              .update({
                                            'numComments':
                                                FieldValue.increment(1),
                                          });
                                          _model.textController?.clear();
                                        },
                                        text: _model
                                                .textController.text.isNotEmpty
                                            ? 'Post'
                                            : '',
                                        options: FFButtonOptions(
                                          width: 70.0,
                                          height: 40.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Urbanist',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                          elevation: 0.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchUserSuggestions() async {
    try {
      final QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final List<String> usernames =
          usersSnapshot.docs.map((doc) => doc['userName'] as String).toList();

      setState(() {
        _userSuggestions = usernames;
      });
    } catch (error) {
      // Handle any errors that occur during data fetching
      print('Error fetching user data: $error');
    }
  }

  void _onCommentChanged(String text) {
    // Check if "@" is typed and show user suggestions accordingly
    setState(() {
      _showUserSuggestions = text.contains('@');
    });
  }

  void _onUserSuggestionSelected(String username) {
    // Insert the selected username into the comment
    final currentText = _model.textController.text;
    final caretPosition = _model.textController?.selection.base.offset;
    final newText = currentText.replaceRange(
      caretPosition! - 1, // Replace the "@" character
      caretPosition,
      '@$username ',
    );

    // Update the comment text and hide user suggestions
    setState(() {
      _model.textController.text = newText;
      _model.textController?.selection = TextSelection.fromPosition(
        TextPosition(offset: caretPosition + username.length),
      );
      _showUserSuggestions = false;
    });
  }
}

class UserSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;

  UserSuggestions({
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final username = suggestions[index];
        return ListTile(
          title: Text(username),
          onTap: () => onSuggestionSelected(username),
        );
      },
    );
  }
}
