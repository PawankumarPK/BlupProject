import 'package:blup_task/res/ConstantColors.dart';
import 'package:blup_task/res/Dimens.dart';
import 'package:blup_task/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class TopIconContainer extends StatelessWidget {
  final icon;

  const TopIconContainer({Key? key,this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.defaultSize! * Dimens.size6,
      height: SizeConfig.defaultSize! * Dimens.size6,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ConstantColors.topIconBgColor),
      child:  Icon(icon, size: SizeConfig.defaultSize! * Dimens.size2,),
    );
  }
}
