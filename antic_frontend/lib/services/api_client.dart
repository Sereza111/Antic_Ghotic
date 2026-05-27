import 'dart:async';

import 'package:antic_frontend/models/automation_script_summary.dart';
import 'package:antic_frontend/models/profile_summary.dart';

/// Заглушка клиентского слоя для UI.
/// На старте возвращаем мок-данные, чтобы можно было собрать интерфейс.
class ApiClient {
  final String baseUrl;

  const ApiClient({required this.baseUrl});

  // Конфиг плейсхолдера. В реальном проекте подтянем из env/настроек.
  static const defaultBaseUrl = 'http://SERVER:3000';

  Future<List<ProfileSummary>> fetchProfiles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      ProfileSummary(id: 'p1', name: 'Готика-1', description: 'Демо профиль', running: false),
      ProfileSummary(id: 'p2', name: 'Готика-2', description: 'Ещё один профиль', running: true),
    ];
  }

  Future<List<AutomationScriptSummary>> fetchScripts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      AutomationScriptSummary(id: 's1', name: 'Открыть URL', description: 'Демо сценарий'),
      AutomationScriptSummary(id: 's2', name: 'Скриншот страницы', description: 'Демо сценарий'),
    ];
  }

  Future<void> runScript({
    required String profileId,
    required String scriptId,
  }) async {
    // Пока просто имитируем запуск.
    await Future.delayed(const Duration(milliseconds: 400));
    // В будущем: POST /api/runs на удаленный backend.
  }
}

