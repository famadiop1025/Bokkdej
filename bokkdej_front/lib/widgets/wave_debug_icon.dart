import 'package:flutter/material.dart';

class WaveDebugIcon extends StatelessWidget {
  final double width;
  final double height;
  
  const WaveDebugIcon({
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
        color: Colors.red, // Couleur très visible
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 3), // Bordure très visible
      ),
      child: const Center(
        child: Text(
          'WAVE DEBUG',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
