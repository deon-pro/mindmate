import 'package:flutter/material.dart';
import 'package:mindmates/flutter_flow/chat/index.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/flutter_flow/flutter_flow_widgets.dart';
import 'package:mindmates/pages/messaging/single_chat_widget.dart';
import 'package:mindmates/pages/professionals/view_post.dart';
import 'package:mindmates/pages/videocall/videocall.dart';
//import 'package:mindmates/pages/payments/professionalpayment.dart';
import 'package:mindmates/pages/payments/paypal.dart';
import 'package:mindmates/professionals.dart';
import 'package:mindmates/pages/sos/review.dart';

class ViewProfesional extends StatefulWidget {
  final ProfessionalData data;
  const ViewProfesional({Key? key, required this.data}) : super(key: key);

  @override
  State<ViewProfesional> createState() => _ViewProfesionalState();
}

class _ViewProfesionalState extends State<ViewProfesional> {
  @override
  Widget build(BuildContext context) {
    String profilePic = widget.data.profile;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.data.docid);
    return Scaffold(
      appBar: AppBar(),
      // backgroundColor: Colors.black,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 75, 0, 0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue, 
              onPressed: () {
               
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoCallPage(),
                  ),
                );
              },
              child:
                  Icon(Icons.video_call), 
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 75, 0, 0),
            child: FloatingActionButton(
              backgroundColor: widget.data.rate < 10
                  ? Colors.green
                  : widget.data.rate < 50
                      ? Color(0xFF12CCEE)
                      : widget.data.rate < 100
                          ? const Color.fromARGB(255, 217, 1, 255)
                          : widget.data.rate >= 100
                              ? Colors.yellow
                              : Colors.greenAccent,
              onPressed: () {
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(title: '',),
                  ),
                );
              },
              child: Text(
                '\$${widget.data.rate.toString()}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: SingleChildScrollView(
        child: Container(
          // Rest of your code remains unchanged
          // ...

          // constraints: BoxConstraints(
          //   maxHeight: (MediaQuery.of(context).size.height),
          // ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CircleAvatar(
                  radius: 60,
                  foregroundImage:
                      // ignore: unnecessary_null_comparison
                      profilePic != null ? NetworkImage(profilePic) : null,
                  child: const Icon(Icons.person),
                ),
              ),
              Container(
                height: 64,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 90),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        widget.data.name,
                        style: TextStyle(
                          // fontSize: 11,
                          // color:
                          //     Theme.of(context).shadowColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    Container(
                      child: Text(
                        widget.data.service,
                        style: TextStyle(
                          fontSize: 11,
                          // color:
                          //     Theme.of(context).shadowColor,
                          // fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
              
              
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width * .7,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    backgroundColor: Colors.grey[500],
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReviewScreen(
                          profid: widget.data.docid,
                          name: widget.data.name,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'REVIEWS',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.star, color: Colors.green),
                    ],
                  ),
                ),
              ),


            Container(
  height: 40,
  width: MediaQuery.of(context).size.width * .7,
  margin: EdgeInsets.symmetric(vertical: 10), // Adjust margin as needed
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey, // Grey background color
    ),
    onPressed: () {
      // Add logic to show about me information
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('About Me'),
            content: SingleChildScrollView(
              child: Text(
                widget.data.about,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context)
                                  .primaryText
                  ), // White text color
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    },
    child: Text(
      'About Me',
      style: TextStyle(color: Colors.white), // White text color
    ),
  ),
),

              
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, .0, 24.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreamBuilder<UsersRecord>(
                        stream: UsersRecord.getDocument(userRef),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
                            return Scaffold(
                              backgroundColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              body: Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CircularProgressIndicator(
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          final viewProfilePageOtherUsersRecord =
                              snapshot.data!;
                          return FFButtonWidget(
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SingleChatWidget(
                                        receiverId:
                                            viewProfilePageOtherUsersRecord.uid,
                                        userImage:
                                            viewProfilePageOtherUsersRecord
                                                .photoUrl,
                                        username:
                                            viewProfilePageOtherUsersRecord
                                                .userName,
                                        professional: true, token: viewProfilePageOtherUsersRecord.token,
                                      )));
                            },
                            text: 'Message',
                            options: FFButtonOptions(
                              width: 260.0,
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: Colors.white,
                                  ),
                              elevation: 2.0,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          );
                        }),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: FlutterFlowTheme.of(context).time,
                // child: Text('Professional Posts'),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 8, 0, 8),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Professional Posts',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).time,
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(4))),
                      width: MediaQuery.of(context).size.width * .46,

                      // child: Text('Professional Posts'),
                    ),
                    Container(
                      height: 2,
                      width: MediaQuery.of(context).size.width * .54,
                      color: FlutterFlowTheme.of(context).time,
                      // child: Text('Professional Posts'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('professional_posts')
                        .where('userId', isEqualTo: widget.data.docid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              alignment: Alignment.topCenter,
                              child: const Text('..')),
                        );
                      }
                      if (snapshot.error != null) {
                        return Center(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: const Text('Error loading posts...')),
                        );
                      }
                      final postDocs = snapshot.data!.docs;

                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: postDocs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final posts =
                              postDocs[index].data() as Map<String, dynamic>;

                          final image = posts['imageUrl'] as String?;
                          final comment = posts['comment'] as String;
                          final time = posts['timestamp'] as Timestamp;

                          final appStartTime =
                              time.toDate().millisecondsSinceEpoch;
                          final currentTime =
                              DateTime.now().millisecondsSinceEpoch;
                          final duration = Duration(
                              milliseconds: currentTime - appStartTime);

                          final hours = duration.inHours;
                          final minutes = duration.inMinutes.remainder(60);

                          final appstart = time.toDate();
                          final currenttime = DateTime.now();

                          final bool isYesterday =
                              appstart.year == currenttime.year &&
                                  appstart.month == currenttime.month &&
                                  appstart.day == currenttime.day - 1;

                          final bool isToday =
                              appstart.year == currenttime.year &&
                                  appstart.month == currenttime.month &&
                                  appstart.day == currenttime.day;

                          Timestamp timestamp = time;
                          DateTime dateTime = timestamp.toDate();
                          DateFormat formatt = DateFormat('dd');
                          String date = formatt.format(dateTime);
                          DateFormat formatte = DateFormat('MMMM yyyy');
                          String month = formatte.format(dateTime);
                          // DateFormat format = DateFormat('');

                          String postTime =
                              DateFormat('h:mm a').format(dateTime);

                          String formattedTime = '';

                          if (minutes < 1) {
                            formattedTime += 'Just now';
                          } else if (hours < 1) {
                            formattedTime +=
                                '$minutes minute${minutes > 1 ? 's' : ''} ago';
                          } else if (isToday) {
                            formattedTime += 'Today, at $postTime';
                          } else if (isYesterday) {
                            formattedTime += 'Yesterday, at $postTime';
                          } else {
                            formattedTime += '$month $date, at $postTime';
                          }
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProfessionalPostView(
                                        comment: comment,
                                        image: image,
                                        time: formattedTime,
                                      )));
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              child: image != null
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(),
                            ),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
