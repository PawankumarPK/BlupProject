import 'package:blup_task/screens/blupStory/BlupStoryScaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

