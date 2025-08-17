import 'package:flutter/material.dart';

class SafeImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  String _getCorrectImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Si l'URL commence déjà par http, la retourner telle quelle
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Sinon, ajouter l'URL de base
    const String baseUrl = 'http://localhost:8000';
    
    // S'assurer qu'il n'y a qu'un seul slash
    if (imagePath.startsWith('/')) {
      return '$baseUrl$imagePath';
    } else {
      return '$baseUrl/$imagePath';
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctedUrl = _getCorrectImageUrl(imageUrl);
    
    if (correctedUrl.isEmpty) {
      return errorWidget ?? _buildDefaultPlaceholder();
    }

    return Image.network(
      correctedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultPlaceholder();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant,
        size: (width ?? 50) * 0.4,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
