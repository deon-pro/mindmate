import 'dart:math';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:mindmates/pages/videocall/Video_call_screen.dart';
import 'package:share_plus/share_plus.dart';

class VideoCallHomeScreen extends StatefulWidget {
  const VideoCallHomeScreen({Key? key}) : super(key: key);

  @override
  _VideoCallHomeScreenState createState() => _VideoCallHomeScreenState();
}

class _VideoCallHomeScreenState extends State<VideoCallHomeScreen> {
  TextEditingController _roomIdController = TextEditingController();
  RtcEngine? _engine;
  // String? _sharedRoomId; // Store the meeting ID (roomId)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Generate a unique channel name for each meeting
  String generateChannelName(String userId) {
    String userIdChunk = userId.length > 6 ? userId.substring(0, 6) : userId;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String timestampChunk = timestamp.length > 6
        ? timestamp.substring(timestamp.length - 6)
        : timestamp;

    // return "MIND_${userIdChunk}_${timestampChunk}";
    return "MIND_${userIdChunk}_${timestampChunk}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindmate Video Room'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Meeting ID or Create a New One',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meeting ID!!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createRoom,
                      child: const Text('Create Room'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        if (isValid) {
                          _joinRoom(_roomIdController.text.trim());
                        }
                      },
                      child: const Text('Join Room'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
    if (_engine != null) return; // Already initialized

    _engine = createAgoraRtcEngine();
    try {
      // Replace with your actual Agora App ID
      await _engine!.initialize(RtcEngineContext(
        appId: '10a1b2098d2e45e59100af945e38ef99',
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
    } catch (e) {
      print("Agora initialization failed: $e");
    }
  }

  void _createRoom() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Step 1: Initialize the Agora engine
    await _initializeAgoraEngine();

    // Step 2: Generate a unique channel name
    String channelName = generateChannelName(userId);

    // Step 3: Fetch Agora token
    String? token = await fetchAgoraToken(channelName, 0, 'publisher');
    if (token == null) {
      print('Failed to fetch token');
      return;
    }

    // Step 4: Store room details in Firestore
    _firestore.collection('rooms').doc(channelName).set({
      'roomId': channelName,
      'adminId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
    });

    // Step 5: Add admin as a participant in Firestore
    _firestore
        .collection('rooms')
        .doc(channelName)
        .collection('participants')
        .doc(userId)
        .set({
      'userId': userId,
      'role': 'admin',
      'kicked': false,
      'agoraUid': 0, // Admin's Agora UID is 0
    });

    // Step 6: Join the Agora channel as the admin
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            roomId: channelName,
            token: token,
            isAdmin: true,
            uid: 0, // Admin's UID
          ),
        ),
      );
    } catch (e) {
      print("Error joining channel as admin: $e");
    }
  }

  // Function to join an existing room as a participant
  void _joinRoom(String roomId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Step 1: Initialize the Agora engine
    await _initializeAgoraEngine();

    // Step 2: Fetch room details from Firestore
    DocumentSnapshot roomSnapshot =
        await _firestore.collection('rooms').doc(roomId).get();
    if (!roomSnapshot.exists) {
      print('Room does not exist.');
      final snackBar = SnackBar(
        content: Text("Sorry!! The meeting does not exist."),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
//
      return;
    }

    bool isAdmin = roomSnapshot['adminId'] == userId;

    // Step 3: Generate a unique Agora UID for the participant
    int agoraUid = isAdmin ? 0 : Random().nextInt(100000);

    // Step 4: Fetch Agora token
    String? token = await fetchAgoraToken(
        roomId, agoraUid, isAdmin ? 'publisher' : 'subscriber');
    if (token == null) {
      print('Failed to fetch token');
      return;
    }

    // Step 5: Add the participant to Firestore
    _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .doc(userId)
        .set({
      'userId': userId,
      'role': isAdmin ? 'admin' : 'participant',
      'kicked': false,
      'agoraUid': agoraUid,
    });

    // Step 6: Join the Agora channel
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            roomId: roomId,
            token: token,
            isAdmin: isAdmin,
            uid: agoraUid,
          ),
        ),
      );
    } catch (e) {
      print("Error joining channel as participant: $e");
    }
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
