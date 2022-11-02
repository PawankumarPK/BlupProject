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
import '../../../utils/EditableItem.dart';
import '../../../utils/SizeConfig.dart';
import '../widget/SaveImage.dart';
import '../widget/TopIconContainers.dart';

class BlupStoryScreen extends StatefulWidget {
  const BlupStoryScreen({Key? key}) : super(key: key);

  @override
  _BlupStoryScreenState createState() => _BlupStoryScreenState();
}

class _BlupStoryScreenState extends State<BlupStoryScreen> {
  late EditableItem activeItem;
  late Offset initPos;
  late Offset currentPos;
  late double currentScale;
  late double currentRotation;
  bool inAction = false;
  late File file;

  var isImageCapture = false;
  var isCanvasVisible = false;

  TextEditingController contentController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();

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
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  ///----------------- Pick Image --------------------
                  InkWell(
                      onTap: () => {selectOptionBottomSheet()},
                      child: TopIconContainer(icon: Icons.photo_camera_rounded)),

                  ///----------------- Enter content text --------------------
                  InkWell(
                      onTap: () =>
                      {showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return  enterContentDialog();
                          })
                      },
                      child: TopIconContainer(icon: Icons.text_fields)),

                  ///----------------- Pick Brush --------------------
                  InkWell(
                      onTap: () =>
                      {
                        if (isCanvasVisible == true){
                          isCanvasVisible = false
                        }
                        else {
                          isCanvasVisible = true
                        },
                        setState(() {})
                      },
                      child: TopIconContainer(icon: Icons.brush)),

                  ///----------------- Save image --------------------
                  InkWell(
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ConstantString.pleaseWait)));
                        var image = await screenshotController.captureFromWidget(buildStory());
                        if (image == null) {
                          return;
                        }
                        await saveImage(image,context);

                      },
                      child: TopIconContainer(icon: Icons.save)),
                ],
              )),
          Expanded(
            flex: 9,
            child: GestureDetector(
              onScaleStart: (details) {
                if (activeItem == null) return;
                initPos = details.focalPoint;
                currentPos = activeItem.position;
                currentScale = activeItem.scale;
                currentRotation = activeItem.rotation;
              },
              onScaleUpdate: (details) {
                if (activeItem == null) return;
                final delta = details.focalPoint - initPos;
                final left = (delta.dx / screen.width) + currentPos.dx;
                final top = (delta.dy / screen.height) + currentPos.dy;

                setState(() {
                  activeItem.position = Offset(left, top);
                  activeItem.rotation = details.rotation + currentRotation;
                  activeItem.scale = max(min(details.scale * currentScale, 3), 0.2);
                });
              },
              child: buildStory(),
            ),
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
    switch (e.type) {
      case ItemType.Text:
        widget =  Text(
          contentController.text,
          style: const TextStyle(color: Colors.black),
        );
        break;
      case ItemType.Image:
        widget = Column(
          children: [
            Visibility(
                visible: isImageCapture == false ? true : false,
                child:  Text(
                  ConstantString.blupStoryEditorApp,
                  style: TextStyle(fontSize: SizeConfig.defaultSize! * Dimens.size2),
                )),
            isImageCapture == false ? Container() : showImage(file)
          ],
        );
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

  ///---------------- Choose image section -----------------
  //select picture from camera and gallery
  Future selectPicture(ImageSource source) async {
    final picker = ImagePicker();
    var imageFile = await picker.pickImage(source: source);
    if (mounted) {
      setState(() {
        file = File(imageFile!.path);
        isImageCapture = true;
      });
    }
  }

  //show picked image into story screen
  Widget showImage(File file) {
    if (file != null) {
      return Image.file(
        file,
        width: SizeConfig.defaultSize! * Dimens.size20,
        height: SizeConfig.defaultSize! * Dimens.size20,
        fit: BoxFit.cover,
      );
    } else {
      return Text(ConstantString.fileNotLoaded);
    }
  }

  //open option selection bottom sheet for where you pick image
  void selectOptionBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.black12,
            child: Wrap(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(SizeConfig.defaultSize! * Dimens.sizePoint5),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: SizeConfig.screenWidth,
                        padding: EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize! * Dimens.size1),
                        alignment: Alignment.center,
                        child: Text(
                          ConstantString.chooseOption,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          selectPicture(ImageSource.camera);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: SizeConfig.screenWidth,
                          padding: EdgeInsets.all(SizeConfig.defaultSize! * Dimens.size1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.camera_alt,
                                color: Colors.black.withOpacity(0.7),
                                size: SizeConfig.defaultSize! * Dimens.size2,
                              ),
                              SizedBox(
                                width: SizeConfig.defaultSize! * Dimens.size1,
                              ),
                               Text(
                                ConstantString.camera,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          selectPicture(ImageSource.gallery);
                        },
                        child: Container(
                          width: SizeConfig.screenWidth,
                          padding: EdgeInsets.all(SizeConfig.defaultSize! * Dimens.size1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.photo_album,
                                color: Colors.black.withOpacity(0.7),
                                size: SizeConfig.defaultSize! * Dimens.size2,
                              ),
                               SizedBox(
                                width: SizeConfig.defaultSize! * Dimens.size1,
                              ),
                               Text(
                                ConstantString.uploadFromGallery,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }


  ///------------------ Enter content text dialog box --------------
  Widget enterContentDialog(){
   return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.defaultSize! * Dimens.size2),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.defaultSize! * Dimens.size2),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.defaultSize! * Dimens.size1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, SizeConfig.defaultSize! * Dimens.sizePoint2),
                  blurRadius: SizeConfig.defaultSize! * Dimens.size1),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: SizeConfig.defaultSize! * Dimens.size2,bottom: SizeConfig.defaultSize! * Dimens.size2),
              child:  TextField (
                controller: contentController,
                decoration:  InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: ConstantString.enterContent,
                  hintText: '',
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: MaterialButton(
                  color: ConstantColors.secondaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text(ConstantString.done,
                    style: TextStyle(
                      color: ConstantColors.textWhiteColor,
                      fontSize: SizeConfig.defaultSize! * Dimens.size1Point8,
                    ),
                  )),
            ),
          ],
        ),

    ));
  }
}
