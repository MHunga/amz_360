import 'dart:math';

import 'package:flutter/material.dart';

class ControlChervonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xffffffff).withOpacity(0.5);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: 50),
        -pi / 2 - pi / 8, pi / 4, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
