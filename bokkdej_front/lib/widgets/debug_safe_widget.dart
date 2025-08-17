import 'package:flutter/material.dart';

/// Widget de debugging ultra-robuste pour traquer les erreurs null
class DebugSafeWidget extends StatelessWidget {
  final Widget Function() builder;
  final String location;
  final dynamic data;

  const DebugSafeWidget({
    Key? key,
    required this.builder,
    required this.location,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Logs plus silencieux pour éviter la pollution
      // print('[DEBUG SAFE] Construction widget à: $location');
      
      final widget = builder();
      // print('[DEBUG SAFE] ✅ Succès construction à: $location');
      return widget;
    } catch (e, stackTrace) {
      print('[DEBUG SAFE] ❌ ERREUR CRITIQUE à $location: $e');
      print('[DEBUG SAFE] Stack trace: $stackTrace');
      print('[DEBUG SAFE] Données qui ont causé l\'erreur: $data');
      
      // Widget de fallback avec informations d'erreur
      return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Erreur de rendu',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Location: $location',
              style: TextStyle(fontSize: 10, color: Colors.red[700]),
            ),
            Text(
              'Erreur: ${e.toString()}',
              style: TextStyle(fontSize: 10, color: Colors.red[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }
}

/// Extension pour wrapper facilement n'importe quel widget
extension DebugSafeExtension on Widget {
  Widget debugSafe(String location, {dynamic data}) {
    return DebugSafeWidget(
      location: location,
      data: data,
      builder: () => this,
    );
  }
}

/// Helper pour créer des Text sécurisés
class SafeText extends StatelessWidget {
  final dynamic data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String fallback;

  const SafeText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fallback = 'N/A',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      String text;
      if (data == null) {
        text = fallback;
      } else if (data is String) {
        text = data;
      } else {
        text = data.toString();
      }
      
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    } catch (e) {
      print('[SAFE TEXT] Erreur conversion: $e pour data: $data');
      return Text(
        fallback,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}

/// Helper pour accès sécurisé aux Maps
class SafeMapAccess {
  static T? get<T>(Map<String, dynamic>? map, String key, {T? fallback}) {
    try {
      if (map == null) return fallback;
      final value = map[key];
      if (value == null) return fallback;
      if (value is T) return value;
      return fallback;
    } catch (e) {
      print('[SAFE MAP] Erreur accès $key: $e');
      return fallback;
    }
  }
  
  static String getString(Map<String, dynamic>? map, String key, {String fallback = ''}) {
    try {
      final value = get<dynamic>(map, key);
      return value?.toString() ?? fallback;
    } catch (e) {
      print('[SAFE MAP] Erreur getString $key: $e');
      return fallback;
    }
  }
  
  static double getDouble(Map<String, dynamic>? map, String key, {double fallback = 0.0}) {
    try {
      final value = get<dynamic>(map, key);
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    } catch (e) {
      print('[SAFE MAP] Erreur getDouble $key: $e');
      return fallback;
    }
  }
  
  static int getInt(Map<String, dynamic>? map, String key, {int fallback = 0}) {
    try {
      final value = get<dynamic>(map, key);
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    } catch (e) {
      print('[SAFE MAP] Erreur getInt $key: $e');
      return fallback;
    }
  }
  
  static List<T> getList<T>(Map<String, dynamic>? map, String key, {List<T> fallback = const []}) {
    try {
      final value = get<dynamic>(map, key);
      if (value == null) return fallback;
      if (value is List<T>) return value;
      if (value is List) return value.cast<T>();
      return fallback;
    } catch (e) {
      print('[SAFE MAP] Erreur getList $key: $e');
      return fallback;
    }
  }
}
