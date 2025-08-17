import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pin_login_page.dart'; // Pour getApiBaseUrl

class Base {
  final int id;
  final String nom;
  final double prix;
  final String? description;
  final bool disponible;

  Base({
    required this.id,
    required this.nom,
    required this.prix,
    this.description,
    required this.disponible,
  });

  factory Base.fromJson(Map<String, dynamic> json) {
    return Base(
      id: json['id'],
      nom: json['nom'],
      prix: double.parse(json['prix'].toString()),
      description: json['description'],
      disponible: json['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prix': prix,
      'description': description,
      'disponible': disponible,
    };
  }
}

class BaseProvider with ChangeNotifier {
  List<Base> _bases = [];
  bool _isLoading = false;
  String? _error;
  final String _token;

  BaseProvider(this._token);

  List<Base> get bases => _bases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBases() async {
    _setLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/api/bases/'),
        headers: _token.isNotEmpty ? {'Authorization': 'Bearer $_token'} : {},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bases = data.map((base) => Base.fromJson(Map<String, dynamic>.from(base))).toList();
        _setError(null);
      } else {
        _setError('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Erreur réseau: $e');
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Base? getBaseById(int id) {
    try {
      return _bases.firstWhere((base) => base.id == id);
    } catch (e) {
      return null;
    }
  }

  Base? getBaseByName(String name) {
    try {
      return _bases.firstWhere((base) => base.nom.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
} 