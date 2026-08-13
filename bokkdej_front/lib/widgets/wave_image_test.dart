import 'package:flutter/material.dart';

class WaveImageTest extends StatelessWidget {
  final double width;
  final double height;
  
  const WaveImageTest({
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
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 3),
      ),
      child: Image.asset(
        'assets/images/wave_official_logo.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Erreur de chargement de l\'image Wave: $error');
          return Container(
            color: Colors.red,
            child: const Center(
              child: Text(
                'ERREUR\nIMAGE\nWAVE',
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
    );
  }
}
