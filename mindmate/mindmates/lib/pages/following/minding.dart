import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/auth/firebase_auth/auth_util.dart';
import 'package:rxdart/rxdart.dart';

class Followings extends StatefulWidget {
  const Followings({super.key});

  @override
  State<Followings> createState() => _FollowingsState();
}

class _FollowingsState extends State<Followings> {
  final userAc = FirebaseAuth.instance.currentUser;

  List<String> followingUserIds =
      []; // Track the user IDs being followed by the current user
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchFollowingUserIds(); // Fetch the list of user IDs being followed
  }

  void unnotify(String myId, String followId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define the query to select the documents to delete
    QuerySnapshot querySnapshot = await firestore
        .collection("notifications")
        .where("myId", isEqualTo: myId)
        .where("followerId", isEqualTo: followId)
        .get();

    // Use a forEach loop to delete each matching document
    querySnapshot.docs.forEach((doc) async {
      await doc.reference.delete();
    });
  }


  void fetchFollowingUserIds() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userAc?.uid)
        .get();

    final followingList = userSnapshot.get('minders') as List<dynamic>?;
    if (followingList != null) {
      setState(() {
        followingUserIds = List<String>.from(followingList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userid = userAc?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).disabledColor,
        title: Text(
          'Minding',
          style: TextStyle(
            color: Theme.of(context).shadowColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  width: MediaQuery.of(context).size.width * .92,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SizedBox(
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 26,
                          color: Theme.of(context).shadowColor,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .72,
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: TextFormField(
                            // controller: _email,

                            onChanged: (value) {
                              setState(() {
                                searchText = value
                                    .toLowerCase(); // Update the searchText on text changes
                              });
                            },

                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: 'search...',
                              hintStyle: const TextStyle(
                                  //  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 63, 62, 62)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', isEqualTo: userid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No minders to show.'),
                      );
                    }
                    if (snapshot.error != null) {
                      return const Center(
                        child: Text('Error loading minders.'),
                      );
                    }


                    final userData = snapshot.data!.docs;
                    final people = userData.isNotEmpty
                        ? List<String>.from(userData.first['minding'])
                        : [];

                    final List<Stream<QuerySnapshot>> queryStreams = [];
                    const int batchSize = 10;

                    for (int i = 0; i < people.length; i += batchSize) {
                      final batchIds = people.skip(i).take(batchSize).toList();
                      final queryStream = FirebaseFirestore.instance
                          .collection('users')
                          .where('uid', whereIn: batchIds)
                          .snapshots();

                      queryStreams.add(queryStream);
                      print(batchIds);
                    }

                    return StreamBuilder<List<QuerySnapshot>>(
                        stream: CombineLatestStream.list(queryStreams),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No mindings to show.'),
                            );
                          }
                         
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.greenAccent, //<-- SEE HERE
                                backgroundColor: Colors.grey,
                              ),
                            );
                          }
                          if (snapshot.error != null) {
                            return const Center(
                              child: Text('Error loading minders.'),
                            );
                          }

                          final List<Following> allFollowings = snapshot.data!
                              .expand((querySnapshot) {
                                return querySnapshot.docs.map((doc) {
                                  return Following(
                                    username: doc['userName'],
                                    profile: doc['photo_url'],
                                    userid: doc['uid'],
                                  );
                                });
                              })
                              .cast<Following>()
                              .toList();

                          final List<Following> followings =
                              allFollowings.where((follower) {
                            final username = follower.username.toLowerCase();
                            final searchQuery = searchText.toLowerCase();
                            return username.contains(searchQuery);
                          }).toList();

                          // print('follos: ${followers.length}');
                          return Expanded(
                            child: ListView.builder(
                              itemCount: followings.length,
                              itemBuilder: (BuildContext context, int index) {
                                // ignore: unused_local_variable
                                final isFollowingBack = followingUserIds
                                    .contains(followings[index].userid);
                                return Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    // borderRadius: BorderRadius.all(Radius.circular(8)),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color.fromARGB(
                                              255, 115, 113, 113), //New
                                          blurRadius: 3.0,
                                          offset: Offset(0, 1.2))
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      //junoir row .pic and username

                                      Row(
                                        children: [
                                          Container(
                                            // height: 60,
                                            // alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 10, 0),
                                            child:  CircleAvatar(
                                              radius: 22,
                                                foregroundImage:
                                                  // ignore: unnecessary_null_comparison
                                                  followings[index].profile != null
                                                      ? NetworkImage(
                                                          followings[index].profile)
                                                      : null,
                                              child: const Icon(Icons.person),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .44,
                                                
                                            child: Text(
                                              followings[index].username,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .22,
                                             
                                          child: ElevatedButton(
                                                  onPressed: () {
                                                    void unfollowMy() async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(userAc?.uid)
                                                          .update({
                                                        'minding': FieldValue
                                                            .arrayRemove([
                                                          followings[index]
                                                              .userid
                                                        ]),
                                                      }).then((_) {
                                                        print(
                                                            'Unminded user successfully');
                                                      }).catchError((error) {
                                                        print(
                                                            'Error unminding user: $error');
                                                      });
                                                    }

                                                    void unfollow() async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(followings[index]
                                                              .userid)
                                                          .update({
                                                        'minders': FieldValue
                                                            .arrayRemove(
                                                                [userAc?.uid]),
                                                      }).then((_) {
                                                        unnotify(
                                                        currentUserUid,
                                                        followings[index]
                                                            .userid);
                                                      }).catchError((error) {
                                                        print(
                                                            'Error unminding user: $error');
                                                      });
                                                      unfollowMy();
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Followings()),
                                                      );
                                                    }

                                                    unfollow();
                                                  },
                                                  child: const Text(
                                                    'Unmind',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                )
                                              ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class Following {
  String username;
  String profile;
  String userid;

  Following({
    required this.username,
    required this.profile,
    required this.userid,
  });
}
