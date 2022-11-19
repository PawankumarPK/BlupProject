import 'dart:io';
import 'package:blup_task/res/ConstantString.dart';
import 'package:blup_task/screens/blupStory/widget/CanvasDraw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import '../../../res/ConstantColors.dart';
import '../../../res/Dimens.dart';
import '../../../utils/CustomObject.dart';
import '../../../utils/EditableItem.dart';
import '../../../utils/SizeConfig.dart';

class CanvasDrawLine extends StatefulWidget {
  const CanvasDrawLine({Key? key}) : super(key: key);

  @override
  _CanvasDrawLineState createState() => _CanvasDrawLineState();
}

class _CanvasDrawLineState extends State<CanvasDrawLine> {
  late EditableItem activeItem;
  late Offset initPos;
  late Offset currentPos;
  late double currentScale;
  late double currentRotation;
  bool inAction = false;
  late File file;

  var isImageCapture = false;
  var isCanvasVisible = false;

  final keyTextHelloWorld = GlobalKey();
  final keyTextForImage = GlobalKey();
  late Offset position;
  late Size size;

  TextEditingController contentController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();

  var isCanvasLineVisible = false;
  var isCanvasLineVisibleForHelloWord = false;

  var isReachedFromBelow = false;
  var isReachedFromAbove = false;
  var isReachedFromRight = false;
  var isReachedFromLeft = false;

  var isReachedHintTwoFromBelow = false;
  var isReachedHintTwoFromAbove = false;
  var isReachedHintTwoFromRight = false;
  var isReachedHintTwoFromLeft = false;

  var isContainerVisible = false;
  var isContainerBottomVisible = false;

  var helloHeight = SizeConfig.defaultSize! * Dimens.size50;

  var mockData = [
    EditableItem()
      ..type = ItemType.Image
      ..value = "",
    EditableItem()
      ..type = ItemType.Text
      ..value = "",
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: buildStory(),
          ),
        ],
      ),
    );
  }


  //show and map all widgets like image , text , canvas
  Widget buildStory() {
    return Stack(
      children: [
        Container(color: Colors.white),
        ...mockData.map(buildItemWidget).toList(),
        isCanvasVisible == true ? signature(context) : Container(),
      ],
    );
  }

  //build all item widget to show into story screen
  Widget buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;

    Widget widget;

    ///--------------- Hello world section -------------
    switch (e.type) {
      case ItemType.Text:
        widget = GestureDetector(
            onScaleStart: (details) {
              if (activeItem == null) return;
              initPos = details.focalPoint;
              currentPos = activeItem.position;
              currentScale = activeItem.scale;
              currentRotation = activeItem.rotation;
              isCanvasLineVisibleForHelloWord = true;
            },

            onScaleEnd: (detail) {
              isCanvasLineVisibleForHelloWord = false;
              //isContainerVisible = true;
              setState(() {});
            },

            onScaleUpdate: (details) {
              if (activeItem == null) {
                return;
              }
              final delta = details.focalPoint - initPos;
              final left = (delta.dx / screen.width) + currentPos.dx;
              final top = (delta.dy / screen.height) + currentPos.dy;

              setState(() {
                activeItem.position = Offset(left, top);
                activeItem.rotation = details.rotation + currentRotation;
                activeItem.scale = max(min(details.scale * currentScale, 3), 0.2);
                //isContainerVisible = false;
                isContainerBottomVisible = false;
                calculateSizeAndPositionForHelloText();
              });
            },
            child: Column(
              children: [

                ///---------------- Hello world Top line ------------
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isCanvasLineVisibleForHelloWord == false ? false : true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: isReachedHintTwoFromBelow == true?true:false,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 1.0,
                              height: SizeConfig.defaultSize! * Dimens.size26,
                              child: DecoratedBox(
                                decoration:
                                BoxDecoration(color: ConstantColors.greenColor),
                              ),
                            ),
                            Text(
                              (CustomObject.y - CustomObject.posY).toStringAsFixed(0),
                              style: TextStyle(
                                  color: ConstantColors.greenColor,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: isReachedHintTwoFromBelow == true?false:true,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 40,left: 40),
                              child: SizedBox(
                                width: 1.0,
                                height: SizeConfig.defaultSize! * Dimens.size26,
                                child: DecoratedBox(
                                  decoration:
                                      BoxDecoration(color: ConstantColors.pinkColor),
                                ),
                              ),
                            ),
                            Text(
                              CustomObject.y.toStringAsFixed(1),
                              style: TextStyle(
                                  color: ConstantColors.primaryColor,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: isReachedHintTwoFromBelow == true?true:false,

                        child: Column(
                          children: [
                            SizedBox(
                              width: 1.0,
                              height: SizeConfig.defaultSize! * Dimens.size26,
                              child: DecoratedBox(
                                decoration:
                                BoxDecoration(color: ConstantColors.greenColor),
                              ),
                            ),
                            Text(
                              (CustomObject.y - CustomObject.posY).toStringAsFixed(0),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                  color: ConstantColors.greenColor,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [

                    ///------------------ Left line --------------------
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisibleForHelloWord == false
                          ? false
                          : true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: isReachedHintTwoFromLeft == true ? true : false,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: SizeConfig.defaultSize! * Dimens.size26,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.greenColor),
                                    ),
                                  ),
                                  Text(
                                    (CustomObject.x - CustomObject.posX).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ConstantColors.greenColor,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: isReachedHintTwoFromLeft == true ? false : true,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: SizeConfig.defaultSize! * Dimens.size26,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.pinkColor),
                                    ),
                                  ),
                                  Text(
                                    CustomObject.x.toStringAsFixed(1),
                                    style: TextStyle(
                                        color: ConstantColors.primaryColor,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isReachedHintTwoFromLeft == true ? true : false,
                            child: Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: SizeConfig.defaultSize! * Dimens.size26,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.greenColor),
                                    ),
                                  ),

                                 /* Text(
                                    (CustomObject.x - CustomObject.posX).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ConstantColors.greenColor,
                                        fontSize: 12),
                                  ),*/
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    ///----------- hello world top line conditions ---------
                    Text(
                      key: keyTextHelloWorld,
                      "Hello World",
                      style: TextStyle(
                        color: ConstantColors.primaryColor,
                          fontSize: SizeConfig.defaultSize! * Dimens.size2),
                    ),
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisibleForHelloWord == false
                          ? false
                          : true,
                      child: Column(
                        children: [

                          Visibility(
                          visible: isReachedHintTwoFromRight == true?true:false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Row(
                              children: [
                                 Text(
                                    (CustomObject.posX - CustomObject.x).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ConstantColors.greenColor,
                                        fontSize: 12),
                                  ),
                                SizedBox(
                                    width: SizeConfig.defaultSize! * Dimens.size26,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.greenColor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ),

                          Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: isReachedHintTwoFromRight == true?false:true,

                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Text(
                                    CustomObject.x.toStringAsFixed(1),
                                    style: TextStyle(
                                        color: ConstantColors.primaryColor,
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.defaultSize! * Dimens.size26,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.pinkColor),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),

                          Visibility(
                            visible: isReachedHintTwoFromRight == true?true:false,
                            child: Padding(
                              padding: EdgeInsets.only(right: 50),
                              child: SizedBox(
                                width: SizeConfig.defaultSize! * Dimens.size26,
                                height: 1.0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      color: ConstantColors.greenColor),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),

                ///------------- Blup Above line --------
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isCanvasLineVisibleForHelloWord == false ? false : true,
                  child: Row(
                    children: [

                      Visibility(
                        visible: isReachedHintTwoFromAbove == true?true:false,
                        child: Padding(
                          padding: EdgeInsets.only(right: 40),
                          child: Column(
                            children: [
                               Text(
                                    (CustomObject.posY - CustomObject.y).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ConstantColors.greenColor,
                                        fontSize: 12),
                                  ),
                              SizedBox(
                                width: 1.0,
                                height: SizeConfig.defaultSize! * Dimens.size36,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: ConstantColors.greenColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      Visibility(
                        visible: isReachedHintTwoFromAbove == true?false:true,

                        child: Column(
                          children: [
                            Text(
                              CustomObject.y.toStringAsFixed(1),
                              style: TextStyle(
                                  color: ConstantColors.primaryColor,
                                  fontSize: 15),
                            ),
                            SizedBox(
                              width: 1.0,
                              height: SizeConfig.defaultSize! * Dimens.size36,
                              child: DecoratedBox(
                                decoration:
                                BoxDecoration(color: ConstantColors.pinkColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: isReachedHintTwoFromAbove == true?true:false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: Column(
                            children: [
                              Text(
                                (CustomObject.posY - CustomObject.y).toStringAsFixed(0),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ConstantColors.greenColor,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: 1.0,
                                height: SizeConfig.defaultSize! * Dimens.size36,
                                child: DecoratedBox(
                                  decoration:
                                  BoxDecoration(color: ConstantColors.greenColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),




                    ],
                  ),
                ),
              ],
            ));
        break;

      ///--------------- Blup story section -------------
      case ItemType.Image:
        widget = GestureDetector(

            onScaleStart: (details) {
              if (activeItem == null) return;
              initPos = details.focalPoint;
              currentPos = activeItem.position;
              currentScale = activeItem.scale;
              currentRotation = activeItem.rotation;
              isCanvasLineVisible = true;
            },
            onScaleEnd: (detail) {
              isCanvasLineVisible = false;
              isContainerVisible = false;
              //isContainerBottomVisible = false;
              setState(() {});
            },
            onScaleUpdate: (details) {
              if (activeItem == null) {
                return;
              }
              final delta = details.focalPoint - initPos;
              final left = (delta.dx / screen.width) + currentPos.dx;
              final top = (delta.dy / screen.height) + currentPos.dy;

              setState(() {
                activeItem.position = Offset(left, top);
                activeItem.rotation = details.rotation + currentRotation;
                activeItem.scale = max(min(details.scale * currentScale, 3), 0.2);

                isContainerBottomVisible = true;
                calculateSizeAndPositionForBlupText();
              });
            },
            child: Column(
              children: [
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isCanvasLineVisible == false ? false : true,
                  child: Column(
                    children: [

                      Row(
                        children: [
                          Visibility(
                            visible: isReachedFromBelow == true?true:false,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 1.0,
                                    height: helloHeight,
                                    child: DecoratedBox(
                                      decoration:
                                      BoxDecoration(color: ConstantColors.greenColor),
                                    ),
                                  ),

                                  Text(
                                    (CustomObject.posY - CustomObject.y).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ConstantColors.greenColor,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isReachedFromBelow == true?false:true,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 1.0,
                                  height: helloHeight,
                                  child: DecoratedBox(
                                    decoration:
                                        BoxDecoration(color: ConstantColors.pinkColor),
                                  ),
                                ),
                                Text(
                                  CustomObject.posY.toStringAsFixed(0),
                                  style: TextStyle(
                                      color: ConstantColors.primaryColor, fontSize: 15),
                                ),
                              ],
                            ),
                          ),

                          Visibility(
                            visible: isReachedFromBelow == true?true:false,
                            child: Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Column(
                                children: [

                                  SizedBox(
                                    width: 1.0,
                                    height: helloHeight,
                                    child: DecoratedBox(
                                      decoration:
                                      BoxDecoration(color: ConstantColors.greenColor),
                                    ),
                                  ),
                                  Text(
                                    (CustomObject.posY - CustomObject.y).toStringAsFixed(0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ConstantColors.greenColor,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                Row(
                  children: [
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisible == false ? false : true,
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Visibility(
                                visible: isReachedFromRight==true?true:false,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5,right: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: SizeConfig.defaultSize! * Dimens.size26,
                                        height: 1.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: ConstantColors.greenColor),
                                        ),
                                      ),
                                      Text(
                                        (CustomObject.posX - CustomObject.x).toStringAsFixed(0),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ConstantColors.greenColor,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isReachedFromRight==true?false:true,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: SizeConfig.defaultSize! * Dimens.size26,
                                        height: 1.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: ConstantColors.pinkColor),
                                        ),
                                      ),

                                      Text(
                                        CustomObject.posX.toStringAsFixed(0),
                                        style: TextStyle(
                                            color: ConstantColors.primaryColor,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isReachedFromRight==true?true:false,
                                child: Padding(
                                  padding: EdgeInsets.only(top:5),

                                  child: SizedBox(
                                    width: SizeConfig.defaultSize! * Dimens.size26,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.greenColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    Text(
                      key: keyTextForImage,
                      "Hello World",
                      style: TextStyle(
                        color: ConstantColors.secondaryColor,
                          fontSize: SizeConfig.defaultSize! * Dimens.size2),
                    ),
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisible == false ? false : true,
                      child: Row(
                        children: [

                          Column(
                            children: [
                              Visibility(
                                visible: isReachedFromLeft==true?true:false,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 5,left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        (CustomObject.x - CustomObject.posX ).toStringAsFixed(0),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ConstantColors.greenColor,
                                            fontSize: 12),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        height: 1.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: ConstantColors.greenColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: isReachedFromLeft==true?false:true,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        CustomObject.posX.toStringAsFixed(0),
                                        style: TextStyle(
                                            color: ConstantColors.primaryColor,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.defaultSize! * Dimens.size26,
                                        height: 1.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: ConstantColors.pinkColor),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),


                              ),

                              Visibility(
                                visible: isReachedFromLeft==true?true:false,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: SizedBox(
                                    width: 180,
                                    height: 1.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: ConstantColors.greenColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isCanvasLineVisible == false ? false : true,
                  child: Row(
                    children: [
                      Visibility(
                        visible: isReachedFromAbove == true?true:false,
                        child: Padding(
                          padding: EdgeInsets.only(right: 55),
                          child: Column(
                            children: [
                              Text(
                                (CustomObject.y - CustomObject.posY ).toStringAsFixed(0),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ConstantColors.greenColor,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: 1.0,
                                height: SizeConfig.defaultSize! * Dimens.size36,
                                child: DecoratedBox(
                                  decoration:
                                  BoxDecoration(color: ConstantColors.greenColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Visibility(
                        visible: isReachedFromAbove == true?false:true,
                        child: Column(
                          children: [
                            Text(
                              CustomObject.posY.toStringAsFixed(0),
                              style: TextStyle(
                                  color: ConstantColors.primaryColor, fontSize: 15),
                            ),
                            SizedBox(
                              width: 1.0,
                              height: SizeConfig.defaultSize! * Dimens.size36,
                              child: DecoratedBox(
                                decoration:
                                BoxDecoration(color: ConstantColors.pinkColor),
                              ),
                            ),

                          ],
                        ),
                      ),

                      Visibility(
                        visible: isReachedFromAbove == true?true:false,
                        child: Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Column(
                            children: [
                              Text(
                                (CustomObject.y - CustomObject.posY ).toStringAsFixed(0),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ConstantColors.greenColor,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: 1.0,
                                height: SizeConfig.defaultSize! * Dimens.size36,
                                child: DecoratedBox(
                                  decoration:
                                  BoxDecoration(color: ConstantColors.greenColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
        break;
    }

    return Positioned(
        top: e.position.dy * screen.height,
        left: e.position.dx * screen.width,
        child: Transform.scale(
            scale: e.scale,
            child: Transform.rotate(
                angle: e.rotation,
                child: Listener(
                    onPointerDown: (details) {
                      if (inAction) return;
                      inAction = true;
                      activeItem = e;
                      initPos = details.position;
                      currentPos = e.position;
                      currentScale = e.scale;
                      currentRotation = e.rotation;
                    },
                    onPointerUp: (details) {
                      inAction = false;
                    },
                    child: widget))));
  }

  void calculateSizeAndPositionForBlupText() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // final RenderBox? box = keyText.currentContext?.findRenderObject();
        final RenderBox box =
            keyTextForImage.currentContext!.findRenderObject() as RenderBox;

        setState(() {
          position = box.localToGlobal(Offset.zero);
          size = box.size;
          CustomObject.posX = double.parse(position.dx.toStringAsFixed(0));
          CustomObject.posY = double.parse(position.dy.toStringAsFixed(0));

          if(CustomObject.posY == CustomObject.y &&
             CustomObject.posY == CustomObject.y + 200 ||
             CustomObject.posY >= CustomObject.y &&
             CustomObject.posX == CustomObject.x){
            isReachedFromBelow = true;
            //helloHeight = SizeConfig.defaultSize! * Dimens.size50 - CustomObject.posX;
            isContainerVisible =true;
          }else{
            isReachedFromBelow = false;
            isContainerVisible =false;
          }

          ///---------------- Above ----------------
          if(CustomObject.posY == CustomObject.y &&
             CustomObject.posY == CustomObject.y - 200 ||
             CustomObject.posY <= CustomObject.y &&
             CustomObject.posX == CustomObject.x){
            isReachedFromAbove = true;
            isContainerBottomVisible = true;
          }else{
            isReachedFromAbove = false;
          }


          ///---------------- Right ----------------
          if(CustomObject.posX == CustomObject.x &&
              CustomObject.posX == CustomObject.x + 200 ||
              CustomObject.posX >= CustomObject.x &&
              CustomObject.posY == CustomObject.y){
            print("====>>>REACHED");
            isReachedFromRight = true;
           // isContainerBottomVisible = true;
          }else{
            isReachedFromRight = false;
          }

          ///---------------- Left ----------------
          if(CustomObject.posX == CustomObject.x &&
              CustomObject.posX == CustomObject.x - 200 ||
              CustomObject.posX <= CustomObject.x &&
              CustomObject.posY == CustomObject.y){
            print("====>>>REACHED");
            isReachedFromLeft = true;
            // isContainerBottomVisible = true;
          }else{
            isReachedFromLeft = false;
          }


          print("----*** POSX:  " + CustomObject.posX.toString() + " " + "CUSTOM X:  " + CustomObject.x.toString());
        });
      });

  void calculateSizeAndPositionForHelloText() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // final RenderBox? box = keyText.currentContext?.findRenderObject();
        final RenderBox box =
            keyTextHelloWorld.currentContext!.findRenderObject() as RenderBox;

        setState(() {
          position = box.localToGlobal(Offset.zero);
          size = box.size;

          CustomObject.x = double.parse(position.dx.toStringAsFixed(0));
          CustomObject.y = double.parse(position.dy.toStringAsFixed(0));

          if(CustomObject.y == CustomObject.posY &&
              CustomObject.y == CustomObject.posY + 200 ||
              CustomObject.y >= CustomObject.posY &&
              CustomObject.x == CustomObject.posX){
            isReachedHintTwoFromBelow = true;
            //helloHeight = SizeConfig.defaultSize! * Dimens.size50 - CustomObject.posX;
            isContainerVisible =true;
          }else{
            isReachedHintTwoFromBelow = false;
            isContainerVisible =false;
          }

          ///---------------- Above ----------------
          if(CustomObject.y == CustomObject.posY &&
              CustomObject.y == CustomObject.posY - 200 ||
              CustomObject.y <= CustomObject.posY &&
              CustomObject.x == CustomObject.posX){
            isReachedHintTwoFromAbove = true;
           // isContainerBottomVisible = true;
          }else{
            isReachedHintTwoFromAbove = false;
          }

          ///---------------- Left ----------------
          if(CustomObject.posX == CustomObject.x &&
              CustomObject.posX == CustomObject.x - 200 ||
              CustomObject.posX <= CustomObject.x &&
              CustomObject.posY == CustomObject.y){
            isReachedHintTwoFromLeft = true;
          }else{
            isReachedHintTwoFromLeft = false;
          }


          ///---------------- Right ----------------
          if(CustomObject.posX == CustomObject.x &&
              CustomObject.posX == CustomObject.x + 200 ||
              CustomObject.posX >= CustomObject.x &&
                  CustomObject.posY == CustomObject.y){
            print("====>>>REACHED");
            isReachedHintTwoFromRight = true;
            // isContainerBottomVisible = true;
          }else{
            isReachedHintTwoFromRight = false;
          }

          print("----*** POSX:  " + CustomObject.posX.toString() + " " + "CUSTOM X:  " + CustomObject.x.toString());

          // print("====>> ImagePositon" + 'X: ${position.dx.toInt()} +     Y: ${position.dy.toInt()}');
        });
      });
}
