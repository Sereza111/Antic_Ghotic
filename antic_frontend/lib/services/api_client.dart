import 'dart:convert';

import 'package:antic_frontend/models/automation_script_summary.dart';
import 'package:antic_frontend/models/profile_summary.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<void> checkHealth() async {
    final res = await _http
        .get(_uri('/health'))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw ApiException('Health failed: ${res.statusCode}', statusCode: res.statusCode);
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['ok'] != true) {
      throw ApiException('Backend not ok');
    }
    if (body['db'] != true) {
      final err = body['error']?.toString();
      if (body['version'] == null && err == null) {
        throw ApiException(
          'Старый backend без API. Portainer: rebuild stack из GitHub.',
        );
      }
      throw ApiException(
        err != null && err.isNotEmpty
            ? 'MySQL: $err\nПроверь MYSQL_HOST в Portainer (не localhost из контейнера).'
            : 'Нет связи с MySQL. Проверь env и импорт db/antic_full.sql',
      );
    }

    final profilesRes = await _http
        .get(_uri('/api/profiles'))
        .timeout(const Duration(seconds: 8));
    if (profilesRes.statusCode == 404) {
      throw ApiException(
        'Нет маршрута /api/profiles — обнови backend на сервере (git push + redeploy).',
      );
    }
    if (profilesRes.statusCode != 200) {
      throw ApiException(_errorBody(profilesRes), statusCode: profilesRes.statusCode);
    }
  }

  Future<List<ProfileSummary>> fetchProfiles() async {
    final res = await _http
        .get(_uri('/api/profiles'))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw ApiException(_errorBody(res), statusCode: res.statusCode);
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ProfileSummary(
              id: e['id'] as String,
              name: e['name'] as String,
              description: e['description'] as String?,
              running: e['running'] == true,
            ))
        .toList();
  }

  Future<ProfileSummary> createProfile({required String name, String? description}) async {
    final res = await _http
        .post(
          _uri('/api/profiles'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'description': description}),
        )
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 201) {
      throw ApiException(_errorBody(res), statusCode: res.statusCode);
    }
    final e = jsonDecode(res.body) as Map<String, dynamic>;
    return ProfileSummary(
      id: e['id'] as String,
      name: e['name'] as String,
      description: e['description'] as String?,
      running: false,
    );
  }

  Future<List<AutomationScriptSummary>> fetchScripts() async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final res = await _http
            .get(_uri('/api/scripts'))
            .timeout(const Duration(seconds: 20));
        if (res.statusCode != 200) {
          throw ApiException(_errorBody(res), statusCode: res.statusCode);
        }
        final list = jsonDecode(res.body) as List<dynamic>;
        return list
            .map((e) => AutomationScriptSummary(
                  id: e['id'] as String,
                  name: e['name'] as String,
                  description: e['description'] as String?,
                ))
            .toList();
      } catch (e) {
        lastError = e;
        await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }
    throw ApiException(lastError.toString());
  }

  Future<Map<String, dynamic>> startProfile(
    String profileId, {
    String? targetUrl,
  }) async {
    final res = await _http
        .post(
          _uri('/api/profiles/$profileId/start'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({if (targetUrl != null) 'targetUrl': targetUrl}),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw ApiException(_errorBody(res), statusCode: res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> stopProfile(String profileId) async {
    final res = await _http
        .post(
          _uri('/api/profiles/$profileId/stop'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw ApiException(_errorBody(res), statusCode: res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> runScript({
    required String profileId,
    required String scriptId,
  }) async {
    final res = await _http
        .post(
          _uri('/api/runs'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'profileId': profileId, 'scriptId': scriptId}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 201) {
      throw ApiException(_errorBody(res), statusCode: res.statusCode);
    }
  }

  String _errorBody(http.Response res) {
    try {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      return m['error']?.toString() ?? 'HTTP ${res.statusCode}';
    } catch (_) {
      return 'HTTP ${res.statusCode}: ${res.body}';
    }
  }
}
