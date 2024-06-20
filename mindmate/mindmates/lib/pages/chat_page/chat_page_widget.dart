import '/flutter_flow/chat/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'chat_page_model.dart';
export 'chat_page_model.dart';

class ChatPageWidget extends StatefulWidget {
  const ChatPageWidget({
    Key? key,
    this.chatUser,
    this.chatRef,
    this.chatUsers,
  }) : super(key: key);

  final UsersRecord? chatUser;
  final List<UsersRecord>? chatUsers;
  final DocumentReference? chatRef;

  @override
  _ChatPageWidgetState createState() => _ChatPageWidgetState();
}

class _ChatPageWidgetState extends State<ChatPageWidget> {
  late ChatPageModel _model;



  final scaffoldKey = GlobalKey<ScaffoldState>();
  FFChatInfo? _chatInfo;
  bool isGroupChat() {
    if (widget.chatUser == null) {
      return true;
    }
    if (widget.chatRef == null) {
      return false;
    }
    return _chatInfo?.isGroupChat ?? false;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatPageModel());

    FFChatManager.instance
        .getChatInfo(
      otherUserRecord: widget.chatUser,
      chatReference: widget.chatRef,
    )
        .listen((info) {
      if (mounted) {
        setState(() => _chatInfo = info);
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      List<String> chatUserNames = widget.chatUsers?.map((user) => user.displayName).toList() ?? [];
String formattedUserNames = chatUserNames.join(', ');

   return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Stack(
          children: [
            if (isGroupChat())
              GestureDetector(
                onTap: () {
                  showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(20.0),
                                                      child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Container(
                                                          //   margin: const EdgeInsets
                                                          //           .fromLTRB(
                                                          //       20, 20, 20, 20),
                                                          //   child: 
                                                            ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount: widget.chatUsers?.length,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                return ListTile(
                                                                  title: Text( widget.chatUsers![index].userName),
                                                                );
                                                              },
                                                            ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                },
                child: Text(
                  // widget.chatUser!.userName,
                  formattedUserNames,
                  style: FlutterFlowTheme.of(context).bodyMedium
                  // .override(
                  //       fontFamily: 'Urbanist',
                  //       color: Colors.black,
                  //       fontSize: 16.0,
                  //       fontWeight: FontWeight.bold,
                  //     )
                      ,
                ),
              ),
            if (!isGroupChat())
              Text(
                widget.chatUser!.userName,
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
          ],
        ),
        actions: [
          Visibility(
            visible: isGroupChat(),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    'addChatUsers',
                    queryParameters: {
                      'chat': serializeParam(
                        _chatInfo!.chatRecord,
                        ParamType.Document,
                      ),
                    }.withoutNulls,
                    extra: <String, dynamic>{
                      'chat': _chatInfo!.chatRecord,
                    },
                  );
                },
                child: Icon(
                  Icons.person_add,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: StreamBuilder<FFChatInfo>(
          stream: FFChatManager.instance.getChatInfo(
            otherUserRecord: widget.chatUser,
            chatReference: widget.chatRef,
          ),
          builder: (context, snapshot) => snapshot.hasData
              ? FFChatPage(
                  chatInfo: snapshot.data!,
                  allowImages: true,
                  
                  backgroundColor:
                      FlutterFlowTheme.of(context).primaryBackground,
                  timeDisplaySetting: TimeDisplaySetting.visibleOnTap,
                  currentUserBoxDecoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  otherUsersBoxDecoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  currentUserTextStyle:
                      FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                  otherUsersTextStyle: FlutterFlowTheme.of(context).bodyMedium,
                  inputHintTextStyle: FlutterFlowTheme.of(context).bodySmall,
                  inputTextStyle:
                      FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).alternate,
                            fontWeight: FontWeight.bold,
                          ),
                  emptyChatWidget: Image.asset(
                    'assets/images/messagesEmpty@2x.png',
                    width: MediaQuery.sizeOf(context).width * 0.76,
                  ),
                )
              : Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
