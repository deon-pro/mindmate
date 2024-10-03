import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/components/notifications/model.dart';
import 'package:mindmates/flutter_flow/chat/index.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/flutter_flow/flutter_flow_widgets.dart';
import 'package:mindmates/pages/messaging/single_chat_widget.dart';
import 'package:mindmates/pages/professionals/view_post.dart';
import 'package:mindmates/pages/videocall/Video_call_home.dart';
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
  FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String server = "";
  Map<String, dynamic>? userInfo;

  // Initialize Firebase and Remote Config
  @override
  void initState() {
    super.initState();
    _initializeRemoteConfig();
    getFCMServer();
    getCurrentUserDetails();
  }

// Function to initialize Remote Config asynchronously
  Future<void> _initializeRemoteConfig() async {
    try {
      // Set default values for Remote Config parameters
      await _remoteConfig.setDefaults(<String, dynamic>{
        'adminEmails':
            'dean404e@gmail.com', // Default value if not set in Remote Config
      });

      // Fetch and activate the latest Remote Config values
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print("Error initializing Remote Config: $e");
    }
  }

// Fetch and parse the admin emails from Remote Config
  Future<List<String>> getAdminEmails() async {
    try {
      final String adminEmails = _remoteConfig.getString('EMAIL');
      if (adminEmails.isNotEmpty) {
        return adminEmails
            .split(',')
            .map((e) => e.trim())
            .toList(); // Convert comma-separated emails to a list
      }
    } catch (e) {
      print("Error fetching admin emails: $e");
    }
    return [];
  }

// Get admin's FCM token from Firestore
  Future<List<String>> getAdminTokens() async {
    List<String> adminEmails = await getAdminEmails();
    List<String> adminTokens = [];

    try {
      for (String email in adminEmails) {
        // Fetch the admin token from Firestore (assuming you store FCM tokens in a collection like 'users')
        var userSnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Assuming FCM token is stored in the 'token' field
          String? fcmToken = userSnapshot.docs.first['token'];
          if (fcmToken != null) {
            adminTokens.add(fcmToken);
          }
        }
      }
    } catch (e) {
      print("Error fetching admin tokens: $e");
    }

    return adminTokens; // Return a list of FCM tokens for the admin users
  }

  Future<void> getCurrentUserDetails() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userInfo = userSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('User does not exist in the database.');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void getFCMServer() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    // await remoteConfig.
    var data = remoteConfig.getString('FCM');
    if (data.isNotEmpty) {
      // String serverToken = jsonDecode(data)["FCM"];
      setState(() {
        server = data;
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    String profilePic = widget.data.profile;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.data.docid);
    return Scaffold(
      // appBar: AppBar(),
      // backgroundColor: Colors.black,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 55, 0, 0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoCallHomeScreen(),
                  ),
                );
              },
              child: Icon(Icons.video_call),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 55, 0, 0),
            child: PopupMenuButton<String>(
              // Use the FloatingActionButton directly as the icon of the PopupMenuButton
              child: FloatingActionButton(
                backgroundColor: widget.data.rate < 10
                    ? Colors.green
                    : widget.data.rate < 50
                        ? const Color(0xFF12CCEE)
                        : widget.data.rate < 100
                            ? const Color.fromARGB(255, 217, 1, 255)
                            : widget.data.rate >= 100
                                ? Colors.yellow
                                : Colors.greenAccent,
                onPressed: null, // No need to handle onPressed here
                child: Text(
                  '\$${widget.data.rate.toString()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Handle the selected item from the menu
              onSelected: (String result) async {
                if (result == 'Paypal') {
                  // Navigate to the Payment screen for Paypal
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(
                        title: '',
                      ),
                    ),
                  );
                } else if (result == 'Till') {
                  // Show the till payment dialog
                  void _submitTransactionId(
                      String transactionId, String transactionamt) async {
                    // Save the transaction details in Firestore for future verification
                    await _firestore.collection('till_payments').add({
                      'userId': FirebaseAuth.instance.currentUser!.uid,
                      'transactionId': transactionId,
                      'amount': transactionamt,
                      'profId': widget.data.docid,
                      'status':
                          'pending', // Admin can later verify the transaction
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    // Optionally, notify the user that the transaction is being verified
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Payment is being verified')),
                    );
                  }

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController transactionIdController =
                          TextEditingController();

                      TextEditingController transactionamtController =
                          TextEditingController();

                      return SingleChildScrollView(
                        child: AlertDialog(
                          title: const Text('Till Payment'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Enter your payment reference after making a payment using this till number.\n'
                                'Payment for ${widget.data.name} ',
                              ),
                              Text(
                                '*Ensure you are making the confirmation to the right user!!',
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Till: 9922067',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Name: Blue Code Infinity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: transactionIdController,
                                decoration: const InputDecoration(
                                  labelText: 'Transaction ID',
                                  hintText:
                                      'Enter the M-Pesa confirmation code',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: transactionamtController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  hintText: 'Enter the Amount for Security',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Handle the transaction ID submission
                                String transactionId =
                                    transactionIdController.text.trim();

                                String transactionamt =
                                    transactionamtController.text.trim();
                                if (transactionId.isNotEmpty &&
                                    transactionamt.isNotEmpty) {
                                  // _submitTransactionId(
                                  //     transactionId, transactionamt);
                                  List<String> tokens = await getAdminTokens();

                                  for (String token in tokens) {
                                    NotifModel().sendFCMMessagePayment(
                                        token,
                                        '${userInfo!['userName']} requested payment confirmation',
                                        server,
                                        '${userInfo!['userName']}'); // Send the message for each token
                                  }

                                  Navigator.of(context)
                                      .pop(); // Close the dialog after submission
                                }
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              // Define the menu items
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Paypal',
                  child: Text('Paypal'),
                ),
                const PopupMenuItem<String>(
                  value: 'Till',
                  child: Text('Till'),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 70, 0, 0),
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
              margin:
                  EdgeInsets.symmetric(vertical: 10), // Adjust margin as needed
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
                                    .primaryText), // White text color
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
                        final viewProfilePageOtherUsersRecord = snapshot.data!;
                        return FFButtonWidget(
                          onPressed: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SingleChatWidget(
                                      receiverId:
                                          viewProfilePageOtherUsersRecord.uid,
                                      userImage: viewProfilePageOtherUsersRecord
                                          .photoUrl,
                                      username: viewProfilePageOtherUsersRecord
                                          .userName,
                                      professional: true,
                                      token:
                                          viewProfilePageOtherUsersRecord.token,
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
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(4))),
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
                        final duration =
                            Duration(milliseconds: currentTime - appStartTime);

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

                        String postTime = DateFormat('h:mm a').format(dateTime);

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
    );
  }
}
