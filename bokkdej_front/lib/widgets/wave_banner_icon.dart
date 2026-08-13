import 'package:flutter/material.dart';

class WaveBannerIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color? backgroundColor;
  final bool showText;
  
  const WaveBannerIcon({
    Key? key,
    this.width = 120.0,
    this.height = 40.0,
    this.backgroundColor,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: WaveBannerIconPainter(
        backgroundColor: backgroundColor ?? const Color(0xFF00D4AA),
        showText: showText,
      ),
    );
  }
}

class WaveBannerIconPainter extends CustomPainter {
  final Color backgroundColor;
  final bool showText;
  
  WaveBannerIconPainter({
    required this.backgroundColor,
    required this.showText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Fond de la bannière (turquoise)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    paint.color = backgroundColor;
    canvas.drawRRect(rect, paint);

    // Icône smartphone (carré avec icône)
    final iconSize = size.height * 0.6;
    final iconX = size.height * 0.2;
    final iconY = size.height * 0.2;
    
    // Carré de fond pour l'icône smartphone
    final iconBgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(iconX, iconY, iconSize, iconSize),
      const Radius.circular(4),
    );
    paint.color = backgroundColor.withOpacity(0.8);
    canvas.drawRRect(iconBgRect, paint);

    // Icône smartphone (rectangle avec écran)
    final phoneWidth = iconSize * 0.4;
    final phoneHeight = iconSize * 0.6;
    final phoneX = iconX + (iconSize - phoneWidth) / 2;
    final phoneY = iconY + (iconSize - phoneHeight) / 2;
    
    // Corps du smartphone
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(phoneX, phoneY, phoneWidth, phoneHeight),
      const Radius.circular(2),
    );
    paint.color = Colors.white;
    canvas.drawRRect(phoneRect, paint);

    // Écran du smartphone
    final screenWidth = phoneWidth * 0.7;
    final screenHeight = phoneHeight * 0.6;
    final screenX = phoneX + (phoneWidth - screenWidth) / 2;
    final screenY = phoneY + (phoneHeight - screenHeight) / 2;
    
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(screenX, screenY, screenWidth, screenHeight),
      const Radius.circular(1),
    );
    paint.color = backgroundColor;
    canvas.drawRRect(screenRect, paint);

    // Bouton home (petit cercle en bas)
    final homeButtonY = phoneY + phoneHeight - phoneHeight * 0.15;
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(phoneX + phoneWidth / 2, homeButtonY),
      phoneWidth * 0.08,
      paint,
    );

    if (showText) {
      // Texte "Wave" (si l'espace le permet)
      if (size.width > 80) {
        final textX = iconX + iconSize + size.height * 0.2;
        final textY = size.height * 0.7;
        
        // Dessiner le texte "WAVE" en blanc
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'WAVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: size.height * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(textX, textY - textPainter.height / 2));
      }
    }

    // Ombre sous la bannière
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width, size.height),
      const Radius.circular(8),
    );
    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawRRect(shadowRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
