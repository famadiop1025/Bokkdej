import 'package:flutter/material.dart';

class EnhancedImage extends StatefulWidget {
  final String? imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? fallbackColor;
  final IconData? fallbackIcon;
  final ColorFilter? colorFilter;

  const EnhancedImage({
    Key? key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackColor,
    this.fallbackIcon,
    this.colorFilter,
  }) : super(key: key);

  @override
  State<EnhancedImage> createState() => _EnhancedImageState();
}

class _EnhancedImageState extends State<EnhancedImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // Si pas d'image ou erreur, afficher le fallback
    if (widget.imagePath == null || widget.imagePath!.isEmpty || _hasError) {
      return _buildFallback();
    }

    return Image.asset(
      widget.imagePath!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      colorBlendMode: widget.colorFilter != null ? BlendMode.darken : null,
      errorBuilder: (context, error, stackTrace) {
        print('Erreur de chargement d\'image: ${widget.imagePath}');
        print('Erreur: $error');
        
        // Marquer comme erreur et reconstruire avec fallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
        
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.fallbackColor ?? const Color(0xFFFFD700),
            (widget.fallbackColor ?? const Color(0xFFFFD700)).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.fallbackIcon ?? Icons.restaurant,
              size: 60,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              'Image non disponible',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension pour faciliter l'utilisation
extension EnhancedImageExtension on String? {
  Widget toEnhancedImage({
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Color? fallbackColor,
    IconData? fallbackIcon,
    ColorFilter? colorFilter,
  }) {
    return EnhancedImage(
      imagePath: this,
      fit: fit,
      width: width,
      height: height,
      fallbackColor: fallbackColor,
      fallbackIcon: fallbackIcon,
      colorFilter: colorFilter,
    );
  }
}
