import 'package:flutter/material.dart';

class MoodPage extends StatefulWidget {
  @override
  _MoodPageState createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  List<String> moods = ['😄', '😊', '😐', '😞', '😢']; // Emoji representations of moods
  String selectedMood = ''; // Currently selected mood

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moods
                  .map((mood) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = mood;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedMood == mood
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                          child: Text(
                            mood,
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Feedback:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              getFeedbackMessage(selectedMood),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (selectedMood.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PositiveFeedbackPage(selectedMood),
                    ),
                  );
                },
                child: Text('Take Positive Action'),
              ),
          ],
        ),
      ),
    );
  }

  String getFeedbackMessage(String mood) {
    switch (mood) {
      case '😄':
        return 'You seem to be in a great mood! Enjoy your day!';
      case '😊':
        return 'You look happy today! Keep spreading positivity!';
      case '😐':
        return 'Feeling neutral? Take some time for yourself and relax.';
      case '😞':
        return 'Feeling down? Remember, it\'s okay not to be okay. Reach out to someone you trust.';
      case '😢':
        return 'It\'s okay to feel sad sometimes. Take care of yourself and do something that brings you joy.';
      default:
        return 'Select a mood to see feedback.';
    }
  }
}

class PositiveFeedbackPage extends StatelessWidget {
  final String mood;

  PositiveFeedbackPage(this.mood);

  String getPositiveMessage(String mood) {
    switch (mood) {
      case '😄':
        return 'You are radiating positivity today! Keep up the good vibes!';
      case '😊':
        return 'Your smile brightens up the day! Spread happiness around you!';
      case '😐':
        return 'Taking time to relax is essential. Enjoy the peaceful moments.';
      case '😞':
        return 'Remember, tough times don’t last. You’ll come out stronger!';
      case '😢':
        return 'It’s okay to feel sad, but remember there’s always a silver lining.';
      default:
        return 'No positive feedback available for this mood.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Positive Feedback'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Positive Feedback for $mood',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              getPositiveMessage(mood),
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}


