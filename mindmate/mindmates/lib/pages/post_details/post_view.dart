import 'dart:io';

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ViewPost extends StatefulWidget {
  final photo;
  final page;
  const ViewPost({super.key, required this.photo, required this.page});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  bool _downloading = false;

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      _downloadImage();
    }
  }

  Future<void> _downloadImage() async {
    setState(() {
      _downloading = true;
    });
    final snackBar = SnackBar(
      content: const Text('Saving image...'),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      // Make the HTTP GET request
      final http.Response response = await http.get(Uri.parse(widget.photo));
      

      // Get the DCIM directory
       final Directory dcimDir = Directory('/storage/emulated/0/Pictures');

   
     
      // Create a subdirectory with your app's name
       Directory appDir = Directory('${dcimDir.path}/Mindmate/Posts');
         if (widget.page == 'Post'){
setState(() {
   appDir = Directory('${dcimDir.path}/Mindmate/Posts');
});
      } else if (widget.page == 'Chat'){
setState(() {
   appDir = Directory('${dcimDir.path}/Mindmate/Chats');

});
      }
      if (!appDir.existsSync()) {
        await appDir.create(recursive: true);
      }

      // Get the current date and time
      final DateTime now = DateTime.now();

      // Format the date and time
      final String formattedDateTime =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}${now.second}';

      // Construct the file name
      final String fileName = 'IMG_$formattedDateTime.jpg';

      // Create a new file in the app directory with the constructed file name
      final File file = File('${appDir.path}/$fileName');

      // Write the image data to the file
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _downloading = false;
      });
    } catch (e) {
      print('erorr: $e');
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 14, 10, 10),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed: () {
                  requestStoragePermission();
                },
                icon: const Icon(
                  Icons.download,
                  color: Colors.grey,
                )),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 100,
             width: MediaQuery.of(context).size.width,
            child: Center(
                child: InteractiveViewer(
                  child: Image.network(
                              widget.photo,
                              fit: BoxFit.fitHeight,
                            ),
                )),
          ),
        ],
      ),
    );
  }
}
