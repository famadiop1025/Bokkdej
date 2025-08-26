import 'package:flutter/material.dart';

class EditPlatPage extends StatelessWidget {
  final Map<String, dynamic> plat;
  
  const EditPlatPage({Key? key, required this.plat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le plat'),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
      ),
      body: Center(
        child: Text('Page de modification de plat - À implémenter\nPlat: ${plat['nom'] ?? 'Sans nom'}'),
      ),
    );
  }
}
