import 'package:flutter/material.dart';
import 'pin_login_page.dart';

class StaffLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Restaurant'),
        backgroundColor: Color(0xFFFFD700),
        foregroundColor: Color(0xFF2C2C2C),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD700).withOpacity(0.2), Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  size: 80,
                  color: Color(0xFF2C2C2C),
                ),
                SizedBox(height: 24),
                Text(
                  'Espace Restaurant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Gérez votre restaurant et vos commandes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PinLoginPage(isStaff: true),
                        ),
                      );
                    },
                    icon: Icon(Icons.login, size: 24),
                    label: Text(
                      'Se connecter avec PIN',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD700),
                      foregroundColor: Color(0xFF2C2C2C),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Information'),
                        content: Text(
                          'Pour vous inscrire en tant que restaurant, '
                          'contactez l\'administrateur système.'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Pas encore inscrit ? Contactez l\'admin',
                    style: TextStyle(color: Color(0xFF2C2C2C)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}