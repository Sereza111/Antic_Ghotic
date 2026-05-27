import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:antic_frontend/services/antic_paths.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalProfileLauncher {
  static final Map<String, Process> _processes = {};
  static String? _cachedRoot;

  static Future<String> _projectRoot() async {
    _cachedRoot ??= await AnticPaths.loadHome();
    return _cachedRoot!;
  }

  static bool isRunning(String profileId) => _processes.containsKey(profileId);

  static Future<String> _resolveNodeExecutable() async {
    final fromEnv = Platform.environment['ANTIC_NODE'];
    if (fromEnv != null && fromEnv.isNotEmpty && File(fromEnv).existsSync()) {
      return fromEnv;
    }

    if (Platform.isWindows) {
      try {
        final r = await Process.run('where', ['node'], runInShell: true);
        if (r.exitCode == 0) {
          final line = '${r.stdout}'.split(RegExp(r'[\r\n]')).first.trim();
          if (line.isNotEmpty && File(line).existsSync()) return line;
        }
      } catch (_) {}
      const paths = [
        r'C:\Program Files\nodejs\node.exe',
        r'C:\Program Files (x86)\nodejs\node.exe',
      ];
      for (final path in paths) {
        if (File(path).existsSync()) return path;
      }
    }

    throw StateError(
      'Node.js не найден.\n'
      '1) Установи с https://nodejs.org\n'
      '2) В папке Antic: npm install && npx playwright install chromium',
    );
  }

  static Future<void> start({
    required String profileId,
    required Map<String, dynamic> profileJson,
    required String targetUrl,
  }) async {
    if (_processes.containsKey(profileId)) {
      throw StateError('Профиль уже запущен на этом ПК');
    }

    final root = await _projectRoot();
    final envCheck = await AnticPaths.checkLocalEnv(root);
    if (!envCheck.ok) {
      throw StateError(envCheck.issues.join('\n'));
    }

    final node = envCheck.nodePath ?? await _resolveNodeExecutable();
    final scriptPath = p.join(root, 'scripts', 'local-profile-runner.js');

    final support = await getApplicationSupportDirectory();
    final profilesRoot = p.join(support.path, 'profiles');
    final profileDir = p.join(profilesRoot, profileId);
    await Directory(profileDir).create(recursive: true);

    final configPath = p.join(profileDir, 'profile.json');
    await File(configPath).writeAsString(jsonEncode(profileJson));

    final artifactsDir = p.join(support.path, 'artifacts', profileId);
    await Directory(artifactsDir).create(recursive: true);
    final logPath = p.join(profileDir, 'launcher.log');
    final logFile = File(logPath);
    await logFile.writeAsString('Starting...\n');

    final process = await Process.start(
      node,
      [scriptPath],
      workingDirectory: root,
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

    final stderrBuffer = StringBuffer();
    process.stderr.transform(utf8.decoder).listen((chunk) {
      stderrBuffer.write(chunk);
      logFile.writeAsStringSync(stderrBuffer.toString(), mode: FileMode.append);
    });
    process.stdout.transform(utf8.decoder).listen((chunk) {
      logFile.writeAsStringSync(chunk, mode: FileMode.append);
    });

    _processes[profileId] = process;

    await Future.delayed(const Duration(seconds: 3));
    int? quickExit;
    try {
      quickExit = await process.exitCode
          .timeout(const Duration(milliseconds: 50));
    } on TimeoutException {
      quickExit = null;
    }
    if (quickExit != null && quickExit != 0) {
      _processes.remove(profileId);
      final log = await logFile.readAsString();
      throw StateError(
        'Chromium не запустился (код $quickExit).\n'
        'Выполни в Antic: npm install && npx playwright install chromium\n\n$log',
      );
    }

    unawaited(process.exitCode.then((_) => _processes.remove(profileId)));
  }

  static Future<void> stop(String profileId) async {
    final proc = _processes.remove(profileId);
    if (proc == null) return;
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/PID', '${proc.pid}', '/T', '/F'], runInShell: true);
    } else {
      proc.kill(ProcessSignal.sigterm);
    }
  }
}
