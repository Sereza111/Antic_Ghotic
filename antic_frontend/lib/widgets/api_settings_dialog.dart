import 'package:flutter/material.dart';

import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/services/api_config.dart';
import 'package:antic_frontend/services/antic_paths.dart';

class ApiSettingsDialog extends StatefulWidget {
  final String initialUrl;
  const ApiSettingsDialog({super.key, required this.initialUrl});

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _homeController;
  String? _apiStatus;
  String? _localStatus;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl);
    _homeController = TextEditingController();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final home = await AnticPaths.loadHome();
      if (mounted) _homeController.text = home;
    } catch (_) {}
  }

  @override
  void dispose() {
    _urlController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  Future<void> _testApi() async {
    setState(() {
      _busy = true;
      _apiStatus = null;
    });
    try {
      final client = ApiClient(baseUrl: _urlController.text.trim());
      await client.checkHealth();
      setState(() => _apiStatus = 'OK: API и MySQL доступны');
    } catch (e) {
      setState(() => _apiStatus = 'Ошибка: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _testLocal() async {
    setState(() {
      _busy = true;
      _localStatus = null;
    });
    try {
      final home = _homeController.text.trim();
      final check = await AnticPaths.checkLocalEnv(home);
      if (check.ok) {
        setState(() => _localStatus = 'OK: Node + Playwright\n${check.home}');
      } else {
        setState(() => _localStatus = check.issues.join('\n'));
      }
    } catch (e) {
      setState(() => _localStatus = '$e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111111),
      title: const Text('Настройки Antic'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('API сервера (Portainer)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'http://obtefaluyut.beget.app:3010',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_apiStatus != null) ...[
                const SizedBox(height: 8),
                Text(_apiStatus!, style: const TextStyle(fontSize: 13)),
              ],
              TextButton(onPressed: _busy ? null : _testApi, child: const Text('Проверить API')),
              const Divider(height: 28),
              const Text('Папка Antic на этом ПК', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text(
                'Где лежат package.json и scripts/. Нужно для запуска Chromium.',
                style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _homeController,
                decoration: const InputDecoration(
                  labelText: 'Путь к Antic',
                  hintText: r'C:\Users\...\Desktop\Antic',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_localStatus != null) ...[
                const SizedBox(height: 8),
                Text(_localStatus!, style: const TextStyle(fontSize: 13)),
              ],
              TextButton(onPressed: _busy ? null : _testLocal, child: const Text('Проверить Node / Playwright')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  await ApiConfig.saveBaseUrl(_urlController.text);
                  final home = _homeController.text.trim();
                  if (home.isNotEmpty) await AnticPaths.saveHome(home);
                  if (context.mounted) Navigator.pop(context, _urlController.text.trim());
                },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
