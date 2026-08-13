import 'package:flutter/material.dart';
import 'wave_official_icon.dart';

class WaveOfficialDemo extends StatelessWidget {
  const WaveOfficialDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Wave Officiel'),
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
              'Logo Wave Officiel - Démonstration',
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
                        WaveOfficialIcon(width: 60, height: 20),
                        const SizedBox(height: 8),
                        const Text('60x20px'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveOfficialIcon(width: 80, height: 24),
                        const SizedBox(height: 8),
                        const Text('80x24px'),
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
                        WaveOfficialIcon(width: 100, height: 32),
                        const SizedBox(height: 8),
                        const Text('100x32px'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveOfficialIcon(width: 120, height: 36),
                        const SizedBox(height: 8),
                        const Text('120x36px'),
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
                        WaveOfficialIcon(width: 150, height: 48),
                        const SizedBox(height: 8),
                        const Text('150x48px'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveOfficialIcon(width: 200, height: 64),
                        const SizedBox(height: 8),
                        const Text('200x64px'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Différents modes de fit
            const Text(
              'Différents modes de fit:',
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
                        WaveOfficialIcon(width: 100, height: 32, fit: BoxFit.contain),
                        const SizedBox(height: 8),
                        const Text('Contain'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveOfficialIcon(width: 100, height: 32, fit: BoxFit.cover),
                        const SizedBox(height: 8),
                        const Text('Cover'),
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
                        WaveOfficialIcon(width: 100, height: 32, fit: BoxFit.fill),
                        const SizedBox(height: 8),
                        const Text('Fill'),
                      ],
                    ),
                    Column(
                      children: [
                        WaveOfficialIcon(width: 100, height: 32, fit: BoxFit.fitWidth),
                        const SizedBox(height: 8),
                        const Text('FitWidth'),
                      ],
                    ),
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
                  WaveOfficialIcon(width: 100, height: 32),
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
                  WaveOfficialIcon(width: 80, height: 24),
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
            
            const SizedBox(height: 16),
            
            // Header de page
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF0066CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  WaveOfficialIcon(width: 120, height: 36),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement Sécurisé Wave',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Transaction protégée et sécurisée',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
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
                    'À propos du logo Wave officiel:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Logo officiel de Wave Mobile Money\n'
                    '• Image haute qualité téléchargée depuis Apple Store\n'
                    '• Design professionnel et reconnu\n'
                    '• Tailles flexibles et adaptables\n'
                    '• Fallback automatique si l\'image n\'est pas trouvée\n'
                    '• Ombre et coins arrondis pour un rendu moderne',
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
