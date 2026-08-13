import 'package:flutter/material.dart';

class WaveNetworkTest extends StatelessWidget {
  final double width;
  final double height;
  
  const WaveNetworkTest({
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
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 3),
      ),
      child: Image.network(
        'https://is2-ssl.mzstatic.com/image/thumb/Purple122/v4/b7/77/36/b7773644-e271-648e-ec55-9f8ef6c1e9e3/AppIcon-1x_U007emarketing-0-7-0-85-220.png/1200x630wa.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Erreur de chargement de l\'image Wave depuis le web: $error');
          return Container(
            color: Colors.red,
            child: const Center(
              child: Text(
                'ERREUR\nWEB\nWAVE',
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.orange,
            child: const Center(
              child: Text(
                'CHARGEMENT WEB...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
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
