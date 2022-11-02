
import 'dart:ui';

enum ItemType { Image, Text }

class EditableItem {
  Offset position = const Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  late ItemType type;
  late String value;
}