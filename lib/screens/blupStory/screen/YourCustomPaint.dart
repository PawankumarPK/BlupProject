
import 'package:blup_task/utils/CustomObject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
class YourCustomPaint extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.red..strokeCap = StrokeCap.square..strokeWidth = 3;

    _drawDashedLine(canvas, size, paint );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawDashedLine(Canvas canvas, Size size, Paint paint) {
    // Chage to your preferred size
    const int dashWidth = 4;
    const int dashSpace = 4;

    // Start to draw from left size.
    // Of course, you can change it to match your requirement.
    int startX = CustomObject.x.toInt();
    int y = CustomObject.y.toInt();

    print("====>>>> X: " + startX.toString() + "  " + "Y:  " + y.toString());

    // Repeat drawing until we reach the right edge.
    // In our example, size.with = 300 (from the SizedBox)
    while (startX < size.width) {
      // Draw a small line.
      canvas.drawLine(Offset(startX.toDouble(), y.toDouble()), Offset(startX.toDouble() + dashWidth, y.toDouble()), paint);

      // Update the starting X
      startX += dashWidth + dashSpace;
    }
  }
}
*/



class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size){
    var myPaint = Paint()
      ..color = Color(0xffff0000)
      ..strokeWidth = 0;
    canvas.drawLine(
        Offset(0,0),
        Offset(size.width,size.height),
        myPaint);
    canvas.scale(10,10);
    canvas.drawLine(
        Offset(size.width/10,0),
        Offset(0,size.height/10),
        myPaint);

  }
  @override
  bool shouldRepaint(MyCustomPainter arg) => true;
}