import 'package:blup_task/res/Dimens.dart';
import 'package:blup_task/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

final SignatureController controller = SignatureController(
  penStrokeWidth: 6,
  penColor: Colors.red,
  exportBackgroundColor: Colors.blue,
  exportPenColor: Colors.black,
);

Widget signature(BuildContext context){
  return MediaQuery(
      data: const MediaQueryData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        home: Signature(
          controller: controller,
          height: SizeConfig.defaultSize! * Dimens.size90,
          backgroundColor: Colors.redAccent.withOpacity(0.0)
      ),)
  );
}