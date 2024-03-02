
import 'package:flutter/material.dart';
import 'package:myjorurney/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: 'AIzaSyBbcROIWrD9tz66r2gGfVf7Mqv_bd0Crn0', appId: '1:1088224171052:android:2ce7abeafd41125c6b2d89', messagingSenderId: '1088224171052', projectId: 'myjourney-621e7')
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      primarySwatch: Colors.orange,
      ),
      home: const WidgetTree(),
    );
  }
}
