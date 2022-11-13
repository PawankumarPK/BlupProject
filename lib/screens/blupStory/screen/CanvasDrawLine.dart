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

  ///--------------------- Build story section ---------------------

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

                calculateSizeAndPositionForHelloText();
              });
            },
            child: Column(
              children: [
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isCanvasLineVisibleForHelloWord == false ? false : true,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 1.0,
                        height: SizeConfig.defaultSize! * Dimens.size36,
                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(color: ConstantColors.pinkColor),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              right: SizeConfig.defaultSize! * Dimens.size1),
                          child: Text(
                            CustomObject.y.toStringAsFixed(1),
                            style: TextStyle(
                                color: ConstantColors.primaryColor,
                                fontSize: 15),
                          )),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisibleForHelloWord == false
                          ? false
                          : true,
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
                          Padding(
                              padding: EdgeInsets.only(
                                  right: SizeConfig.defaultSize! * Dimens.size1),
                              child: Text(
                                CustomObject.x.toStringAsFixed(1),
                                style: TextStyle(
                                    color: ConstantColors.primaryColor,
                                    fontSize: 15),
                              )),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => {
                        isCanvasLineVisibleForHelloWord = true,
                        isCanvasLineVisible = false,
                      },
                      child: Container(
                        color: ConstantColors.textWhiteColor,
                        width: SizeConfig.defaultSize! * Dimens.size10Point5,
                        height: SizeConfig.defaultSize! * Dimens.size2,
                        child: Text(
                          key: keyTextHelloWorld,
                          "Hello World",
                          style: TextStyle(
                              fontSize: SizeConfig.defaultSize! * Dimens.size2),
                        ),
                      ),
                    ),
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisibleForHelloWord == false
                          ? false
                          : true,
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.defaultSize! * Dimens.size1),
                              child: Text(
                                CustomObject.x.toStringAsFixed(1),
                                style: TextStyle(
                                    color: ConstantColors.primaryColor,
                                    fontSize: 15),
                              )),
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
                  ],
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible:
                      isCanvasLineVisibleForHelloWord == false ? false : true,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(
                              right: SizeConfig.defaultSize! * Dimens.size1),
                          child: Text(
                            CustomObject.x.toStringAsFixed(1),
                            style: TextStyle(
                                color: ConstantColors.primaryColor,
                                fontSize: 15),
                          )),
                      SizedBox(
                        width: 1.0,
                        height: SizeConfig.screenHeight! * 1,
                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(color: ConstantColors.pinkColor),
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
                activeItem.scale =
                    max(min(details.scale * currentScale, 3), 0.2);

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
                      SizedBox(
                        width: 1.0,
                        height: SizeConfig.defaultSize! * Dimens.size36,
                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(color: ConstantColors.pinkColor),
                        ),
                      ),
                      Text(
                        CustomObject.y.toStringAsFixed(1),
                        style: TextStyle(
                            color: ConstantColors.primaryColor, fontSize: 15),
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
                          SizedBox(
                            width: SizeConfig.defaultSize! * Dimens.size26,
                            height: 1.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: ConstantColors.pinkColor),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(right: SizeConfig.defaultSize! * Dimens.size1),
                              child: Text(
                                CustomObject.x.toStringAsFixed(1),
                                style: TextStyle(
                                    color: ConstantColors.primaryColor,
                                    fontSize: 15),
                              )),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => {
                        isCanvasLineVisibleForHelloWord = false,
                        isCanvasLineVisible = true,
                      },
                      child: Container(
                        width: SizeConfig.defaultSize! * Dimens.size20,
                        height: SizeConfig.defaultSize! * Dimens.size2Point5,
                        color: ConstantColors.textWhiteColor,
                        child: Text(
                          key: keyTextForImage,
                          "Blup Story Editor App",
                          style: TextStyle(
                              fontSize: SizeConfig.defaultSize! * Dimens.size2),
                        ),
                      ),
                    ),
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: isCanvasLineVisible == false ? false : true,
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.defaultSize! * Dimens.size1),
                              child: Text(
                                CustomObject.x.toStringAsFixed(1),
                                style: TextStyle(
                                    color: ConstantColors.primaryColor,
                                    fontSize: 15),
                              )),
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
                  ],
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: isCanvasLineVisible == false ? false : true,
                  child: Column(
                    children: [
                      Text(
                        CustomObject.y.toStringAsFixed(1),
                        style: TextStyle(
                            color: ConstantColors.primaryColor, fontSize: 15),
                      ),
                      SizedBox(
                        width: 1.0,
                        height: SizeConfig.screenHeight! * 1,
                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(color: ConstantColors.pinkColor),
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

          CustomObject.x = position.dx;
          CustomObject.y = position.dy;

          // print("====>> ImagePositon" + 'X: ${position.dx.toInt()} +     Y: ${position.dy.toInt()}');
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

          CustomObject.x = position.dx;
          CustomObject.y = position.dy;

          // print("====>> ImagePositon" + 'X: ${position.dx.toInt()} +     Y: ${position.dy.toInt()}');
        });
      });
}
