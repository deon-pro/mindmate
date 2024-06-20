
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/pages/menu/confirm_user_reporting.dart';

class UserReporting extends StatelessWidget {
  final reporteeId;
  final postId;
  final username;
  const UserReporting({super.key, this.reporteeId, this.postId, this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userReports')
            .orderBy('position', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center();
          }
          if (snapshot.error != null) {
            return const Center(
              child: Text('Error loading data...'),
            );
          }
          final reportPost = snapshot.data!.docs;

          return Column(
            children: [
              Container(
                // height: 70,
                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                child: Text('Select the reason to report this user:',
                    style: TextStyle(
                      // fontSize: 12,
                      fontStyle: FontStyle.italic,
                    )),
              ),
              Container(
                height: 1,
                color: Color.fromARGB(31, 82, 82, 82),
              ),
              ListView.builder(
                  itemCount: reportPost.length,
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    // Get the data from the document at the current index
                    final data =
                        reportPost[index].data() as Map<String, dynamic>;

                    // Access the 'username' field from the data
                    final reason = data['reason'] as String;
                    final subReason = data['subreason'] as String;

                    return InkWell(
                      onTap: () {
                         Navigator.pop(
                                                                        context);
                                                                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SubmitUserReport(
                                reason: reason,
                                reporteeId: reporteeId,
                                username: username,
                              )));
                      },
                     
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .7,
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
                                      child: Text(reason,
                                          style: TextStyle(
                                              // fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    subReason != ''
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .7,
                                            child: Text(subReason,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  // fontWeight: FontWeight.bold
                                                )),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Theme.of(context).shadowColor,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Color.fromARGB(31, 82, 82, 82),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          );
        },
      ),
    );
  }
}
