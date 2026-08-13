import 'package:flutter/material.dart';
import 'wave_banner_icon.dart';

class WaveBannerDemo extends StatelessWidget {
  const WaveBannerDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bannière Wave'),
        backgroundColor: const Color(0xFF00D4AA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Bannière Wave - Démonstration',
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
            
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        WaveBannerIcon(width: 80, height: 24, backgroundColor: const Color(0xFF00D4AA)),
                        const SizedBox(height: 8),
                        const Text('80x24px'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveBannerIcon(width: 100, height: 32, backgroundColor: const Color(0xFF00D4AA)),
                        const SizedBox(height: 8),
                        const Text('100x32px'),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        WaveBannerIcon(width: 120, height: 36, backgroundColor: const Color(0xFF00D4AA)),
                        const SizedBox(height: 8),
                        const Text('120x36px'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveBannerIcon(width: 150, height: 48, backgroundColor: const Color(0xFF00D4AA)),
                        const SizedBox(height: 8),
                        const Text('150x48px'),
                      ],
                    ),
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
            
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        WaveBannerIcon(width: 100, height: 32, backgroundColor: const Color(0xFF00D4AA)),
                        const SizedBox(height: 8),
                        const Text('Turquoise'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveBannerIcon(width: 100, height: 32, backgroundColor: const Color(0xFF0066CC)),
                        const SizedBox(height: 8),
                        const Text('Bleu Wave'),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        WaveBannerIcon(width: 100, height: 32, backgroundColor: Colors.green),
                        const SizedBox(height: 8),
                        const Text('Vert'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveBannerIcon(width: 100, height: 32, backgroundColor: Colors.purple),
                        const SizedBox(height: 8),
                        const Text('Violet'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Version sans texte
            const Text(
              'Version sans texte:',
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
                    WaveBannerIcon(width: 60, height: 32, backgroundColor: const Color(0xFF00D4AA), showText: false),
                    const SizedBox(height: 8),
                    const Text('Icône seule'),
                  ],
                ),
                Column(
                  children: [
                    WaveBannerIcon(width: 100, height: 32, backgroundColor: const Color(0xFF00D4AA), showText: true),
                    const SizedBox(height: 8),
                    const Text('Avec texte'),
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
                  WaveBannerIcon(width: 100, height: 32, backgroundColor: Colors.white),
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
                  WaveBannerIcon(width: 80, height: 24, backgroundColor: const Color(0xFF00D4AA)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement mobile sécurisé',
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
                color: const Color(0xFF00D4AA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À propos de la bannière Wave:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Icône smartphone avec écran\n'
                    '• Texte "WAVE" en gras\n'
                    '• Fond turquoise Wave\n'
                    '• Coins arrondis\n'
                    '• Ombre subtile\n'
                    '• Version avec/sans texte',
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
