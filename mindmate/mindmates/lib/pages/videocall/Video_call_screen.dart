
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/pages/videocall/app_bar.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomId;
  final String token;
  final bool isAdmin;
  final uid;

  const VideoCallScreen(
      {Key? key,
      required this.roomId,
      required this.token,
      required this.isAdmin,
      required this.uid})
      : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  
  RtcEngine? _engine;
  bool _isJoined = false;
  int? _remoteUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isKicked = false; // To track if the user was kicked out

  @override
  void initState() {
    super.initState();
    // _initAgora();
    _initializeAgoraEngine();
    _listenForKickedStatus(); // Start listening for kicked status
    // Listen for room end status
    _listenForRoomEndStatus();
  }

  Future<void> _initializeAgoraEngine() async {
    await [Permission.microphone, Permission.camera]
        .request(); // Request audio permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      print('Permissions not granted');
      return;
    }
    if (_engine == null) {
      // ; // Already initialized

      _engine = createAgoraRtcEngine();
      // try {
      // Replace with your actual Agora App ID
      await _engine!.initialize(
          RtcEngineContext(
            appId: '10a1b2098d2e45e59100af945e38ef99',
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
            ));

      
    }

    // Set up event listeners (remote user joining, leaving, etc.)
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Local user joined successfully');
          setState(() {
            _isJoined = true;
          });
           _addParticipantToRoom();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('Remote user joined: $remoteUid');
          setState(() {
            _remoteUid = remoteUid;
          });
           _updateAgoraUidForParticipant(_remoteUid!);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print('Remote user left: $remoteUid');
          setState(() {
            _remoteUid = null;
          });
         
        },
         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onError: (ErrorCodeType errorCode, String errorMessage) {
          print('Agora Error: $errorCode, Message: $errorMessage');
        },
      ),
    );

     // Enable video and audio
      await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      await _engine!.startPreview();

        await _engine!.joinChannel(
        token: widget.token,
        channelId: widget.roomId,
        uid: widget.uid,
        options: ChannelMediaOptions(
            autoSubscribeAudio: true, autoSubscribeVideo: true),
      );
    
  }

// This function adds the remote user to Firestore by their Agora UID
  // Function to update the Agora UID for a remote participant
  void _updateAgoraUidForParticipant(int remoteUid) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Update Firestore document for the current user with the Agora UID
    await _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('participants')
        .doc(userId)
        .update({
      'agoraUid': remoteUid, // Store the remote UID in Firestore
    });
  }

  // Function to add the local participant to Firestore room
  void _addParticipantToRoom() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('participants')
        .doc(userId)
        .update({
      'joinedAt': FieldValue.serverTimestamp(),
      'agoraUid': 0, // Local user UID (0 for auto-assignment)
    });
  }

  String getCurrentUserId() {
    return FirebaseAuth
        .instance.currentUser!.uid; // Ensure user is authenticated
  }

  // Listen to Firestore for "kicked" status
  void _listenForKickedStatus() {
    final userId = getCurrentUserId(); // Dynamically get current user ID
    _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('participants')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['kicked'] == true) {
        setState(() {
          _isKicked = true;
        });
        _leaveRoom(); // Force the user to leave the room
      }
    });
  }

  

  // Function to remove (kick) a participant (admin action)
  void _removeUser(int remoteUid) async {
    if (widget.isAdmin) {
      // Fetch participants where agoraUid matches remoteUid
      final querySnapshot = await _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('participants')
          .where('agoraUid', isEqualTo: remoteUid)
          .get();

      // Check if a participant with the matching agoraUid exists
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          // Update the kicked field to true for the matching participant
          await doc.reference.update({
            'kicked': true,
          });
        }
      }
    }
  }

  Future<void> _leaveRoom() async {
    await _engine!.leaveChannel();
    Navigator.pop(context);
  }

  void _showEndSessionConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Session'),
          content: const Text(
              'Are you sure you want to end the session for everyone?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // Close the dialog without doing anything
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('End Session'),
              onPressed: () {
                // End the session for everyone
                _endSessionForEveryone();
                // Close the dialog after ending the session
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _endSessionForEveryone() async {
    if (widget.isAdmin) {
      // Mark the room as inactive in Firestore
      await _firestore.collection('rooms').doc(widget.roomId).update({
        'active': false, // Mark the room as inactive
      });

      // Leave the Agora channel
      await _engine?.leaveChannel();

      // Destroy the Agora engine instance
      await _engine?.release();

      // Optionally notify participants (already shown in previous examples)
      _notifyParticipantsRoomEnded();

      // Navigate back to the previous page (e.g., home screen)
      Navigator.pop(context);
    }
  }

  void _notifyParticipantsRoomEnded() {
    // Fetch all participants in the room
    _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('participants')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        // Notify each participant by updating their individual status
        doc.reference.update({'roomEnded': true});
        // _listenForRoomEndStatus();
      }
    });
  }

  void _listenForRoomEndStatus() {
    _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['active'] == false) {
        // The room has been ended by the admin
        _leaveRoom(); // Leave the Agora session and navigate away
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: '10a1b2098d2e45e59100af945e38ef99',
      channelName: widget.roomId,
      username: widget.roomId,
    ),
  );
    return Scaffold(
      appBar: VideoScreenAppBar(roomId: widget.roomId, isAdmin: widget.isAdmin, endSession: _showEndSessionConfirmationDialog,),
      body: Stack(
        children: [
          // Full screen remote video
          _remoteUid != null
              ? Positioned.fill(
                  child: AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: _remoteUid!),
                      connection: RtcConnection(channelId: widget.roomId),
                    ),
                  ),
                )
              : const Center(
                  child: Text('Waiting for remote user...'),
                ),

          // Small local video in the corner
          Positioned(
            top: 20, // Adjust this value to position the small video vertically
            right:
                20, // Adjust this value to position the small video horizontally
            child: _isJoined
                ? Container(
                    width: 120, // Width of the local video view
                    height: 160, // Height of the local video view
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: 
                        AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine!,
                            canvas: VideoCanvas(uid: 0),
                          ),
                        ),
                     
                  )
                : const CircularProgressIndicator(),
          ),

          // Admin controls (if the user is an admin and remote user is present)
          if (widget.isAdmin && _remoteUid != null)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () =>
                    _removeUser(_remoteUid!), // Admin can remove user
              ),
            ),

               Positioned(
                bottom: 30,
                child: Center(child: AgoraVideoButtons(client: client))),

          // Message if the user has been kicked out
          if (_isKicked)
            const Center(
              child: Text(
                'You have been removed from the call.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
        ],
      ),

    
    );
  }
}
