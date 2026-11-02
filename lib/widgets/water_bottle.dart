import 'package:flutter/material.dart';

class WaterBottleWidget extends StatelessWidget {
  const WaterBottleWidget({
    super.key,
    required this.fillLevel,
    this.width = 110,
    this.height = 200,
  });

  /// 0.0 (empty) to 1.0 (full).
  final double fillLevel;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: fillLevel.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => CustomPaint(
        size: Size(width, height),
        painter: _BottlePainter(
          level: value,
          water: Colors.lightBlue.shade400,
          outline: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  _BottlePainter({
    required this.level,
    required this.water,
    required this.outline,
  });

  final double level;
  final Color water;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(w * .38, h * .06)
      ..lineTo(w * .62, h * .06)
      ..lineTo(w * .62, h * .14)
      ..quadraticBezierTo(w * .85, h * .20, w * .85, h * .34)
      ..lineTo(w * .85, h * .92)
      ..quadraticBezierTo(w * .85, h * .98, w * .79, h * .98)
      ..lineTo(w * .21, h * .98)
      ..quadraticBezierTo(w * .15, h * .98, w * .15, h * .92)
      ..lineTo(w * .15, h * .34)
      ..quadraticBezierTo(w * .15, h * .20, w * .38, h * .14)
      ..close();

    // Water, clipped to the bottle outline so it follows the shape.
    final top = h * .14;
    final bottom = h * .98;
    final waterTop = bottom - (bottom - top) * level;
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromLTRB(0, waterTop, w, bottom),
      Paint()..color = water.withValues(alpha: .85),
    );
    canvas.restore();

    canvas.drawPath(
      body,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    // Cap.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .36, 0, w * .28, h * .06),
        const Radius.circular(4),
      ),
      Paint()..color = outline,
    );
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.level != level || old.water != water || old.outline != outline;
}
