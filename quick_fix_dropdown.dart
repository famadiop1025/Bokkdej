// 🔧 CORRECTION RAPIDE DROPDOWN FLUTTER
// Remplacez votre dropdown problématique par ce code

import 'package:flutter/material.dart';

// Solution 1: Dropdown sécurisé pour les types de menu
class SafeMenuTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onChanged;
  
  const SafeMenuTypeDropdown({
    Key? key,
    this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> menuTypes = [
      {'value': 'petit_dej', 'label': 'Petit-déjeuner'},
      {'value': 'dej', 'label': 'Déjeuner'},
      {'value': 'diner', 'label': 'Dîner'},
    ];

    // Vérifier que la valeur sélectionnée existe
    bool isValidSelection = menuTypes.any((type) => type['value'] == selectedValue);

    return DropdownButton<String>(
      value: isValidSelection ? selectedValue : null,
      hint: Text('Sélectionnez un type'),
      isExpanded: true,
      items: menuTypes.map((type) => DropdownMenuItem<String>(
        value: type['value'],
        child: Text(type['label']!),
      )).toList(),
      onChanged: onChanged,
    );
  }
}

// Solution 2: Dropdown générique sécurisé
class SafeDropdown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T> items;
  final Function(T?) onChanged;
  final String hint;
  final String Function(T) getLabel;
  final T Function(T) getValue;
  
  const SafeDropdown({
    Key? key,
    this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hint = 'Sélectionnez...',
    required this.getLabel,
    required this.getValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtrer les items null et éliminer les doublons
    final uniqueItems = items
        .where((item) => item != null)
        .toSet()
        .toList();

    // Vérifier que la valeur sélectionnée existe
    bool isValidSelection = uniqueItems.any((item) => getValue(item) == selectedValue);

    return DropdownButton<T>(
      value: isValidSelection ? selectedValue : null,
      hint: Text(hint),
      isExpanded: true,
      items: uniqueItems.map((item) => DropdownMenuItem<T>(
        value: getValue(item),
        child: Text(getLabel(item)),
      )).toList(),
      onChanged: onChanged,
    );
  }
}

// Solution 3: Dropdown avec gestion d'erreur
class ErrorSafeDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<Map<String, dynamic>> items;
  final Function(String?) onChanged;
  final String hint;
  
  const ErrorSafeDropdown({
    Key? key,
    this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hint = 'Sélectionnez...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Filtrer et nettoyer les données
      final cleanItems = items
          .where((item) => 
              item['value'] != null && 
              item['value'].toString().isNotEmpty)
          .toList();

      // Éliminer les doublons par valeur
      final Map<String, Map<String, dynamic>> seen = {};
      final uniqueItems = cleanItems
          .where((item) {
            String value = item['value'].toString();
            if (seen.containsKey(value)) {
              return false;
            }
            seen[value] = item;
            return true;
          })
          .toList();

      // Vérifier la validité de la sélection
      bool isValidSelection = uniqueItems
          .any((item) => item['value'].toString() == selectedValue);

      if (uniqueItems.isEmpty) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('Aucune option disponible'),
        );
      }

      return DropdownButton<String>(
        value: isValidSelection ? selectedValue : null,
        hint: Text(hint),
        isExpanded: true,
        items: uniqueItems.map((item) => DropdownMenuItem<String>(
          value: item['value'].toString(),
          child: Text(item['label']?.toString() ?? item['value'].toString()),
        )).toList(),
        onChanged: onChanged,
      );

    } catch (e) {
      // En cas d'erreur, afficher un widget de fallback
      print('Erreur dropdown: $e');
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          selectedValue ?? 'Erreur de chargement',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

// Exemple d'utilisation:
/*
SafeMenuTypeDropdown(
  selectedValue: currentType,
  onChanged: (String? newValue) {
    setState(() {
      currentType = newValue;
    });
  },
)

// Ou pour un dropdown générique:
ErrorSafeDropdown(
  selectedValue: selectedMenuItem,
  hint: 'Choisir un plat',
  items: menuItems.map((menu) => {
    'value': menu.id.toString(),
    'label': menu.nom,
  }).toList(),
  onChanged: (String? value) {
    setState(() {
      selectedMenuItem = value;
    });
  },
)
*/
