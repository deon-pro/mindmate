import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PublicFollowers extends StatefulWidget {
  final userid;
  const PublicFollowers({Key? key, required this.userid});

  @override
  State<PublicFollowers> createState() => _PublicFollowersState();
}

class _PublicFollowersState extends State<PublicFollowers> {
  final userAc = FirebaseAuth.instance.currentUser;

  List<String> followingUserIds =
      []; // Track the user IDs being followed by the current user
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchFollowingUserIds(); // Fetch the list of user IDs being followed
  }

  void fetchFollowingUserIds() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userAc?.uid)
        .get();

    final followingList = userSnapshot.get('minding') as List<dynamic>?;
    if (followingList != null) {
      setState(() {
        followingUserIds = List<String>.from(followingList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myuserid = userAc?.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).disabledColor,
        title: const Text(
          'Minders',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              // Your search bar code...
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
                    .where('uid', isEqualTo: widget.userid)
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
                      ? List<String>.from(userData.first['minders'])
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
                          child: Text('No minders to show.'),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                            backgroundColor: Colors.grey,
                          ),
                        );
                      }
                      if (snapshot.error != null) {
                        return const Center(
                          child: Text('Error loading minders.'),
                        );
                      }

                      final List<Follower> allFollowers = snapshot.data!
                          .expand((querySnapshot) {
                            return querySnapshot.docs.map((doc) {
                              return Follower(
                                username: doc['userName'],
                                profile: doc['photo_url'],
                                userid: doc['uid'],
                              );
                            });
                          })
                          .cast<Follower>()
                          .toList();

                      // Filter followers based on search text
                      final List<Follower> followers =
                          allFollowers.where((follower) {
                        final username = follower.username.toLowerCase();
                        final searchQuery = searchText.toLowerCase();
                        return username.contains(searchQuery);
                      }).toList();

                      return Expanded(
                        child: ListView.builder(
                          itemCount: followers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final isFollowingBack = followingUserIds
                                .contains(followers[index].userid);

                            return Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 115, 113, 113),
                                    blurRadius: 3.0,
                                    offset: Offset(0, 1.2),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 10, 0),
                                        child: CircleAvatar(
                                          radius: 22,
                                          foregroundImage:
                                              // ignore: unnecessary_null_comparison
                                              followers[index].profile != null
                                                  ? NetworkImage(
                                                      followers[index].profile)
                                                  : null,
                                          child: const Icon(Icons.person),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isFollowingBack
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .6
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .42,
                                        child: Text(
                                          followers[index].username,
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).shadowColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      width: isFollowingBack
                                          ? 4
                                          : MediaQuery.of(context).size.width *
                                              .28,
                                      child: followers[index].userid == userAc!.uid? null:
                                      isFollowingBack
                                          ? null
                                          : ElevatedButton(
                                              onPressed: () {
                                                void followMy() async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(userAc?.uid)
                                                      .update({
                                                    'minding':
                                                        FieldValue.arrayUnion([
                                                      followers[index].userid
                                                    ]),
                                                  }).then((_) {
                                                    print(
                                                        'Minded user successfully');
                                                  }).catchError((error) {
                                                    print(
                                                        'Error minding user: $error');
                                                  });
                                                }

                                                void follow() async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(followers[index]
                                                          .userid)
                                                      .update({
                                                    'minders':
                                                        FieldValue.arrayUnion(
                                                            [userAc?.uid]),
                                                  }).then((_) {
                                                    print(
                                                        'Minded user successfully');
                                                  }).catchError((error) {
                                                    print(
                                                        'Error minding user: $error');
                                                  });
                                                  followMy();
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PublicFollowers(userid: widget.userid,)),
                                                  );
                                                }

                                                follow();
                                              },
                                              child: const Text(
                                                'Mind Back',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            )),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Follower {
  final String username;
  final String profile;
  final String userid;

  Follower({
    required this.username,
    required this.profile,
    required this.userid,
  });
}
