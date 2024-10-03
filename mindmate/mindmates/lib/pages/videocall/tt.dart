import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class VideoCallHomeScreenT extends StatefulWidget {
  const VideoCallHomeScreenT({Key? key}) : super(key: key);

  @override
  _VideoCallHomeScreenTState createState() => _VideoCallHomeScreenTState();
}

class _VideoCallHomeScreenTState extends State<VideoCallHomeScreenT> {
  TextEditingController _roomIdController = TextEditingController();
  RtcEngine? _engine;
  String? _sharedRoomId; // Store the meeting ID (roomId)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique channel name for each meeting
  String generateChannelName(String userId) {
    String userIdChunk = userId.length > 6 ? userId.substring(0, 6) : userId;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String timestampChunk = timestamp.length > 4
        ? timestamp.substring(timestamp.length - 4)
        : timestamp;
    return "MIND_${userIdChunk}_${timestampChunk}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Room ID or Create a New One',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createRoom,
                    child: const Text('Create Room (Admin)'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _joinRoom(_roomIdController.text),
                    child: const Text('Join Room'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a new room (channel) and act as admin
  void _createRoom() async {
    final userId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user ID
    _engine = createAgoraRtcEngine();
    String channelName = generateChannelName(userId);

    // Get a token for this channel from Firebase Cloud Functions
    String? token = await fetchAgoraToken(channelName, 0, 'publisher');
    _sharedRoomId = channelName; // Store the room ID (channel name) in session

    // Store room data in Firestore
    _firestore.collection('rooms').doc(channelName).set({
      'roomId': channelName,
      'adminId': userId, // Current user is the admin
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
    });

    // Store the admin as a participant in the room
    _firestore
        .collection('rooms')
        .doc(channelName)
        .collection('participants')
        .doc(userId)
        .set({
      'userId': userId,
      'role': 'admin',
      'kicked': false,
      'agoraUid': 0, // Admin's Agora UID is set to 0
    });

    // Join the Agora channel as the host/admin
    await _engine?.joinChannel(
      token: token!,
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );

    // Redirect to video call page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          roomId: channelName,
          token: token!,
          isAdmin: true, // Pass admin status
        ),
      ),
    );
  }

  // Function to join an existing room as a participant
  void _joinRoom(String roomId) async {
    final userId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user ID

    // Get a token for this channel from Firebase Cloud Functions
    String? token = await fetchAgoraToken(roomId, 0, 'subscriber');

    // Store the participant in Firestore
    _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .doc(userId)
        .set({
      'userId': userId,
      'role': 'participant',
      'kicked': false,
      'agoraUid': 0, // Agora UID will be updated later
    });

    // Redirect to the video call page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          roomId: roomId,
          token: token!,
          isAdmin: false, // Not an admin
        ),
      ),
    );
  }

  Future<String?> fetchAgoraToken(
      String channelName, int uid, String role) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('generateAgoraToken');
      final response = await callable.call(<String, dynamic>{
        'channelName': channelName,
        'uid': uid,
        'role': role,
      });

      final data = response.data as Map<String, dynamic>;
      return data['token'] as String?;
    } catch (e) {
      print('Error fetching Agora token: $e');
      return null;
    }
  }

  // Function to share the Room ID only (without token)
  void _shareRoomIdOnly(String roomId) {
    Share.share('Join my Meeting using Room ID: $roomId');
  }
}

class VideoCallScreen extends StatefulWidget {
  final String roomId;
  final String token;
  final bool isAdmin;

  const VideoCallScreen(
      {Key? key,
      required this.roomId,
      required this.token,
      required this.isAdmin})
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
    _initAgora();
    _listenForKickedStatus(); // Start listening for kicked status
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: '10a1b2098d2e45e59100af945e38ef99'));

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _isJoined = true;
        });

        // Add the local user (Firebase user) to Firestore as a participant
        _addParticipantToRoom();
      },
      // When a remote user joins
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          _remoteUid = remoteUid; // Store the Agora remote UID as int
        });

        // Add remote user to Firestore by mapping their Agora UID to their user ID
        _updateAgoraUidForParticipant(remoteUid);
      },
      // When a remote user leaves or goes offline
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() {
          _remoteUid = null; // Remove from state when user goes offline
        });

        // Optionally, you can remove or update the participant status in Firestore
      },
    ));

    await _engine!.enableVideo();
    await _engine!.startPreview();
    await _engine!.joinChannel(
      token: widget.token,
      channelId: widget.roomId,
      uid: 0, // Local user UID (0 for auto-assignment)
      options: const ChannelMediaOptions(),
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

  // // Function to add participants to Firestore room
  // void _addParticipantToRoom() {
  //   final userId = getCurrentUserId();  // Dynamically get current user ID
  //   _firestore.collection('rooms').doc(widget.roomId).collection('participants').doc(userId).set({
  //     'kicked': false,
  //     'userId': userId,
  //   });
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Admin can share the room ID to invite others
                Share.share(
                    'Join my video call with Room ID: ${widget.roomId}');
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _isJoined
                ? AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: _remoteUid!),
                      connection: RtcConnection(channelId: widget.roomId),
                    ),
                  )
                : const Text(
                    'Waiting for a user to join...',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
          ),
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
          if (_isKicked)
            Center(
              child: Text(
                'You have been removed from the call.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _leaveRoom,
        child: const Icon(Icons.call_end),
      ),
    );
  }
}