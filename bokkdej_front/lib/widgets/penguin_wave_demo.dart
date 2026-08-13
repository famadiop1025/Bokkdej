import 'package:flutter/material.dart';
import 'penguin_wave_icon.dart';

class PenguinWaveDemo extends StatelessWidget {
  const PenguinWaveDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icône Pingouin Wave'),
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
              'Icône Pingouin Wave - Démonstration',
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
                    PenguinWaveIcon(size: 16, backgroundColor: const Color(0xFF0066CC)),
                    const SizedBox(height: 8),
                    const Text('16px'),
                  ],
                ),
                Column(
                  children: [
                    PenguinWaveIcon(size: 24, backgroundColor: const Color(0xFF0066CC)),
                    const SizedBox(height: 8),
                    const Text('24px'),
                  ],
                ),
                Column(
                  children: [
                    PenguinWaveIcon(size: 32, backgroundColor: const Color(0xFF0066CC)),
                    const SizedBox(height: 8),
                    const Text('32px'),
                  ],
                ),
                Column(
                  children: [
                    PenguinWaveIcon(size: 48, backgroundColor: const Color(0xFF0066CC)),
                    const SizedBox(height: 8),
                    const Text('48px'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Différentes couleurs de fond
            const Text(
              'Différentes couleurs de fond:',
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
                    PenguinWaveIcon(size: 32, backgroundColor: const Color(0xFF0066CC)),
                    const SizedBox(height: 8),
                    const Text('Bleu Wave'),
                  ],
                ),
                Column(
                  children: [
                    PenguinWaveIcon(size: 32, backgroundColor: Colors.green),
                    const SizedBox(height: 8),
                    const Text('Vert'),
                  ],
                ),
                Column(
                  children: [
                    PenguinWaveIcon(size: 32, backgroundColor: Colors.purple),
                    const SizedBox(height: 8),
                    const Text('Violet'),
                  ],
                ),
                Column(
                  children: [
                    PenguinWaveIcon(size: 32, backgroundColor: Colors.orange),
                    const SizedBox(height: 8),
                    const Text('Orange'),
                  ],
                ),
              ],
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
                  PenguinWaveIcon(size: 24, backgroundColor: const Color(0xFF0066CC)),
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  PenguinWaveIcon(size: 32, backgroundColor: const Color(0xFF0066CC)),
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
            
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À propos de l\'icône Pingouin Wave:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Pingouin amical avec un salut\n'
                    '• Corps noir avec ventre blanc\n'
                    '• Bec et pieds orange\n'
                    '• Yeux expressifs\n'
                    '• Fond bleu Wave personnalisable',
                    style: TextStyle(fontSize: 14),
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
