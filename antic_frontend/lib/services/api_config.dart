import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const _keyBaseUrl = 'api_base_url';
  /// Адрес backend на сервере (Portainer: порт BACKEND_PORT, обычно 3010).
  static const defaultBaseUrl = 'http://obtefaluyut.beget.app:3010';

  static Future<String> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl) ?? defaultBaseUrl;
  }

  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = url.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setString(_keyBaseUrl, normalized);
  }
}
