import 'dart:ui';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';



class GuidelineScreen extends StatefulWidget {
  @override
  _GuidelineScreenState createState() => _GuidelineScreenState();
}
class _GuidelineScreenState extends State<GuidelineScreen> with TickerProviderStateMixin, ChangeNotifier {
  late Sizer currentSizer;
  double angle = 0.0;

  late AnimationController ctrl;
  ValueNotifier<int> repaint = ValueNotifier<int>(0);
  List<FadePoint> points = [];
  final Map<String, Sizer> sizers = {
    'l': Sizer('l', Alignment.centerLeft, {'t': 0.5, 'b': 0.5, 'S': 1.0, 'M': 0.5}),
    't': Sizer('t', Alignment.topCenter, {'l': 0.5, 'r': 0.5, 'M': 0.5}),
    'r': Sizer('r', Alignment.centerRight, {'t': 0.5, 'b': 0.5, 'R': 1.0, 'M': 0.5}),
    'b': Sizer('b', Alignment.bottomCenter, {'l': 0.5, 'r': 0.5, 'S': 1.0, 'R': 1.0, 'M': 0.5}),
    'S': Sizer('S', Alignment.bottomLeft, {}),
    'R': Sizer('R', Alignment.bottomRight, {}),
    'M': Sizer('M', Alignment.center, {}),
  };
  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 300), value: 1.0);
  }
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ColoredBox(
        color: Colors.black12,
        child: CustomMultiChildLayoutPainter(
          delegate: _FooResizerDelegate(sizers, this, points, repaint),
          layoutIds: [],

          children: [
            LayoutId(
              id: 'body',
              child: AnimatedBuilder(
                animation: this,
                builder: (ctx, child) {
                  return Transform.rotate(
                    angle: angle,
                    child: child,
                  );
                },
                child: Material(color: Colors.grey[300], elevation: 4, child: FlutterLogo()),
              ),
            ),
            ...sizers.values.map(_sizerBuilder),
          ],
        ),
      ),
    );
  }
  Widget _sizerBuilder(Sizer sizer) {
    final colors = {
      'M': Colors.orange,
      'R': Colors.teal,
      'S': Colors.lime,
    };
    return LayoutId(
      id: sizer.id,
      child: GestureDetector(
        onPanStart: (details) => _panStart(sizer),
        onPanUpdate: _panUpdate,
        onPanEnd: _panEnd,
        child: AnimatedBuilder(
          animation: ctrl,
          builder: (context, child) {
            final color = colors[sizer.id] ?? Colors.green;
            return Opacity(
              opacity: currentSizer == sizer? 1.0 : Curves.ease.transform(ctrl.value),
              child: Container(
                decoration: ShapeDecoration(
                  shape: CircleBorder(side: BorderSide(width: 0.2, color: Colors.black38)),
                  color: currentSizer == sizer? Color.lerp(Colors.deepPurple, color, ctrl.value) : color,
                  //shadows: [BoxShadow.lerp(BoxShadow(spreadRadius: 2, blurRadius: 4, offset: Offset(2, 2)), null, ctrl.value)],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
  _panStart(Sizer sizer) {
    currentSizer = sizer;
    ctrl.reverse();
  }
  _panUpdate(DragUpdateDetails details) {
    assert(currentSizer != null);
    if (currentSizer.id == 'S') {
      // scale
      final w = (sizers['l']!.center - sizers['r']!.center).distance;
      final h = (sizers['t']!.center - sizers['b']!.center).distance;
      final rect = Rect.fromCenter(center: sizers['M']!.center, width: w, height: h);
      final center = sizers['M']!.center;
      final matrix1 = _rotate(angle, center);
      final pivot = MatrixUtils.transformPoint(matrix1, rect.topRight);
      final scale = (sizers['S']!.center + details.delta - pivot).distance /  (sizers['S']!.center - pivot).distance;
      final matrix2 = _scale(scale, pivot);
      final finalMatrix = matrix2 * matrix1;
      for (var sizer in sizers.values) {
        sizer.center = MatrixUtils.transformPoint(finalMatrix, sizer.alignment.withinRect(rect));
      }
    } else
    if (currentSizer.id == 'M') {
      // move
      sizers.values.forEach((sizer) => sizer.center += details.delta);
    } else
    if (currentSizer.id == 'R') {
      // rotate
      final localCenter = sizers['M']!.center;
      final globalCenter = (context.findRenderObject() as RenderBox).localToGlobal(localCenter);
      final angle0 = (details.globalPosition - details.delta - globalCenter).direction;
      final angle1 = (details.globalPosition - globalCenter).direction;
      final deltaAngle = angle1 - angle0;
      sizers.values
        .where((sizer) => sizer.id != 'M')
        .forEach((sizer) {
          final vector = sizer.center - localCenter;
          sizer.center = localCenter + Offset.fromDirection(vector.direction + deltaAngle, vector.distance);
        });
      angle += deltaAngle;
    } else {
      // resize
      final adjustedAngle = angle + currentSizer.angleAdjustment;
      final rotatedDistance = details.delta.distance * cos(details.delta.direction - adjustedAngle);
      var vector = Offset.fromDirection(adjustedAngle, rotatedDistance);
      currentSizer.center += vector;
      currentSizer.dependents.forEach((id, factor) => sizers[id]?.center += vector * factor);
    }
    points.add(FadePoint(currentSizer.center));
    notifyListeners();
  }
  _panEnd(DragEndDetails details) {
    assert(currentSizer != null);
    // currentSizer = null;
    ctrl.forward();
  }
  Matrix4 _scale(double scale, Offset focalPoint) {
    var dx = (1 - scale) * focalPoint.dx;
    var dy = (1 - scale) * focalPoint.dy;
    return Matrix4(scale, 0, 0, 0, 0, scale, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }
  Matrix4 _rotate(double angle, Offset focalPoint) {
    var c = cos(angle);
    var s = sin(angle);
    var dx = (1 - c) * focalPoint.dx + s * focalPoint.dy;
    var dy = (1 - c) * focalPoint.dy - s * focalPoint.dx;
    return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }
}
class _FooResizerDelegate extends MultiChildLayoutPainterDelegate {
  static const SIZE = 48.0;
  final Map<String, Sizer> sizers;
  final List<FadePoint> points;
  final ValueNotifier<int> repaintNotifier;
  _FooResizerDelegate(this.sizers, Listenable relayout, this.points, this.repaintNotifier)
    : super(relayout: relayout);
  @override
  void performLayout(Size size) {
    //sizers['M']!.center ??= init(size);
    for (var sizer in sizers.values) {
      layoutChild(sizer.id, BoxConstraints.tight(Size(SIZE, SIZE)));
      positionChild(sizer.id, sizer.center - Offset(SIZE / 2, SIZE / 2));
    }
    //final w = (sizers['l']!.center - sizers['r']!.center).distance;
    //final h = (sizers['t']!.center - sizers['b']!.center).distance;
    layoutChild('body', BoxConstraints.tight(Size(200, 200)));
    positionChild('body', sizers['M']!.center - Offset(200 / 2, 200 / 2));
  }
  Offset init(Size size) {
    final rect = (Offset.zero & size).deflate(SIZE / 2);
    print('init rect: $rect');
    for (var sizer in sizers.values) {
      sizer
        ..center = sizer.alignment.withinRect(rect)
        ..angleAdjustment = sizer.alignment.x == 0? pi / 2 : 0;
    }
    return sizers['M']!.center;
  }
  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
  static final LIFETIME = Duration(milliseconds: 350);
  final Paint shadowPaint = Paint()
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
  @override
  void foregroundPaint(Canvas canvas, Size size) {
    final now = DateTime.now();
    points.forEach((p) {
      final opacity = (1 - now.difference(p.creationTime).inMilliseconds / LIFETIME.inMilliseconds).clamp(0.0, 1.0);
      canvas.drawCircle(p.offset, SIZE / 2, shadowPaint..color = Colors.deepPurple.withOpacity(opacity * .25));
    });
    // print(points.length);
    if (points.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(repaintCallback);
      points.removeWhere((p) => (now.difference(p.creationTime)) > LIFETIME);
    }
  }
  void repaintCallback(Duration timeStamp) {
    repaintNotifier.value++;
  }
  @override
  void paint(Canvas canvas, Size size) {
    final w = (sizers['r']!.center - sizers['l']!.center).distance;
    final h = (sizers['b']!.center - sizers['t']!.center).distance;
    final rect = Rect.fromCenter(center: sizers['M']!.center, width: w, height: h);
    final angle = (sizers['r']!.center - sizers['l']!.center).direction;
    final matrix = Matrix4.identity()
      ..translate(rect.center.dx, rect.center.dy)
      ..rotateZ(angle)
      ..translate(-rect.center.dx, -rect.center.dy);
    final transformedRect = MatrixUtils.transformRect(matrix, rect);
    final points = [
      Offset(transformedRect.left, 0), Offset(transformedRect.left, size.height),
      Offset(0, transformedRect.top), Offset(size.width, transformedRect.top),
      Offset(transformedRect.right, 0), Offset(transformedRect.right, size.height),
      Offset(0, transformedRect.bottom), Offset(size.width, transformedRect.bottom),
    ];
    canvas.drawPoints(PointMode.lines, points, Paint());
  }
}
class Sizer {
  final String id;
  final Alignment alignment;
  final Map<String, double> dependents;
  late Offset center;
  late double angleAdjustment;
  Sizer(this.id, this.alignment, this.dependents);
}
class FadePoint {
  final DateTime creationTime;
  final Offset offset;
  FadePoint(this.offset) : creationTime = DateTime.now();
}


extension LayoutIdExtension on Iterable<Widget> {
  List wrapIds(List ids) {
    int i = 0;
    return this.map((e) => LayoutId(id: ids[i++], child: e)).toList();
  }
}

class CustomMultiChildLayoutPainter extends StatelessWidget {

  CustomMultiChildLayoutPainter({
    required this.delegate,
    this.children = const <Widget>[],
    required this.layoutIds,
  }) : super();

  final MultiChildLayoutPainterDelegate delegate;
  final List<Widget> children;
  final List layoutIds;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      //painter: _PainterDelegate(delegate.paint, delegate.repaint),
     // foregroundPainter: _PainterDelegate(delegate.foregroundPaint, delegate.repaint),
      child: CustomMultiChildLayout(
        delegate: delegate,
       // children: layoutIds != null? children.wrapIds(layoutIds) : children,
      ),
    );
  }
}

abstract class MultiChildLayoutPainterDelegate extends MultiChildLayoutDelegate {
  late Listenable repaint;

  MultiChildLayoutPainterDelegate({Listenable? relayout}) : super(relayout: relayout);

  void paint(Canvas canvas, Size size);
  void foregroundPaint(Canvas canvas, Size size);
}

class CustomSingleChildLayoutPainter extends StatelessWidget {

  CustomSingleChildLayoutPainter({
    Key? key,
    required this.delegate,
    required this.child,
  }) : super(key: key);

  final SingleChildLayoutPainterDelegate delegate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PainterDelegate(delegate.paint, delegate.repaint),
      foregroundPainter: _PainterDelegate(delegate.foregroundPaint, delegate.repaint),
      child: CustomSingleChildLayout(
        delegate: delegate,
        child: child,
      ),
    );
  }
}

abstract class SingleChildLayoutPainterDelegate extends SingleChildLayoutDelegate {
  Listenable repaint;

  SingleChildLayoutPainterDelegate({
    required Listenable relayout,
    required this.repaint,
  }) : super(relayout: relayout);

  void paint(Canvas canvas, Size size);
  void foregroundPaint(Canvas canvas, Size size);
}

class _PainterDelegate extends CustomPainter {
  final void Function(Canvas, Size) paintDelegate;

  _PainterDelegate(this.paintDelegate, Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) => paintDelegate(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}