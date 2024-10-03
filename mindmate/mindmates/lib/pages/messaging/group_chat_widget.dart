import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mindmates/auth/firebase_auth/auth_util.dart';
import 'package:mindmates/components/notifications/model.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/messaging/add_users_list.dart';
import 'package:mindmates/pages/messaging/group_info_edit.dart';
import 'package:mindmates/pages/messaging/group_info_view_only.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class GroupChatWidget extends StatefulWidget {
  final groupId;
  final groupName;
  final groupProfile;
  final isAdmin;

  const GroupChatWidget({
    super.key,
    // required this.receiverId,
    required this.groupId,
    required this.groupName,
    required this.groupProfile,
    required this.isAdmin,
  });

  @override
  State<GroupChatWidget> createState() => _GroupChatWidgetState();
}

class _GroupChatWidgetState extends State<GroupChatWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final picker = ImagePicker();
  bool isExpanded = false;
  List<String> groupMemberTokens = [];
  String server = '';

  List<File> _imageFiles = [];
  // String receiverId = 'AA2TvlRX6tgYJFsCHkjt5tN73fs1';

  Future<Map<String, bool>> isUserBlocked(
      String? currentUserID, String targetUserID) async {
    final currentUserBlockedDoc =
        await _firestore.collection('blocked_users').doc(currentUserID).get();
    final targetUserBlockedDoc =
        await _firestore.collection('blocked_users').doc(targetUserID).get();

    final isCurrentUserBlockedByTarget = targetUserBlockedDoc
            .data()?['blocked_users']
            ?.contains(currentUserID) ??
        false;
    final isTargetUserBlockedByCurrent = currentUserBlockedDoc
            .data()?['blocked_users']
            ?.contains(targetUserID) ??
        false;

    return {
      'isCurrentUserBlockedByTarget': isCurrentUserBlockedByTarget,
      'isTargetUserBlockedByCurrent': isTargetUserBlockedByCurrent,
    };
  }

  String createChatId(String senderId, String receiverId) {
    // Sort the user IDs to ensure consistency in creating the chat ID
    List<String> sortedIds = [senderId, receiverId]..sort();

    // Concatenate the sorted user IDs with an underscore in between
    String chatId = '${sortedIds[0]}_${sortedIds[1]}';

    return chatId;
  }

  // Define a boolean variable to track if the image upload is in progress
  bool isUploading = false;

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      await pickImages();
    }
  }

  Future<void> pickImages() async {
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      final List<File> newImages =
          pickedImages.map((image) => File(image.path)).toList();
      if (_imageFiles.length + newImages.length <= 30) {
        // Check the total number of images
        setState(() {
          _imageFiles.addAll(newImages);
        });
      } else {
        // Display a message or notification indicating the limit has been reached
      }
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> imageUrls = [];

    // Set isUploading to true to indicate that the upload has started
    isUploading = true;

    try {
      for (int i = 0; i < _imageFiles.length; i++) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('chats/${DateTime.now().toString()}');
        final UploadTask uploadTask = storageReference.putFile(_imageFiles[i]);
        final TaskSnapshot snapshot = await uploadTask;
        final String url = await snapshot.ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      // Handle any errors that occur during image upload
      print('Error uploading images: $e');
    } finally {
      // Set isUploading to false to indicate that the upload has finished
      isUploading = false;
    }

    // Perform any actions needed after image upload is complete
    createChat();

    return imageUrls;
  }

  Future<void> sendPhoto(
      String replyid, String replyContent, String replyType) async {
    if (isUploading) {
      // setState(() {
      //   isUploading = true;
      // });
      return; // Prevent sending photos while upload is in progress
    }

    await requestStoragePermission();

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference messagesRef = firestore.collection('messagesGroup');
    final userId = currentUserUid;
    // String chatId = createChatId(widget.receiverId, userId!);

    try {
      final List<String> imageUrls = await uploadImages();

      for (String imageUrl in imageUrls) {
        DocumentReference documentRef = await messagesRef.add({
          'senderId': userId,
          // 'receiverId': widget.receiverId,
          'groupId': widget.groupId,
          'type': 'photo', // 'text' or 'image'
          'content': imageUrl, // Image URL
          'replyId': replyid,
          'replyContent': replyContent,
          'replyType': replyType,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await documentRef.update({'id': documentRef.id});
      }
    } catch (e) {
      // Handle any errors that occur during image upload
      print('Error uploading images: $e');
    }

    // Clear the list of selected images after successful upload
    setState(() {
      _imageFiles.clear();
    });
  }

  Future<void> createChat() async {
    final userId = currentUserUid;
    // ignore: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation
    // String chatId = '${widget.receiverId}_$userId';
    // String chatId = createChatId(widget.receiverId, userId!);

    await FirebaseFirestore.instance
        .collection('chatsGroup')
        .doc(widget.groupId)
        .update({
      'lastmessage': _msgController.text.trim(),
      'seenby': [],
      'sender': currentUserUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage(String messageType, String replyid,
      String replyContent, String replyType) async {
    createChat();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference messagesRef = firestore.collection('messagesGroup');
    final userId = currentUserUid;
    // ignore: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation
    // String chatId = createChatId(widget.receiverId, userId);

    DocumentReference documentRef = await messagesRef.add({
      'senderId': userId,
      // 'receiverId': widget.receiverId,
      'groupId': widget.groupId,
      'type': messageType, // 'text' or 'image'
      'content': _msgController.text.trim(), // Image URL
      'replyId': replyid,
      'replyContent': replyContent,
      'replyType': replyType,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // _msgController.clear();
    await documentRef.update({'id': documentRef.id});
  }

  void initState() {
    super.initState();
    getFCMServerKey();
    fetchGroupMemberTokens();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // After the frame is rendered, scroll to the bottom
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void getFCMServerKey() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    // await remoteConfig.
    var data = remoteConfig.getString('FCM');
    if (data.isNotEmpty) {
      // String serverToken = jsonDecode(data)["FCM"];
      setState(() {
        server = data;
      });
      print(
        "CORRECT configure Remote config in firebase: $server",
      );
    } else {
      print(
        "Please configure Remote config in firebase",
      );
    }
  }

  Future<void> fetchGroupMemberTokens() async {
    try {
      // Access the Firestore collection for the specific group
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('chatsGroup')
          .doc(widget.groupId)
          .get();

      // Retrieve the list of member IDs from the group document
      List<dynamic> memberIds = groupSnapshot['users'];

      List<String> tokens = [];
      // Fetch tokens for each member
      for (var memberId in memberIds) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();
        String token = userSnapshot['token'];
        tokens.add(token);
      }

      // Update the state with the fetched tokens
      setState(() {
        groupMemberTokens = tokens;
      });
    } catch (e) {
      print('Error fetching group member tokens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // List<String> sortedIds = [currentUserUid, widget.receiverId]..sort();

    // // Concatenate the sorted user IDs with an underscore in between
    // String chatId = '${sortedIds[0]}_${sortedIds[1]}';

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primary),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        title: GestureDetector(
          onTap: () {
            widget.isAdmin
                ? Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupInfoEdit(
                          groupId: widget.groupId,
                        )))
                : Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GroupInfoViewOnly(
                          groupId: widget.groupId,
                        )));
          },

          // onTap: () => ,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            // height: 100,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  foregroundImage: widget.groupProfile != null
                      ? NetworkImage(widget.groupProfile!)
                      : null,
                  child: const Icon(Icons.person),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    widget.groupName,
                    style: TextStyle(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                // widget.professional
                //     ? Padding(
                //         padding:
                //             EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                //         child: Icon(
                //           Icons.verified,
                //           color: Color(0xFF12CCEE),
                //         ),
                //       )
                //     : Container(),
              ],
            ),
          ),
        ),
        actions: [
          widget.isAdmin
              ? StreamBuilder<QuerySnapshot>(
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

                    return IconButton(
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => AddusersWidget(
                                      groupId: widget.groupId,
                                      member: members,
                                    )))),
                        icon: Icon(Icons.add_circle_outline_outlined));
                  })
              : Container()
        ],
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 120),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messagesGroup')
                .where('groupId', isEqualTo: widget.groupId)
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While waiting for the result, you can return a loading indicator or null.
                // return CircularProgressIndicator(); // Replace with your loading indicator.
                return Center(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: const Text('..')));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Image.asset(
                  'assets/images/messagesEmpty@2x.png',
                  width: MediaQuery.sizeOf(context).width * 0.76,
                ));
              }
              if (snapshot.error != null) {
                return Center(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: const Text('Error loading chats...')),
                );
              }
              Map<String, List<Map<String, dynamic>>> messagesByDate = {};
              List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
              for (var document in documents) {
                // Check if the 'timestamp' field exists and is not null
                if (document['timestamp'] != null &&
                    document['timestamp'] is Timestamp) {
                  DateTime messageDate =
                      (document['timestamp'] as Timestamp).toDate();
                  String dateKey =
                      '${messageDate.year}-${messageDate.month.toString().padLeft(2, '0')}-${messageDate.day.toString().padLeft(2, '0')}';
                  messagesByDate[dateKey] ??= [];
                  messagesByDate[dateKey]!
                      .add(document.data() as Map<String, dynamic>);
                }
              }

              // Extract the date keys to use as subheadings
              List<String> dateKeys = messagesByDate.keys.toList();
              dateKeys.sort((a, b) {
                DateTime dateA = DateTime.parse(a);
                DateTime dateB = DateTime.parse(b);
                return dateB
                    .compareTo(dateA); // Sort dateKeys in descending order
              });

              return ListView.builder(
                itemCount: dateKeys.length,
                reverse: true,
                itemBuilder: (context, index) {
                  String dateKey = dateKeys[index];
                  List<Map<String, dynamic>> messagesForDate =
                      messagesByDate[dateKey]!
                          .reversed
                          .toList(); // Reverse the list here

                  return Column(
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 167, 167, 167),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Text(
                            dateKey,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chatsGroup')
                              .where('id', isEqualTo: widget.groupId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 30, 0, 0),
                                    child: const Text('..')),
                              );
                            }
                            if (snapshot.error != null) {
                              return Center(
                                child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 30, 0, 0),
                                    child:
                                        const Text('Error loading chats...')),
                              );
                            }

                            final messagedata = snapshot.data!.docs.first;
                            final messageInfo = messagedata.data() as Map<
                                String,
                                dynamic>; // Explicitly cast to the correct type

                            String lastChat = messageInfo['lastmessage'];
                            return ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                controller: _scrollController,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: messagesForDate.length,
                                itemBuilder: (context, index) {
                                  if (index < messagesForDate.length) {
                                    String messageText =
                                        messagesForDate[index]['content'];
                                    String messageType =
                                        messagesForDate[index]['type'];
                                    // Timestamp? messageTime =
                                    //     messagesForDate[index]['timestamp']
                                    //         as Timestamp?;
                                    String isMe =
                                        messagesForDate[index]['senderId'];
                                    String msgId = messagesForDate[index]['id'];
                                    String replyMsg =
                                        messagesForDate[index]['replyContent'];

                                    String replyType =
                                        messagesForDate[index]['replyType'];

                                    String msg =
                                        messagesForDate[index]['content'];
                                    // String senderId = messagesForDate[index]
                                    //     ['content'];

                                    if (messagesForDate[index]['timestamp'] !=
                                        null) {
                                      Timestamp messageTime =
                                          messagesForDate[index]['timestamp'];
                                      // Proceed with using messageTime
                                      DateTime dateTime = messageTime.toDate();
                                      // String u = user

                                      String postTime =
                                          DateFormat('h:mm a').format(dateTime);
                                      return StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('users')
                                              .where('uid', isEqualTo: isMe)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.data!.docs.isEmpty) {
                                              return Container();
                                            }
                                            if (snapshot.error != null) {
                                              return const Center(
                                                child: Text(
                                                    'Error loading data...'),
                                              );
                                            }

                                            final userdata =
                                                snapshot.data!.docs.first;
                                            final userInfo = userdata.data() as Map<
                                                String,
                                                dynamic>; // Explicitly cast to the correct type

                                            final String userProfile =
                                                userInfo['photo_url'];
                                            final String userName =
                                                userInfo['userName'];

                                            return messageType == 'text'
                                                ? GestureDetector(
                                                    onHorizontalDragEnd:
                                                        (details) {
                                                      if (details
                                                              .primaryVelocity! >
                                                          0) {
                                                        reply(
                                                            context,
                                                            msgId,
                                                            msg,
                                                            messageType,
                                                            isMe,
                                                            userName);

                                                        // repId,repContent, repType
                                                      }
                                                    },
                                                    onLongPress: () {
                                                      if (isMe ==
                                                          currentUserUid) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Remove Message'),
                                                              content: const Text(
                                                                  'Do you really want to remove this message? This will be removed for all users!'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    // Implement delete functionality here
                                                                    // For example, delete the image from Firestore
                                                                    // Then close the dialog
                                                                    final collection = FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'messages');
                                                                    collection
                                                                        .doc(
                                                                            msgId) // <-- Doc ID to be deleted.
                                                                        .delete() // <-- Delete
                                                                        .then((_) => lastChat ==
                                                                                msg
                                                                            ? FirebaseFirestore.instance.collection('chatsGroup').doc(widget.groupId).update({
                                                                                'lastmessage': 'Message has been deleted',
                                                                                'timestamp': FieldValue.serverTimestamp()
                                                                              })
                                                                            : null)
                                                                        .catchError(
                                                                            (error) {
                                                                      // ignore: invalid_return_type_for_catch_error
                                                                      return Text(
                                                                          'Delete failed: $error');
                                                                    });

                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Delete'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    // Close the dialog without deleting
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                      ;
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .fromLTRB(
                                                          14, 14, 14, 14),
                                                      child: IntrinsicHeight(
                                                        child:
                                                            FractionallySizedBox(
                                                          alignment: isMe ==
                                                                  currentUserUid
                                                              ? Alignment
                                                                  .centerRight
                                                              : Alignment
                                                                  .centerLeft,
                                                          // widthFactor: MediaQuery.of(context).size.width * .6,
                                                          child: Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxWidth: isMe !=
                                                                      currentUserUid
                                                                  ? MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .71
                                                                  : MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .6,
                                                            ),
                                                            alignment: isMe ==
                                                                    currentUserUid
                                                                ? Alignment
                                                                    .centerRight
                                                                : Alignment
                                                                    .centerLeft,
                                                            // width: isMe != currentUserUid
                                                            //     ? MediaQuery.of(context).size.width *
                                                            //         .71
                                                            //     : MediaQuery.of(context).size.width *
                                                            //         .6,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                isMe != currentUserUid
                                                                    ? Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .1,
                                                                        margin: const EdgeInsets
                                                                            .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            10,
                                                                            0),
                                                                        child:
                                                                            CircleAvatar(
                                                                          //  radius: 20,
                                                                          foregroundImage: userProfile.isNotEmpty
                                                                              ? NetworkImage(userProfile)
                                                                              : null,
                                                                          child:
                                                                              const Icon(Icons.person),
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                                Container(
                                                                  alignment: isMe ==
                                                                          currentUserUid
                                                                      ? Alignment
                                                                          .centerRight
                                                                      : Alignment
                                                                          .centerLeft,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .6,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  // height: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: isMe ==
                                                                            currentUserUid
                                                                        ? Colors
                                                                            .white
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    // boxShadow: [
                                                                    //   const BoxShadow(
                                                                    //       // color: Colors.white, //New
                                                                    //       blurRadius: 2.0,
                                                                    //       offset: Offset(0, 1))
                                                                    // ],
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(6)),
                                                                  ),
                                                                  child: Column(
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            replyMsg != ''
                                                                                ? IntrinsicHeight(
                                                                                    child: replyType == 'text'
                                                                                        ? Container(
                                                                                            padding: const EdgeInsets.all(8),
                                                                                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                                                            decoration: BoxDecoration(
                                                                                              color: isMe != currentUserUid ? Colors.green[200] : Colors.blue[100],
                                                                                              border: Border(
                                                                                                left: BorderSide(
                                                                                                  color: isMe == currentUserUid ? Colors.grey[200]! : Colors.grey[400]!,
                                                                                                  width: 4,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            width: MediaQuery.of(context).size.width * .6,
                                                                                            child: Text(
                                                                                              replyMsg,
                                                                                              maxLines: 4, // Set max lines based on the expanded state
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              style: TextStyle(color: FlutterFlowTheme.of(context).alternate),
                                                                                            ))
                                                                                        : Container(
                                                                                            padding: const EdgeInsets.all(8),
                                                                                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                                                            decoration: BoxDecoration(
                                                                                              color: isMe != currentUserUid ? Colors.green[200] : Colors.blue[100],
                                                                                              border: Border(
                                                                                                left: BorderSide(
                                                                                                  color: isMe == currentUserUid ? Colors.grey[200]! : Colors.grey[400]!,
                                                                                                  width: 4,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            width: MediaQuery.of(context).size.width * .6,
                                                                                            alignment: Alignment.centerRight,
                                                                                            child: Container(
                                                                                              height: 44,
                                                                                              width: 44,
                                                                                              decoration: BoxDecoration(
                                                                                                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                                                  image: DecorationImage(
                                                                                                    image: NetworkImage(
                                                                                                      replyMsg,
                                                                                                    ),
                                                                                                    fit: BoxFit.cover,
                                                                                                  )),
                                                                                            )),
                                                                                  )
                                                                                : Container(),
                                                                            Container(
                                                                              alignment: isMe == currentUserUid ? Alignment.centerRight : Alignment.centerLeft,
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  isMe == currentUserUid
                                                                                      ? Container()
                                                                                      : Text(
                                                                                          userName,
                                                                                          style: TextStyle(
                                                                                            color: isMe == currentUserUid ? Colors.transparent : Colors.amber,
                                                                                            fontSize: 13,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                  isExpanded
                                                                                      ? Text(
                                                                                          msg,
                                                                                          maxLines: 14, // Set max lines based on the expanded state
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          style: TextStyle(fontSize: 14, color: isMe == currentUserUid ? FlutterFlowTheme.of(context).alternate : FlutterFlowTheme.of(context).tertiary),
                                                                                        )
                                                                                      : Text(
                                                                                          msg,
                                                                                          // maxLines: !isExpanded ? null : 10, // Set max lines based on the expanded state
                                                                                          // overflow: TextOverflow.ellipsis,
                                                                                          style: TextStyle(fontSize: 14, color: isMe == currentUserUid ? FlutterFlowTheme.of(context).alternate : FlutterFlowTheme.of(context).tertiary),
                                                                                        ),
                                                                                  msg.split('\n').length > 14
                                                                                      ? GestureDetector(
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              isExpanded = !isExpanded;
                                                                                            });
                                                                                          },
                                                                                          child: Container(
                                                                                            alignment: Alignment.bottomRight,
                                                                                            child: Text(
                                                                                              !isExpanded ? 'Read Less' : 'Read More',
                                                                                              style: TextStyle(
                                                                                                color: Color.fromARGB(255, 109, 189, 255),
                                                                                                fontSize: 11,
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : Container(),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.fromLTRB(2, 10, 2, 2),
                                                                              alignment: Alignment.bottomRight,
                                                                              child: Text(
                                                                                postTime,
                                                                                style: TextStyle(
                                                                                  fontSize: 9,
                                                                                  color: isMe != currentUserUid ? Colors.white : FlutterFlowTheme.of(context).primary,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ]),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onHorizontalDragEnd:
                                                        (details) {
                                                      if (details
                                                              .primaryVelocity! >
                                                          0) {
                                                        reply(
                                                            context,
                                                            msgId,
                                                            msg,
                                                            messageType,
                                                            isMe,
                                                            userName);

                                                        // repId,repContent, repType
                                                      }
                                                    },
                                                    onTap: () => Navigator.of(
                                                            context)
                                                        .push(MaterialPageRoute(
                                                            builder: (context) =>
                                                                SentImages(
                                                                    photo:
                                                                        messageText))),
                                                    onLongPress: () {
                                                      if (isMe ==
                                                          currentUserUid) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Remove photo'),
                                                              content: const Text(
                                                                  'Do you really want to remove this photo? This will be removed for all users!'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    // Implement delete functionality here
                                                                    // For example, delete the image from Firestore
                                                                    // Then close the dialog
                                                                    final collection = FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'messages');
                                                                    collection
                                                                        .doc(
                                                                            msgId) // <-- Doc ID to be deleted.
                                                                        .delete() // <-- Delete
                                                                        .then((_) =>
                                                                            print(
                                                                                'Deleted'))
                                                                        .catchError((error) =>
                                                                            print('Delete failed: $error'));

                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'chatsGroup')
                                                                        .doc(widget
                                                                            .groupId)
                                                                        .update({
                                                                      'lastmessage':
                                                                          'Message has been deleted',
                                                                      'timestamp':
                                                                          FieldValue
                                                                              .serverTimestamp(),
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Delete'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    // Close the dialog without deleting
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                      ;
                                                    },
                                                    child: FractionallySizedBox(
                                                      alignment:
                                                          isMe == currentUserUid
                                                              ? Alignment
                                                                  .centerRight
                                                              : Alignment
                                                                  .centerLeft,
                                                      // widthFactor:
                                                      //     0.6,
                                                      child: Container(
                                                        margin: isMe ==
                                                                currentUserUid
                                                            ? const EdgeInsets
                                                                .fromLTRB(
                                                                0, 0, 10, 10)
                                                            : null,
                                                        alignment: isMe ==
                                                                currentUserUid
                                                            ? Alignment
                                                                .centerRight
                                                            : Alignment
                                                                .centerLeft,
                                                        width: isMe !=
                                                                currentUserUid
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .71
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .6,
                                                        child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              isMe != currentUserUid
                                                                  ? SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .17,
                                                                      child:
                                                                          CircleAvatar(
                                                                        //  radius: 20,
                                                                        foregroundImage: userProfile.isNotEmpty
                                                                            ? NetworkImage(userProfile)
                                                                            : null,
                                                                        child: const Icon(
                                                                            Icons.person),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                              Container(
                                                                // alignment: Alignment.center,
                                                                width: isMe !=
                                                                        currentUserUid
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .4
                                                                    : MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .4,
                                                                alignment: isMe ==
                                                                        currentUserUid
                                                                    ? Alignment
                                                                        .centerRight
                                                                    : Alignment
                                                                        .centerLeft,

                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isMe ==
                                                                          currentUserUid
                                                                      ? Colors
                                                                          .white
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                  // boxShadow: [
                                                                  //   const BoxShadow(
                                                                  //       color: Color.fromARGB(255, 182, 182, 182), //New
                                                                  //       blurRadius: 2.0,
                                                                  //       offset: Offset(0, 1))
                                                                  // ],
                                                                  // border: Border.all(
                                                                  //     width: 1,
                                                                  //     // style: BorderStyle.
                                                                  //     color: Theme.of(context).shadowColor),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              6)),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    replyMsg !=
                                                                            ''
                                                                        ? IntrinsicHeight(
                                                                            child: replyType == 'text'
                                                                                ? Container(
                                                                                    padding: const EdgeInsets.all(8),
                                                                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                                                    decoration: BoxDecoration(
                                                                                      color: isMe != currentUserUid ? Colors.green[200] : Colors.blue[100],
                                                                                      border: Border(
                                                                                        left: BorderSide(
                                                                                          color: isMe == currentUserUid ? Colors.grey[200]! : Colors.grey[400]!,
                                                                                          width: 4,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    width: MediaQuery.of(context).size.width * .6,
                                                                                    child: Text(
                                                                                      replyMsg,
                                                                                      maxLines: 4, // Set max lines based on the expanded state
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: TextStyle(color: FlutterFlowTheme.of(context).alternate),
                                                                                    ))
                                                                                : Container(
                                                                                    padding: const EdgeInsets.all(8),
                                                                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                                                    decoration: BoxDecoration(
                                                                                      color: isMe != currentUserUid ? Colors.green[200] : Colors.blue[100],
                                                                                      border: Border(
                                                                                        left: BorderSide(
                                                                                          color: isMe == currentUserUid ? Colors.grey[200]! : Colors.grey[400]!,
                                                                                          width: 4,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    width: MediaQuery.of(context).size.width * .6,
                                                                                    alignment: Alignment.centerRight,
                                                                                    child: Container(
                                                                                      height: 44,
                                                                                      width: 44,
                                                                                      decoration: BoxDecoration(
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                                          image: DecorationImage(
                                                                                            image: NetworkImage(
                                                                                              replyMsg,
                                                                                            ),
                                                                                            fit: BoxFit.cover,
                                                                                          )),
                                                                                    )),
                                                                          )
                                                                        : Container(),
                                                                    Container(
                                                                      height:
                                                                          160,
                                                                      // width: 0,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(6.0), topLeft: Radius.circular(6.0)),
                                                                          image: DecorationImage(
                                                                            image:
                                                                                NetworkImage(
                                                                              messageText,
                                                                            ),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .fromLTRB(
                                                                          2,
                                                                          10,
                                                                          2,
                                                                          2),
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomRight,
                                                                      child:
                                                                          Text(
                                                                        postTime,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              9,
                                                                          color: isMe != currentUserUid
                                                                              ? Colors.white
                                                                              : FlutterFlowTheme.of(context).primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                    ),
                                                  );
                                          });
                                    }
                                  }
                                });
                          }),
                    ],
                  );
                },
              );
            }),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Form(
          child: IntrinsicHeight(
            child: Container(
              // height: 60,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(255, 241, 241, 241),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromARGB(255, 209, 209, 209), //New
                      blurRadius: 6.0,
                      offset: Offset(0, 1))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .62,
                    child: TextFormField(
                      controller: _msgController,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                      decoration: InputDecoration(
                        hintText: 'Send message...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).shadowColor,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0x00000000),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      sendPhoto('', '', '').then((value) => NotifModel()
                          .sendFCMMessage(
                              groupMemberTokens,
                              '$currentUserName sent a photo',
                              server,
                              widget.groupName));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_msgController.text.trim() != '') {
                        sendMessage('text', '', '', '').then((value) =>
                            NotifModel().sendFCMMessage(
                                groupMemberTokens,
                                '$currentUserName: ${_msgController.text.trim()}',
                                server,
                                widget.groupName));
                        // String replyid, String replyContent, String replyType
                      }
                    },
                    child: Icon(
                      Icons.send_outlined,
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

//REPLY
////

  Future<void> reply(BuildContext context, String repId, String repContent,
      String repType, String senderIdent, String senderName) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Set this property to true
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              child: Form(
                child: IntrinsicHeight(
                  child: Container(
                    // height: 60,
                    width: MediaQuery.of(context).size.width * .9,
                    margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      color: Color.fromARGB(255, 241, 241, 241),
                      boxShadow: [
                        // BoxShadow(
                        //     color: Color.fromARGB(255, 209, 209, 209), //New
                        //     blurRadius: 6.0,
                        //     offset: Offset(0, 1))
                      ],
                    ),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: repType == 'text'
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.green[500]!,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * .9 -
                                          10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        senderIdent == currentUserUid
                                            ? 'You'
                                            : senderName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: FlutterFlowTheme.of(context)
                                              .primary, //New
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        repContent,
                                        maxLines:
                                            4, // Set max lines based on the expanded state
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Color.fromARGB(
                                              255, 46, 46, 46), //New
                                        ),
                                      ),
                                    ],
                                  ))
                              : Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(185, 250, 0, 250),
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        senderIdent == currentUserUid
                                            ? 'You'
                                            : senderName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Color.fromARGB(
                                              255, 186, 83, 255), //New
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(3)),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  repContent,
                                                ),
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      ),
                                    ],
                                  )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .62,
                              child: TextFormField(
                                controller: _msgController,
                                minLines: 1,
                                maxLines: 5,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Send a reply...',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).shadowColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                sendPhoto(repId, repContent, repType).then(
                                    (value) => NotifModel().sendFCMMessage(
                                        groupMemberTokens,
                                        '$currentUserName sent a photo',
                                        server,
                                        widget.groupName));

                                // String replyid, String replyContent, String replyType
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_msgController.text.trim() != '') {
                                  Navigator.pop(context);
                                  sendMessage(
                                          'text', repId, repContent, repType)
                                      .then((value) => NotifModel().sendFCMMessage(
                                          groupMemberTokens,
                                          '$currentUserName: ${_msgController.text.trim()}',
                                          server,
                                          widget.groupName));
                                }
                              },
                              child: Icon(
                                Icons.send_outlined,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class SentImages extends StatelessWidget {
  final photo;
  const SentImages({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(
        photo,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
