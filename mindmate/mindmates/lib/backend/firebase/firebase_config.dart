import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAWiZbNiuXkapN7XDHGAr2sL16ZRbhDsI4",
            authDomain: "mindmates-d4849.firebaseapp.com",
            projectId: "mindmates-d4849",
            storageBucket: "mindmates-d4849.appspot.com",
            messagingSenderId: "983028356182",
            appId: "1:983028356182:web:b6465d0ac96ba45a1257f7",
            measurementId: "G-J58V8BEFY1"));
  } else {
    await Firebase.initializeApp();
  }
}
