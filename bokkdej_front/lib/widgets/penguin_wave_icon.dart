import 'package:flutter/material.dart';

class PenguinWaveIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  
  const PenguinWaveIcon({
    Key? key,
    this.size = 24.0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PenguinWaveIconPainter(
        backgroundColor: backgroundColor ?? const Color(0xFF0066CC),
      ),
    );
  }
}

class PenguinWaveIconPainter extends CustomPainter {
  final Color backgroundColor;
  
  PenguinWaveIconPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Fond arrondi bleu
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    paint.color = backgroundColor;
    canvas.drawRRect(rect, paint);

    // Corps du pingouin (ovale noir)
    final bodyRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.6),
      width: size.width * 0.4,
      height: size.height * 0.5,
    );
    paint.color = Colors.black;
    canvas.drawOval(bodyRect, paint);

    // Ventre blanc du pingouin
    final bellyRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.65),
      width: size.width * 0.25,
      height: size.height * 0.3,
    );
    paint.color = Colors.white;
    canvas.drawOval(bellyRect, paint);

    // Tête du pingouin
    final headRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.35),
      width: size.width * 0.35,
      height: size.height * 0.3,
    );
    paint.color = Colors.black;
    canvas.drawOval(headRect, paint);

    // Yeux
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.3),
      size.width * 0.03,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.3),
      size.width * 0.03,
      paint,
    );

    // Pupilles
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.3),
      size.width * 0.015,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.3),
      size.width * 0.015,
      paint,
    );

    // Bec orange
    final beakPath = Path();
    beakPath.moveTo(size.width * 0.5, size.height * 0.4);
    beakPath.lineTo(size.width * 0.48, size.height * 0.45);
    beakPath.lineTo(size.width * 0.52, size.height * 0.45);
    beakPath.close();
    paint.color = Colors.orange;
    canvas.drawPath(beakPath, paint);

    // Nageoire gauche (levée)
    final flipperPath = Path();
    flipperPath.moveTo(size.width * 0.3, size.height * 0.55);
    flipperPath.lineTo(size.width * 0.2, size.height * 0.4);
    flipperPath.lineTo(size.width * 0.25, size.height * 0.5);
    flipperPath.close();
    paint.color = Colors.black;
    canvas.drawPath(flipperPath, paint);

    // Pieds orange
    paint.color = Colors.orange;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.85),
        width: size.width * 0.08,
        height: size.height * 0.06,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.85),
        width: size.width * 0.08,
        height: size.height * 0.06,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
