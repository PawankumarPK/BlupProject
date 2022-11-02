import 'dart:typed_data';
import 'package:blup_task/res/ConstantString.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';


Future<String> saveImage(Uint8List byte,BuildContext context) async {
    await [Permission.storage].request();
    final time = DateTime.now().toIso8601String().replaceAll(".", "_").replaceAll(":", "_");
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(
        byte,
        quality: 80,
        name: name);
    print(result);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ConstantString.successfullySaved),
    ));
    return result['filePath'];
}
