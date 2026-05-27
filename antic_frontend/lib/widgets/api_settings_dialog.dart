import 'package:flutter/material.dart';

import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/services/api_config.dart';

class ApiSettingsDialog extends StatefulWidget {
  final String initialUrl;
  const ApiSettingsDialog({super.key, required this.initialUrl});

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  late final TextEditingController _controller;
  String? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final client = ApiClient(baseUrl: _controller.text.trim());
      await client.checkHealth();
      setState(() => _status = 'OK: сервер отвечает');
    } catch (e) {
      setState(() => _status = 'Ошибка: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111111),
      title: const Text('Адрес API сервера'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Пример: http://93.189.230.198:3010\n'
              'После обновления backend /health должен быть: {"ok":true,"db":true}',
              style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(),
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 10),
              Text(_status!, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Отмена')),
        TextButton(onPressed: _busy ? null : _test, child: const Text('Проверить')),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  await ApiConfig.saveBaseUrl(_controller.text);
                  if (context.mounted) Navigator.pop(context, _controller.text.trim());
                },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
