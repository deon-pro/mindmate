import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class VideoScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String roomId;
  final bool isAdmin;
  final Function endSession;

  const VideoScreenAppBar({
    Key? key,
    required this.roomId,
    required this.isAdmin,
    required this.endSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Remove the default shadow
      elevation: 0,
      // Create a gradient background
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001f4d), // Dark blue
              Color(0xFF0078FF), // Bright blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      // Center the title for a sleek look
      centerTitle: true,
      title: const Text(
        'Video Call',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          fontFamily: 'RobotoMono', // Optional modern font
          letterSpacing: 1.2,
        ),
      ),
      // Add futuristic-looking icons and actions
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: Colors.white, // Modern white icon
            ),
            onPressed: () {
              // Admin can share the room ID to invite others
              Share.share('Join my video call with Room ID: $roomId');
            },
          ),
        if (isAdmin)
          IconButton(
            icon: const Icon(
              Icons.exit_to_app_rounded,
              color: Colors.redAccent, // Bright exit color for attention
            ),
            onPressed: () {
              // Show confirmation dialog before ending the session
              endSession();
            },
          )
      ],
      // Modern AppBar shape with rounded corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
