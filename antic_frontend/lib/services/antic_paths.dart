import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Путь к корню репозитория Antic (где package.json и scripts/).
class AnticPaths {
  static const _keyHome = 'antic_home';

  static Future<String> loadHome() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyHome);
    if (saved != null && saved.isNotEmpty && _isValidRoot(saved)) {
      return saved;
    }
    return resolveHome();
  }

  static Future<void> saveHome(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHome, path.trim());
  }

  static bool _isValidRoot(String dir) {
    return File(p.join(dir, 'package.json')).existsSync() &&
        File(p.join(dir, 'scripts', 'local-profile-runner.js')).existsSync();
  }

  static Future<String> resolveHome() async {
    final fromEnv = Platform.environment['ANTIC_HOME'];
    if (fromEnv != null && fromEnv.isNotEmpty && _isValidRoot(fromEnv)) {
      return fromEnv;
    }

    const defaults = [
      r'C:\Users\Yozik\Desktop\Antic',
      r'C:\Antic',
    ];
    for (final d in defaults) {
      if (_isValidRoot(d)) return d;
    }

    final exeDir = File(Platform.resolvedExecutable).parent.path;
    var cursor = exeDir;
    for (var i = 0; i < 8; i++) {
      if (_isValidRoot(cursor)) return cursor;
      final parent = Directory(cursor).parent.path;
      if (parent == cursor) break;
      cursor = parent;
    }

    final desktop = p.join(
      Platform.environment['USERPROFILE'] ?? '',
      'Desktop',
      'Antic',
    );
    if (_isValidRoot(desktop)) return desktop;

    throw StateError(
      'Папка Antic не найдена.\n'
      'Открой ⚙ → укажи путь к репозиторию (где package.json).\n'
      'Или задай ANTIC_HOME в переменных Windows.',
    );
  }

  static Future<LocalEnvCheck> checkLocalEnv(String home) async {
    final issues = <String>[];
    if (!_isValidRoot(home)) {
      issues.add('Неверная папка: нет package.json или scripts/local-profile-runner.js');
      return LocalEnvCheck(ok: false, home: home, issues: issues);
    }

    String? nodePath;
    try {
      nodePath = await _findNode();
    } catch (e) {
      issues.add('$e');
    }

    final nodeModules = Directory(p.join(home, 'node_modules'));
    if (!nodeModules.existsSync()) {
      issues.add('Нет node_modules — в PowerShell: cd "$home" && npm install');
    }

    final pw = Directory(p.join(home, 'node_modules', 'playwright'));
    if (!pw.existsSync()) {
      issues.add('Playwright не установлен — npx playwright install chromium');
    }

    return LocalEnvCheck(
      ok: issues.isEmpty,
      home: home,
      nodePath: nodePath,
      issues: issues,
    );
  }

  static Future<String> _findNode() async {
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
      for (final path in [
        r'C:\Program Files\nodejs\node.exe',
        r'C:\Program Files (x86)\nodejs\node.exe',
      ]) {
        if (File(path).existsSync()) return path;
      }
    }
    throw StateError('Node.js не найден — установи с https://nodejs.org');
  }
}

class LocalEnvCheck {
  final bool ok;
  final String home;
  final String? nodePath;
  final List<String> issues;

  const LocalEnvCheck({
    required this.ok,
    required this.home,
    this.nodePath,
    this.issues = const [],
  });
}
