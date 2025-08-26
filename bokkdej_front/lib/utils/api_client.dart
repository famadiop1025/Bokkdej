import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String getApiBaseUrl() => 'http://localhost:8000';

class ApiClient {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  static Future<void> saveTokens({required String access, String? refresh}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    if (refresh != null && refresh.isNotEmpty) {
      await prefs.setString(_kRefresh, refresh);
    }
  }

  static Future<String?> _getAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccess);
  }

  static Future<String?> getAccessToken() async {
    return _getAccess();
  }

  static Future<String?> _getRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefresh);
  }

  static Future<bool> _refreshAccess() async {
    final refresh = await _getRefresh();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final resp = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refresh}),
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final access = (data['access'] ?? data['token'])?.toString();
        if (access != null && access.isNotEmpty) {
          await saveTokens(access: access, refresh: refresh);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  static Future<http.Response> get(Uri uri, {String? fallbackToken}) async {
    return _send('GET', uri, fallbackToken: fallbackToken);
  }

  static Future<http.Response> post(Uri uri, {Object? body, Map<String, String>? headers, String? fallbackToken}) async {
    return _send('POST', uri, body: body, headers: headers, fallbackToken: fallbackToken);
  }

  static Future<http.Response> put(Uri uri, {Object? body, Map<String, String>? headers, String? fallbackToken}) async {
    return _send('PUT', uri, body: body, headers: headers, fallbackToken: fallbackToken);
  }

  static Future<http.Response> delete(Uri uri, {String? fallbackToken}) async {
    return _send('DELETE', uri, fallbackToken: fallbackToken);
  }

  static Future<http.StreamedResponse> sendMultipart(http.MultipartRequest req, {String? fallbackToken}) async {
    final token = await _getAccess() ?? fallbackToken;
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    var resp = await req.send();
    if (resp.statusCode == 401) {
      final ok = await _refreshAccess();
      if (ok) {
        final newToken = await _getAccess();
        if (newToken != null) req.headers['Authorization'] = 'Bearer $newToken';
        resp = await req.send();
      }
    }
    return resp;
  }

  static Future<http.Response> _send(String method, Uri uri, {Object? body, Map<String, String>? headers, String? fallbackToken}) async {
    final token = await _getAccess() ?? fallbackToken;
    final hdrs = <String, String>{'Content-Type': 'application/json', if (headers != null) ...headers};
    if (token != null && token.isNotEmpty) hdrs['Authorization'] = 'Bearer $token';

    http.Response resp;
    switch (method) {
      case 'POST':
        resp = await http.post(uri, headers: hdrs, body: body);
        break;
      case 'PUT':
        resp = await http.put(uri, headers: hdrs, body: body);
        break;
      case 'DELETE':
        resp = await http.delete(uri, headers: hdrs);
        break;
      default:
        resp = await http.get(uri, headers: hdrs);
    }
    if (resp.statusCode == 401) {
      final ok = await _refreshAccess();
      if (ok) {
        final newToken = await _getAccess();
        if (newToken != null) hdrs['Authorization'] = 'Bearer $newToken';
        switch (method) {
          case 'POST':
            return await http.post(uri, headers: hdrs, body: body);
          case 'PUT':
            return await http.put(uri, headers: hdrs, body: body);
          case 'DELETE':
            return await http.delete(uri, headers: hdrs);
          default:
            return await http.get(uri, headers: hdrs);
        }
      }
    }
    return resp;
  }
}


