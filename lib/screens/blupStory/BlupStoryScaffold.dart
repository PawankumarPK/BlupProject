import 'package:blup_task/screens/blupStory/screen/BlupStoryScreen.dart';
import 'package:flutter/material.dart';

import '../../utils/SizeConfig.dart';

class BlupStoryScaffold extends StatelessWidget {
  const BlupStoryScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const Scaffold(
      body: BlupStoryScreen(),
    );
  }
}
