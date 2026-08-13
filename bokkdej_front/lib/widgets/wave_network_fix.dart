import 'package:flutter/material.dart';

class WaveNetworkFix extends StatelessWidget {
  final double width;
  final double height;
  
  const WaveNetworkFix({
    Key? key,
    this.width = 100.0,
    this.height = 32.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          'https://is2-ssl.mzstatic.com/image/thumb/Purple122/v4/b7/77/36/b7773644-e271-648e-ec55-9f8ef6c1e9e3/AppIcon-1x_U007emarketing-0-7-0-85-220.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFF00D4AA),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Erreur de chargement de l\'image Wave réseau: $error');
            return Container(
              color: const Color(0xFF00D4AA),
              child: const Center(
                child: Text(
                  'WAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}