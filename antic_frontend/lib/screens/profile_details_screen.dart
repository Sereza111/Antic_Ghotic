import 'package:flutter/material.dart';

import 'package:antic_frontend/app_scope.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/services/local_profile_launcher.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String profileId;
  final String? initialName;

  const ProfileDetailsScreen({
    super.key,
    required this.profileId,
    this.initialName,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AppScope.of(context).api.fetchProfile(widget.profileId);
      if (!mounted) return;
      setState(() {
        _profile = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Map<String, dynamic> get _fp =>
      Map<String, dynamic>.from(_profile?['fingerprint'] as Map? ?? {});

  Future<void> _saveFingerprint() async {
    setState(() => _saving = true);
    try {
      final updated = await AppScope.of(context).api.updateProfile(widget.profileId, {
        'fingerprint': _fp,
      });
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint сохранён')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _launchBrowser() async {
    if (_profile == null) return;
    final urlController = TextEditingController(text: 'https://example.com/');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Запуск браузера на этом ПК'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: 'URL'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, urlController.text.trim()),
            child: const Text('Запустить'),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;

    try {
      final api = AppScope.of(context).api;
      final result = await api.startProfile(widget.profileId, targetUrl: url);
      if (result['mode'] == 'local') {
        await LocalProfileLauncher.start(
          profileId: widget.profileId,
          profileJson: Map<String, dynamic>.from(result['profile'] as Map),
          targetUrl: (result['targetUrl'] as String?) ?? url,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chromium открыт на этом компьютере')),
      );
      AppScope.of(context).refreshAll();
      _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), duration: const Duration(seconds: 8)),
        );
      }
    }
  }

  Future<void> _stopBrowser() async {
    try {
      await LocalProfileLauncher.stop(widget.profileId);
      await AppScope.of(context).api.stopProfile(widget.profileId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Остановлено')));
      AppScope.of(context).refreshAll();
      _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _setModuleMode(String module, String mode) {
    setState(() {
      _fp[module] = {...Map<String, dynamic>.from(_fp[module] as Map? ?? {}), 'mode': mode};
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _profile?['name']?.toString() ?? widget.initialName ?? widget.profileId;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0A0A0A),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Browser'),
            Tab(text: 'Fingerprint'),
            Tab(text: 'Automation'),
          ],
          indicatorColor: Colors.white54,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _overviewTab(),
                    _browserTab(),
                    _fingerprintTab(),
                    _automationTab(),
                  ],
                ),
    );
  }

  Widget _overviewTab() {
    final nav = _fp['navigator'] as Map? ?? {};
    final screen = _fp['screen'] as Map? ?? {};
    final tz = _fp['timezone'] as Map? ?? {};
    final running = LocalProfileLauncher.isRunning(widget.profileId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('ID: ${widget.profileId}', style: const TextStyle(color: Color(0xFFA0A0A0))),
        const SizedBox(height: 16),
        _info('User-Agent', nav['userAgent']?.toString() ?? '—'),
        _info('Экран', '${screen['width'] ?? '?'}×${screen['height'] ?? '?'}'),
        _info('Timezone', tz['tzIanaName']?.toString() ?? '—'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: running ? null : _launchBrowser,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Запустить на этом ПК'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: running ? _stopBrowser : null,
                icon: const Icon(Icons.stop),
                label: const Text('Стоп'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          running ? 'Статус: RUNNING (локально)' : 'Статус: STOPPED',
          style: TextStyle(color: running ? Colors.white : const Color(0xFF808080)),
        ),
      ],
    );
  }

  Widget _browserTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _info('Engine', _profile?['browserEngine']?.toString() ?? 'chromium'),
        _info('OS', _profile?['osFamily']?.toString() ?? 'windows'),
      ],
    );
  }

  Widget _fingerprintTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _modeRow('Canvas', _fp['canvas']?['mode']?.toString() ?? 'original', 'canvas'),
        _modeRow('WebGL', _fp['webgl']?['mode']?.toString() ?? 'original', 'webgl'),
        _modeRow('WebRTC', _fp['webrtc']?['mode']?.toString() ?? 'disabled', 'webrtc'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _saveFingerprint,
          child: Text(_saving ? 'Сохранение...' : 'Сохранить fingerprint'),
        ),
      ],
    );
  }

  Widget _automationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Вкладка Automation на главном экране — запуск сценариев.'),
        SizedBox(height: 8),
        Text('После выбора сценария браузер откроется на этом ПК.', style: TextStyle(color: Color(0xFFA0A0A0))),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF808080), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _modeRow(String title, String current, String module) {
    const modes = ['original', 'noise', 'spoof', 'disabled', 'limited'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: modes.map((m) {
              final selected = current == m;
              return ChoiceChip(
                label: Text(m),
                selected: selected,
                onSelected: (_) => _setModuleMode(module, m),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
