import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/flutter_flow/chat/index.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/all_chats_page/group_chats_page_widget.dart';
import 'package:mindmates/pages/all_chats_page/single_chat.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: FlutterFlowTheme.of(context).headlineMedium,
        ),
        actions: [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  // text: 'Chats',
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatsNew')
                          .where('receiverId', isEqualTo: currentUserUid)
                          .where('seen', isEqualTo: false)
                          .where('lastmessage', isNotEqualTo: 'delete_Alt_124')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Handle loading state
                          return const Center();
                        }
                        if (snapshot.error != null) {
                          return Center(
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: const Text('Chats')),
                          );
                        }

                        final xdata = snapshot.data!.docs;
                        // final info =
                        // notifications[index].data() as Map<String, dynamic>;

                        String number = xdata.length.toString();
                        int numberInt = xdata.length;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Chats',
                              style: FlutterFlowTheme.of(context).titleSmall,
                            ),
                            numberInt == 0
                                ? Container()
                                : Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(04, 0, 0, 0),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      radius: 12,
                                      child: Text(number),
                                    ),
                                  )
                          ],
                        );
                      }),
                ),
                Tab(
                  // text: 'Chats',
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatsGroup')
                          .where('sender', isNotEqualTo: currentUserUid)
                          // .where('seenby', arrayContains!: currentUserUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Handle loading state
                          return const Center();
                        }
                        if (snapshot.error != null) {
                          return Center(
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: const Text('Chats')),
                          );
                        }

                        final xdata = snapshot.data!.docs;

                        int count = 0;
                        for (var document in xdata) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;

                          // Check if 'seenby' field does not contain the currentUserUid
                          if (!data['seenby'].contains(currentUserUid)) {
                            count++;
                          }
                        }

                        String number = count.toString();
                        int numberInt = count;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Communities',
                              style: FlutterFlowTheme.of(context).titleSmall,
                            ),
                            numberInt == 0
                                ? Container()
                                : Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(04, 0, 0, 0),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      radius: 12,
                                      child: Text(number),
                                    ),
                                  )
                          ],
                        );
                      }),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ChatsPageWidget(),
                  AllChatsPageWidget(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
