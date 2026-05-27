import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Запуск Chromium на этом ПК через Node + Playwright (скрипт в корне Antic).
class LocalProfileLauncher {
  static final Map<String, Process> _processes = {};

  /// Папка репозитория Antic (где лежит scripts/local-profile-runner.js).
  static String get projectRoot {
    final fromEnv = Platform.environment['ANTIC_HOME'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return r'C:\Users\Yozik\Desktop\Antic';
  }

  static bool isRunning(String profileId) => _processes.containsKey(profileId);

  static Future<void> start({
    required String profileId,
    required Map<String, dynamic> profileJson,
    required String targetUrl,
  }) async {
    if (_processes.containsKey(profileId)) {
      throw StateError('Профиль уже запущен локально');
    }

    final scriptPath = p.join(projectRoot, 'scripts', 'local-profile-runner.js');
    if (!File(scriptPath).existsSync()) {
      throw StateError(
        'Не найден $scriptPath\n'
        'Укажи ANTIC_HOME или положи проект в $projectRoot',
      );
    }

    final support = await getApplicationSupportDirectory();
    final profilesRoot = p.join(support.path, 'profiles');
    final profileDir = p.join(profilesRoot, profileId);
    await Directory(profileDir).create(recursive: true);

    final configPath = p.join(profileDir, 'profile.json');
    await File(configPath).writeAsString(jsonEncode(profileJson));

    final artifactsDir = p.join(support.path, 'artifacts', profileId);
    await Directory(artifactsDir).create(recursive: true);

    final process = await Process.start(
      'node',
      [scriptPath],
      environment: {
        'PROFILE_ID': profileId,
        'PROFILE_CONFIG_PATH': configPath,
        'TARGET_URL': targetUrl,
        'PROFILES_DIR': profilesRoot,
        'ARTIFACTS_DIR': artifactsDir,
        'HEADLESS': 'false',
        'KEEP_ALIVE_SECONDS': '0',
      },
    );

    _processes[profileId] = process;
    process.exitCode.whenComplete(() => _processes.remove(profileId));
  }

  static Future<void> stop(String profileId) async {
    final proc = _processes.remove(profileId);
    if (proc == null) return;
    proc.kill(ProcessSignal.sigterm);
  }
}
