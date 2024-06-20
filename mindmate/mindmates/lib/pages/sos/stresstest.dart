import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Assessment Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MentalHealthGame(),
    );
  }
}

class MentalHealthGame extends StatefulWidget {
  @override
  _MentalHealthGameState createState() => _MentalHealthGameState();
}

class _MentalHealthGameState extends State<MentalHealthGame> {
  int questionIndex = 0;
  int totalScore = 0;

  List<Question> questions = [
    Question('Do you often feel overwhelmed or unable to cope?', 1),
    Question('Do you have trouble sleeping at night?', 1),
    Question('Do you often feel sad or hopeless?', 1),
    Question('Do you avoid social interactions?', 1),
    Question('Do you have trouble concentrating?', 1),
    Question('Do you experience mood swings?', 1),
    Question('Do you often feel anxious or worried?', 1),
    Question('Do you lack interest in activities you used to enjoy?', 1),
    Question('Do you have thoughts of self-harm or suicide?', 1),
    Question('Do you have a strong support system of friends and family?', -1),
  ];

  void answerQuestion(int score) {
    totalScore += score;

    setState(() {
      questionIndex++;
    });

    if (questionIndex >= questions.length) {
      String resultText;
      if (totalScore <= 3) {
        resultText = 'Good Mental Health';
      } else if (totalScore <= 6) {
        resultText = 'Medium Mental Health';
      } else {
        resultText = 'Poor Mental Health';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Assessment Result'),
            content: Text('Your mental health state: $resultText'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    questionIndex = 0;
                    totalScore = 0;
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Assessment Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Begin the Mental Health Assessment Test to evaluate your mental well-being:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              questionIndex < questions.length
                  ? questions[questionIndex].text
                  : 'Assessment Complete',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (questionIndex < questions.length)
              ElevatedButton(
                onPressed: () {
                  answerQuestion(1);
                },
                child: Text('Yes'),
              ),
            if (questionIndex < questions.length)
              SizedBox(height: 10),
            if (questionIndex < questions.length)
              ElevatedButton(
                onPressed: () {
                  answerQuestion(0);
                },
                child: Text('No'),
              ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final int score;

  Question(this.text, this.score);
}
