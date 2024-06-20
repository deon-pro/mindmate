import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/pages/notifications/notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommentPage(),
    );
  }
}

class CommentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final commentText =
        "Tell @messi to show some love guys to https://opposite.jy.yi/...";

    return Scaffold(
      appBar: AppBar(
        title: Text('Comment Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CommentWidget(commentText: commentText),
        ),
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final String commentText;

  CommentWidget({required this.commentText});

  @override
  Widget build(BuildContext context) {
    final formattedText = formatCommentText(commentText, context);

    return RichText(
      text: formattedText,
    );
  }

  TextSpan formatCommentText(String originalText, context) {
    final usernamePattern = r"@\w+";
    final matches = RegExp(usernamePattern).allMatches(originalText);

    String formattedText = originalText;
    final textSpans = <TextSpan>[];

    for (Match match in matches) {
      final username = match.group(0)!;

      // Create a gesture recognizer to handle username clicks
      final recognizer = TapGestureRecognizer()
        ..onTap = () {
          _handleMentionClick(username, context);
        };

      final styledMention = TextSpan(
        text: username,
        style: TextStyle(
          color: Colors.blue, // Username text color
          fontWeight: FontWeight.bold, // Username bold
          decoration: TextDecoration.underline, // Underline username
          // Add any other styling as needed
        ),
        recognizer: recognizer,
      );

      // Replace username with styled mention
      formattedText = formattedText.replaceAll(username, '');

      // Add the styled mention to the list of text spans
      textSpans.add(styledMention);
    }

    // Add the remaining text as a plain text span
    textSpans.add(TextSpan(
      text: formattedText,
      style: TextStyle(
        color: Colors.black, // Default text color
      ),
    ));

    return TextSpan(
      children: textSpans,
    );
  }

  void _handleMentionClick(String username, BuildContext context) {
    // Implement logic to navigate to the user's profile
    // Example:
     Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
  }
}
