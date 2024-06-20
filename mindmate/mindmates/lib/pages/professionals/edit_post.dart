import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfessionalPostEdit extends StatefulWidget {
  final comment;
  final image;
  final docid;
  const ProfessionalPostEdit({super.key, required this.comment, required this.image, required this.docid});

  @override
  State<ProfessionalPostEdit> createState() => ProfessionalPostEditState();
}

class ProfessionalPostEditState extends State<ProfessionalPostEdit> {
 
  @override
  Widget build(BuildContext context) {
     TextEditingController commentController = TextEditingController(text: widget.comment );
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () async{
                await FirebaseFirestore.instance
                .collection('professional_posts')
                .doc(widget.docid)
                .update({
             
              'comment': commentController.text.trim(),
            
              // 'verified': false,
            });

            Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 16, 6),
              child: CircleAvatar(
              radius: 24,
                child: Icon(Icons.check),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
                    child: TextField(
                      controller: commentController,
                    ),
                  ),
                       
              Container(
                
                child: widget.image != null
                                  ? Image.network(
                                      widget.image,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(),
              ),
                 ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}