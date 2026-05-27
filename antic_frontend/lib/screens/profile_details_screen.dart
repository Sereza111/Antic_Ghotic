import 'package:flutter/material.dart';

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

  // Простейшие переключатели модулей (плейсхолдер для будущего persistence).
  bool canvasEnabled = true;
  bool webglEnabled = true;
  bool webrtcEnabled = false;
  bool fontsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialName ?? widget.profileId;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Browser'),
            Tab(text: 'Fingerprint'),
            Tab(text: 'Automation'),
          ],
          isScrollable: false,
          indicatorColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(profileId: widget.profileId),
          const _BrowserTab(),
          _FingerprintTab(
            canvasEnabled: canvasEnabled,
            webglEnabled: webglEnabled,
            webrtcEnabled: webrtcEnabled,
            fontsEnabled: fontsEnabled,
            onChangedCanvas: (v) => setState(() => canvasEnabled = v),
            onChangedWebGL: (v) => setState(() => webglEnabled = v),
            onChangedWebRTC: (v) => setState(() => webrtcEnabled = v),
            onChangedFonts: (v) => setState(() => fontsEnabled = v),
          ),
          const _AutomationTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String profileId;
  const _OverviewTab({required this.profileId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 6),
        Text(
          'ID профиля: $profileId',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 18),
        Text(
          'Здесь будут отображаться базовые параметры профиля (user-agent, язык, экран, timezone и т.п.)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _BrowserTab extends StatelessWidget {
  const _BrowserTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Browser',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 14),
        _FieldPlaceholder(label: 'Engine', value: 'chromium (demo)'),
        _FieldPlaceholder(label: 'OS', value: 'windows (demo)'),
        _FieldPlaceholder(label: 'Screen', value: '1280x720 (demo)'),
      ],
    );
  }
}

class _FieldPlaceholder extends StatelessWidget {
  final String label;
  final String value;
  const _FieldPlaceholder({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        color: const Color(0xFF0F0F0F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _FingerprintTab extends StatelessWidget {
  final bool canvasEnabled;
  final bool webglEnabled;
  final bool webrtcEnabled;
  final bool fontsEnabled;

  final ValueChanged<bool> onChangedCanvas;
  final ValueChanged<bool> onChangedWebGL;
  final ValueChanged<bool> onChangedWebRTC;
  final ValueChanged<bool> onChangedFonts;

  const _FingerprintTab({
    required this.canvasEnabled,
    required this.webglEnabled,
    required this.webrtcEnabled,
    required this.fontsEnabled,
    required this.onChangedCanvas,
    required this.onChangedWebGL,
    required this.onChangedWebRTC,
    required this.onChangedFonts,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Модули fingerprint (demo)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _SwitchRow(
          title: 'Canvas',
          subtitle: 'mode: original/noise/spoof (плейсхолдер)',
          value: canvasEnabled,
          onChanged: onChangedCanvas,
        ),
        _SwitchRow(
          title: 'WebGL',
          subtitle: 'mode: original/noise/spoof (плейсхолдер)',
          value: webglEnabled,
          onChanged: onChangedWebGL,
        ),
        _SwitchRow(
          title: 'WebRTC',
          subtitle: 'mode: disabled/limited (плейсхолдер)',
          value: webrtcEnabled,
          onChanged: onChangedWebRTC,
        ),
        _SwitchRow(
          title: 'Fonts',
          subtitle: 'enabled + fontSetId (плейсхолдер)',
          value: fontsEnabled,
          onChanged: onChangedFonts,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        color: const Color(0xFF0F0F0F),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _AutomationTab extends StatelessWidget {
  const _AutomationTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Automation',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 14),
        Text(
          'Здесь будет выбор сценариев и запуск на сервере (docker-контейнер под профиль) через API.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

