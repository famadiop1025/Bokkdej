import 'package:flutter/material.dart';

class WaveTestIcon extends StatelessWidget {
  final double width;
  final double height;
  
  const WaveTestIcon({
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
        color: const Color(0xFF00D4AA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          // Test de l'image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wave_official_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('Erreur de chargement de l\'image Wave: $error');
                return Container(
                  color: Colors.red.withOpacity(0.3),
                  child: const Center(
                    child: Text(
                      'ERREUR\nIMAGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          // Indicateur de test
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
