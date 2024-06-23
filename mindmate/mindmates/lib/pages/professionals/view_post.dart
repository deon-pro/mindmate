// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';

class ProfessionalPostView extends StatelessWidget {
  final comment;
  final image;
  final time;
  const ProfessionalPostView(
      {super.key,
      required this.comment,
      required this.image,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child: image != null
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                    )
                  : Container(),
            ),
            Positioned(
                bottom: 0,
                child: IntrinsicHeight(
                  child: Container(
                    color:
                        FlutterFlowTheme.of(context).accent1.withOpacity(0.2),
                    padding: EdgeInsets.fromLTRB(30, 20, 0, 30),
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.,
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment,
                             style: TextStyle(
                              color: FlutterFlowTheme.of(context).accent2,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: FlutterFlowTheme.of(context).accent2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
