import 'package:flutter/material.dart';

class WaveDebugSimple extends StatelessWidget {
  final double width;
  final double height;
  
  const WaveDebugSimple({
    Key? key,
    this.width = 100.0,
    this.height = 32.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.red, // Fond rouge pour voir la taille
      child: Image.asset(
        'assets/images/wave_new_logo.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('ERREUR IMAGE WAVE: $error');
          return Container(
            color: Colors.blue,
            child: Center(
              child: Text(
                'ERREUR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


