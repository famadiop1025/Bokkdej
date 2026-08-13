import 'package:flutter/material.dart';
import 'wave_icon.dart';

class WaveIconDemo extends StatelessWidget {
  const WaveIconDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icônes Wave'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Icônes Wave - Démonstration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Différentes tailles
            const Text(
              'Différentes tailles:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    WaveIcon(size: 16),
                    const SizedBox(height: 8),
                    const Text('16px'),
                  ],
                ),
                Column(
                  children: [
                    WaveIcon(size: 24),
                    const SizedBox(height: 8),
                    const Text('24px'),
                  ],
                ),
                Column(
                  children: [
                    WaveIcon(size: 32),
                    const SizedBox(height: 8),
                    const Text('32px'),
                  ],
                ),
                Column(
                  children: [
                    WaveIcon(size: 48),
                    const SizedBox(height: 8),
                    const Text('48px'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Différentes couleurs
            const Text(
              'Différentes couleurs:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    WaveIcon(size: 32, color: const Color(0xFF0066CC)),
                    const SizedBox(height: 8),
                    const Text('Bleu Wave'),
                  ],
                ),
                Column(
                  children: [
                    WaveIcon(size: 32, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text('Vert'),
                  ],
                ),
                Column(
                  children: [
                    WaveIcon(size: 32, color: Colors.red),
                    const SizedBox(height: 8),
                    const Text('Rouge'),
                  ],
                ),
                Column(
                  children: [
                    WaveIcon(size: 32, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text('Orange'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Logo avec texte
            const Text(
              'Logo Wave avec texte:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Center(
              child: WaveLogo(
                iconSize: 32,
                fontSize: 20,
                color: const Color(0xFF0066CC),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Center(
              child: WaveLogo(
                iconSize: 24,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Exemples d'utilisation
            const Text(
              'Exemples d\'utilisation:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton de paiement
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WaveIcon(size: 24, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Payer avec Wave',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Carte d'information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  WaveIcon(size: 32, color: const Color(0xFF0066CC)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement sécurisé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vos paiements sont protégés par Wave',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Code d'exemple
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code d\'exemple:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'WaveIcon(size: 24, color: Colors.blue)',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'WaveLogo(iconSize: 32, showText: true)',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
