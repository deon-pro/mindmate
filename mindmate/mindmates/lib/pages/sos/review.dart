import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:mindmates/auth/firebase_auth/auth_util.dart';

class ReviewScreen extends StatefulWidget {
  final profid;
  final name;

  const ReviewScreen({super.key, required this.profid, required this.name});
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final CollectionReference reviews =
      FirebaseFirestore.instance.collection('reviews');
  double _rating = 0;
  TextEditingController _commentController = TextEditingController();
  bool _canSubmit = false;
  int _numberOfReviewsToShow = 4;
  double _averageRating = 0;
  bool _showFeedback = false;
  String _dropdownValue = '4 more'; // Default dropdown value

  @override
  void initState() {
    super.initState();
    _calculateAverageRating();
    _checkUserReviewStatus();
  }

  Future<void> _submitReview() async {
    // Check if the user has already submitted a review
    var existingReview = await reviews
        .where('userid', isEqualTo: currentUserUid)
        .where('profid', isEqualTo: widget.profid)
        .get();

    if (existingReview.docs.isNotEmpty) {
      // User has already submitted a review
      return;
    }

    await reviews.add({
      'userid': currentUserUid,
      'profid': widget.profid,
      'rating': _rating,
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _calculateAverageRating();
    setState(() {
      _rating = 0;
      _commentController.clear();
      _canSubmit = false;
      _showFeedback = true;
    });

    Timer(Duration(seconds: 5), () {
      setState(() {
        _showFeedback = false;
      });
    });
  }

  Future<void> _deleteReview(String reviewId) async {
    await reviews.doc(reviewId).delete();
    _calculateAverageRating();
    _checkUserReviewStatus();
  }

  Future<void> _calculateAverageRating() async {
    var querySnapshot =
        await reviews.where('profid', isEqualTo: widget.profid).get();
    if (querySnapshot.docs.isNotEmpty) {
      var totalRating = 0.0;
      querySnapshot.docs.forEach((doc) {
        totalRating += doc['rating'];
      });
      setState(() {
        _averageRating = totalRating / querySnapshot.docs.length;
      });
    }
  }

  Future<void> _fetchAllReviews() async {
    setState(() {
      _numberOfReviewsToShow =
          10000; // Fetch a large number to display all reviews
    });
  }

  Future<void> _checkUserReviewStatus() async {
    var userReview = await reviews
        .where('userid', isEqualTo: currentUserUid)
        .where('profid', isEqualTo: widget.profid)
        .get();

    setState(() {
      _canSubmit = userReview.docs.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} Reviews', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (_canSubmit || _rating > 0) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Leave a Star:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      SizedBox(width: 10),
                      RatingBar(
                        onRatingChanged: (rating) {
                          setState(() {
                            _rating = rating;
                            _canSubmit = _commentController.text.isNotEmpty;
                          });
                        },
                        rating: _rating,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: 'Write your review'),
                  onChanged: (value) {
                    setState(() {
                      _canSubmit = _rating > 0 && value.isNotEmpty;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _canSubmit
                      ? () async {
                          await _submitReview();
                        }
                      : null,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
              ],
              Text(
                'Rating and Reviews',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 10),
              Text(
                'RATING: ${_averageRating.toStringAsFixed(1).toUpperCase()}/5\n',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.yellow,
                    fontWeight:
                        FontWeight.bold), // Set rating to yellow color and bold
              ),
              Text(
                'Rating and reviews are verified and are from people who have interacted with the professional and his services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.blue), // Set text to blue color
              ),
              SizedBox(height: 20),
              _showFeedback
                  ? Text(
                      'Thank you for giving feedback! Your review will help other users.',
                      style: TextStyle(color: Colors.green),
                    )
                  : SizedBox(height: 0),
              SizedBox(height: 20),
              if (_canSubmit) ...[
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserUid) // Assuming currentUserUid is the UID of the current user
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.error != null) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>;

                    return Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(userData['photo_url']),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData['userName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FutureBuilder<QuerySnapshot>(
                      future: reviews
                          .where('profid', isEqualTo: widget.profid)
                          .orderBy('timestamp', descending: true)
                          .limit(_numberOfReviewsToShow)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No reviews yet.'));
                        } else {
                          return Column(
                            children: snapshot.data!.docs.map((review) {
                              bool isCurrentUserReview =
                                  review['userid'] == currentUserUid;

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('uid', isEqualTo: review['userid'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text('..'),
                                    );
                                  }
                                  if (snapshot.error != null) {
                                    return const Center(
                                      child: Text('Error.'),
                                    );
                                  }

                                  final userdata =
                                      snapshot.data!.docs.first;
                                  final userInfo =
                                      userdata.data() as Map<String, dynamic>;

                                  DateTime timestamp =
                                      (review['timestamp'] as Timestamp)
                                          .toDate();
                                  String formattedDate =
                                      "${timestamp.day}/${timestamp.month}/${timestamp.year % 100}";

                                  return Column(
                                    children: [
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                NetworkImage(userInfo['photo_url']),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userInfo['userName'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  'Rating: ${review['rating']} : $formattedDate',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  'Review: ${review['comment']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Display delete icon for the user's own reviews
                                          if (isCurrentUserReview) ...[
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Delete Review'),
                                                      content: Text('Are you sure you want to delete this review?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            _deleteReview(review.id);
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text('Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      value: _dropdownValue,
                      items: <String>['4 more', 'All'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _dropdownValue = value!;
                          if (value == '4 more') {
                            _fetchAllReviews();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  RatingBar({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.star),
          color: rating >= 1 ? Colors.red : Colors.grey,
          onPressed: () {
            onRatingChanged(1);
          },
        ),
        IconButton(
          icon: Icon(Icons.star),
          color: rating >= 2 ? Colors.orange : Colors.grey,
          onPressed: () {
            onRatingChanged(2);
          },
        ),
        IconButton(
          icon: Icon(Icons.star),
          color: rating >= 3 ? Colors.yellow : Colors.grey,
          onPressed: () {
            onRatingChanged(3);
          },
        ),
        IconButton(
          icon: Icon(Icons.star),
          color: rating >= 4 ? Colors.lightGreen : Colors.grey,
          onPressed: () {
            onRatingChanged(4);
          },
        ),
        IconButton(
          icon: Icon(Icons.star),
          color: rating >= 5 ? Colors.green : Colors.grey,
          onPressed: () {
            onRatingChanged(5);
          },
        ),
      ],
    );
  }
}
