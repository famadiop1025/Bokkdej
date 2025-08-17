import 'package:flutter/material.dart';

class SafeDropdownWidget<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final bool isExpanded;
  final Widget? underline;

  const SafeDropdownWidget({
    Key? key,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.isExpanded = false,
    this.underline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Vérifier que la valeur sélectionnée existe dans les items
      final validValue = items.any((item) => item.value == value) ? value : null;
      
      // Éliminer les doublons potentiels
      final uniqueItems = <T, DropdownMenuItem<T>>{};
      for (final item in items) {
        if (item.value != null) {
          uniqueItems[item.value as T] = item;
        }
      }
      
      if (uniqueItems.isEmpty) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(hint ?? 'Aucune option disponible'),
        );
      }

      return DropdownButton<T>(
        value: validValue,
        hint: hint != null ? Text(hint!) : null,
        isExpanded: isExpanded,
        underline: underline ?? SizedBox(),
        items: uniqueItems.values.toList(),
        onChanged: onChanged,
      );
    } catch (e) {
      // En cas d'erreur, retourner un widget de fallback
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Erreur dropdown: ${e.toString()}',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}
