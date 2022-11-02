import 'package:blup_task/screens/blupStory/BlupStoryScaffold.dart';
import 'package:blup_task/screens/blupStory/screen/BlupStoryScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blup Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BlupStoryScaffold(),
    );
  }
}

