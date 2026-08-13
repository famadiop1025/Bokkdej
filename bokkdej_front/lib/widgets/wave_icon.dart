import 'package:flutter/material.dart';

class WaveIcon extends StatelessWidget {
  final double size;
  final Color? color;
  
  const WaveIcon({
    Key? key,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: WaveIconPainter(color: color),
    );
  }
}

class WaveIconPainter extends CustomPainter {
  final Color? color;
  
  WaveIconPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color ?? const Color(0xFF0066CC);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.8);

    // Fond arrondi
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Lettre W stylisée
    final wPath = Path();
    final wSize = size.width * 0.6;
    final wX = (size.width - wSize) / 2;
    final wY = (size.height - wSize) / 2;
    
    // Dessiner un W simple
    wPath.moveTo(wX, wY + wSize);
    wPath.lineTo(wX + wSize * 0.1, wY);
    wPath.lineTo(wX + wSize * 0.3, wY + wSize * 0.6);
    wPath.lineTo(wX + wSize * 0.5, wY);
    wPath.lineTo(wX + wSize * 0.7, wY + wSize * 0.6);
    wPath.lineTo(wX + wSize * 0.9, wY);
    wPath.lineTo(wX + wSize, wY + wSize);
    wPath.lineTo(wX + wSize * 0.8, wY + wSize);
    wPath.lineTo(wX + wSize * 0.6, wY + wSize * 0.4);
    wPath.lineTo(wX + wSize * 0.4, wY + wSize);
    wPath.lineTo(wX + wSize * 0.2, wY + wSize);
    wPath.close();

    final wPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.9);
    
    canvas.drawPath(wPath, wPaint);

    // Vagues décoratives
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.6);

    // Vague du bas
    final bottomWave = Path();
    bottomWave.moveTo(size.width * 0.1, size.height * 0.8);
    bottomWave.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7,
      size.width * 0.5, size.height * 0.8,
    );
    bottomWave.quadraticBezierTo(
      size.width * 0.7, size.height * 0.9,
      size.width * 0.9, size.height * 0.8,
    );
    canvas.drawPath(bottomWave, wavePaint);

    // Vague du haut
    final topWave = Path();
    topWave.moveTo(size.width * 0.1, size.height * 0.2);
    topWave.quadraticBezierTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.5, size.height * 0.2,
    );
    topWave.quadraticBezierTo(
      size.width * 0.7, size.height * 0.3,
      size.width * 0.9, size.height * 0.2,
    );
    canvas.drawPath(topWave, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget pour l'icône Wave avec texte
class WaveLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? color;
  final bool showText;
  
  const WaveLogo({
    Key? key,
    this.iconSize = 24.0,
    this.fontSize = 14.0,
    this.color,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WaveIcon(size: iconSize, color: color),
          const SizedBox(width: 8),
          Text(
            'Wave',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF0066CC),
            ),
          ),
        ],
      );
    } else {
      return WaveIcon(size: iconSize, color: color);
    }
  }
}
