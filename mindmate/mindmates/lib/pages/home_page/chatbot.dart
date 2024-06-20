import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final messageInsert = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  String apiKey = '<API KEY>';
  String apiUrl = 'https://api.openai.com/v1/chat/completions';

  bool isDarkMode = true;
  bool isSending = false;
  stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    getApiKey();
    loadChatHistory();
  }

  void getApiKey() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    // await remoteConfig.
    var data = remoteConfig.getString('CHAT');
    if (data.isNotEmpty) {
      // String serverToken = jsonDecode(data)["FCM"];
      setState(() {
        apiKey = data;
      });
    } else {
      print(
        "Please configure Remote config in firebase",
      );
    }
  }

  Future<void> loadChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      print('User not logged in');
      return;
    }

    final userId = user.uid;
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('chatbot');

    List<Map<String, dynamic>> loadedUserMessages = [];
    List<Map<String, dynamic>> loadedAssistantMessages = [];

    try {
      // Query user messages by user ID
      QuerySnapshot userMessagesSnapshot = await messagesCollection
          .where('userId', isEqualTo: userId)
          .where('role', isEqualTo: 'user')
          .get();

      // Query assistant messages by user ID
      QuerySnapshot assistantMessagesSnapshot = await messagesCollection
          .where('userId', isEqualTo: userId)
          .where('role', isEqualTo: 'assistant')
          .get();

      // Extract user messages
      loadedUserMessages.addAll(userMessagesSnapshot.docs
          .map<Map<String, dynamic>>(
              (doc) => doc.data() as Map<String, dynamic>)
          .toList());

      // Extract assistant messages
      loadedAssistantMessages.addAll(assistantMessagesSnapshot.docs
          .map<Map<String, dynamic>>(
              (doc) => doc.data() as Map<String, dynamic>)
          .toList());

      // Sort messages by timestamp in ascending order (oldest to newest)
      loadedUserMessages.sort((a, b) {
        int timestampComparison = a['timestamp'].compareTo(b['timestamp']);
        return timestampComparison;
      });

      loadedAssistantMessages.sort((a, b) {
        int timestampComparison = a['timestamp'].compareTo(b['timestamp']);
        return timestampComparison;
      });

      // Merge user and assistant messages
      List<Map<String, dynamic>> mergedMessages = [];
      int userIndex = 0, assistantIndex = 0;

      while (userIndex < loadedUserMessages.length &&
          assistantIndex < loadedAssistantMessages.length) {
        mergedMessages.add(loadedUserMessages[userIndex]);
        userIndex++;

        if (assistantIndex < loadedAssistantMessages.length) {
          mergedMessages.add(loadedAssistantMessages[assistantIndex]);
          assistantIndex++;
        }
      }

      while (userIndex < loadedUserMessages.length) {
        mergedMessages.add(loadedUserMessages[userIndex]);
        userIndex++;
      }

      while (assistantIndex < loadedAssistantMessages.length) {
        mergedMessages.add(loadedAssistantMessages[assistantIndex]);
        assistantIndex++;
      }

      setState(() {
        messages = mergedMessages;
      });
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      isSending = true;
      messages.add({'role': 'user', 'content': message});
      messages
          .add({'role': 'assistant', 'content': 'Generating a response...'});
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo-0613',
          'temperature': 0.6,
          'messages': messages
              .map((msg) => {'role': msg['role'], 'content': msg['content']})
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final assistantReply = responseBody['choices'][0]['message']['content'];

        setState(() {
          isSending = false;
          messages
              .removeLast(); // Remove the 'Generating a response...' message
          messages.add({'role': 'assistant', 'content': assistantReply});
        });

        saveMessages(messages);
      } else {
        print('API request failed with status code: ${response.statusCode}');
        setState(() {
          isSending = false;
        });
      }
    } catch (e) {
      print('Error during API request: $e');
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      print('User not logged in');
      return;
    }

    final userId = user.uid;

    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('chatbot');

    WriteBatch batch = FirebaseFirestore.instance.batch();

    messages.forEach((message) {
      batch.set(
        messagesCollection.doc(),
        {
          'userId': userId,
          'role': message['role'],
          'content': message['content'],
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    });

    await batch.commit();
    print('Messages saved to Firestore.');
  }

  void deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
      },
      onError: (errorNotification) {
        print('Error: $errorNotification');
      },
    );

    if (available) {
      bool listening = await _speech.listen(
        onResult: (result) {
          setState(() {
            messageInsert.text = result.recognizedWords;
          });
        },
      );

      if (!listening) {
        print('Error starting speech recognition');
      }
    } else {
      print('Speech recognition not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text("MindMate AI Assistant"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Conversation"),
                    content: Text(
                        "Are you sure you want to delete the entire conversation? Please be aware that this action is irreversible. Once deleted, all associated data will be permanently removed, and it cannot be recovered."),
                    actions: [
                      TextButton(
                        child: Text("CANCEL"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("DELETE"),
                        onPressed: () {
                          deleteConversation();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) => chat(
                    messages[index]["content"].toString(),
                    messages[index]["role"] == 'user'
                        ? "Minder"
                        : "MindMate AI",
                    messages[index]["role"] == 'user'
                        ? Colors.blue
                        : Colors.orangeAccent,
                    index,
                  ),
                ),
              ),
              Divider(
                height: 6.0,
              ),
              Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: messageInsert,
                        decoration: InputDecoration.collapsed(
                          hintText: "Send your message",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.keyboard_voice,
                              size: 30.0,
                            ),
                            onPressed: () {
                              _startListening();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              size: 30.0,
                            ),
                            onPressed: () {
                              if (messageInsert.text.isEmpty) {
                                print("empty message");
                              } else {
                                _sendMessage(messageInsert.text);
                                messageInsert.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chat(String message, String avatarName, Color color, int index) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Message?"),
              content: Text(
                  "Are you sure you want to delete this message? Please be aware that this action is irreversible. Once deleted, all associated data will be permanently removed, and it cannot be recovered"),
              actions: [
                TextButton(
                  child: Text("CANCEL"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("DELETE"),
                  onPressed: () {
                    deleteMessage(index);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage(
                    avatarName == "Minder"
                        ? "assets/images/user.png"
                        : "assets/images/bot.png",
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: Text(
                    avatarName,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Bubble(
              radius: Radius.circular(15.0),
              color: color,
              elevation: 0.0,
              alignment: Alignment.topLeft,
              nip: BubbleNip.leftBottom,
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteConversation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in
      print('User not logged in');
      return;
    }

    final userId = user.uid;

    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('chatbot');

    try {
      // Retrieve the messages associated with the current user
      QuerySnapshot querySnapshot =
          await messagesCollection.where('userId', isEqualTo: userId).get();

      // Delete the messages from Firestore
      WriteBatch batch = FirebaseFirestore.instance.batch();
      querySnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      await batch.commit();

      // Clear messages from the local state
      setState(() {
        messages.clear();
      });

      print('Conversation deleted from Firestore.');
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }
}
