import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class StickManWidget extends StatelessWidget {
  const StickManWidget({
    super.key,
    required this.progress,
    this.width = 140,
    this.height = 200,
  });

  /// 0.0 (skinny) to 1.0 (very muscular). Grows a little with every stretch.
  final double progress;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => CustomPaint(
        size: Size(width, height),
        painter: _StickManPainter(level: value, color: Colors.orange.shade800),
      ),
    );
  }
}

class _StickManPainter extends CustomPainter {
  _StickManPainter({required this.level, required this.color});

  final double level;
  final Color color;

  Paint _stroke(double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final limb = lerpDouble(3, 11, level)!;
    final torso = lerpDouble(4, 20, level)!;
    final fill = Paint()..color = color;

    // Head.
    canvas.drawCircle(Offset(cx, h * .12), w * .12, _stroke(3));

    // Torso and shoulders.
    final shoulderY = h * .27;
    final hipY = h * .58;
    final shoulderHalf = lerpDouble(w * .08, w * .14, level)!;
    canvas.drawLine(Offset(cx, shoulderY), Offset(cx, hipY), _stroke(torso));
    canvas.drawLine(
      Offset(cx - shoulderHalf, shoulderY),
      Offset(cx + shoulderHalf, shoulderY),
      _stroke(limb),
    );

    for (final side in const [-1.0, 1.0]) {
      // Arms in a flexing pose, with a biceps bulge that grows with level.
      final shoulder = Offset(cx + side * shoulderHalf, shoulderY);
      final elbow = Offset(cx + side * w * .36, h * .36);
      final hand = Offset(cx + side * w * .40, h * .20);
      canvas.drawPath(
        Path()
          ..moveTo(shoulder.dx, shoulder.dy)
          ..lineTo(elbow.dx, elbow.dy)
          ..lineTo(hand.dx, hand.dy),
        _stroke(limb),
      );
      canvas.drawCircle(
        Offset.lerp(shoulder, elbow, .55)!,
        lerpDouble(0, w * .075, level)!,
        fill,
      );

      // Legs with a thigh bulge.
      final hip = Offset(cx, hipY);
      final knee = Offset(cx + side * w * .14, h * .78);
      final foot = Offset(cx + side * w * .16, h * .96);
      canvas.drawPath(
        Path()
          ..moveTo(hip.dx, hip.dy)
          ..lineTo(knee.dx, knee.dy)
          ..lineTo(foot.dx, foot.dy),
        _stroke(limb),
      );
      canvas.drawCircle(
        Offset.lerp(hip, knee, .5)!,
        lerpDouble(0, w * .06, level)!,
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StickManPainter old) =>
      old.level != level || old.color != color;
}
