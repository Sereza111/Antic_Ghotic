import 'package:flutter/material.dart';

import 'package:antic_frontend/app_scope.dart';
import 'package:antic_frontend/screens/automation_screen.dart';
import 'package:antic_frontend/screens/dashboard_screen.dart';
import 'package:antic_frontend/screens/profiles_screen.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/services/api_config.dart';
import 'package:antic_frontend/theme/gothic_theme.dart';
import 'package:antic_frontend/widgets/api_settings_dialog.dart';
import 'package:antic_frontend/widgets/gothic_background.dart';
import 'package:antic_frontend/widgets/gothic_panel.dart';

void main() {
  runApp(const AnticApp());
}

class AnticApp extends StatelessWidget {
  const AnticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antic',
      debugShowCheckedModeBanner: false,
      theme: buildGothicTheme(),
      home: const AnticHome(),
    );
  }
}

class AnticHome extends StatefulWidget {
  const AnticHome({super.key});

  @override
  State<AnticHome> createState() => _AnticHomeState();
}

class _AnticHomeState extends State<AnticHome> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late String _baseUrl;
  late ApiClient _api;
  int _refreshTick = 0;
  bool _loadingConfig = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final url = await ApiConfig.loadBaseUrl();
    setState(() {
      _baseUrl = url;
      _api = ApiClient(baseUrl: url);
      _loadingConfig = false;
    });
  }

  void _refreshAll() {
    setState(() => _refreshTick++);
  }

  Future<void> _openSettings() async {
    final newUrl = await showDialog<String>(
      context: context,
      builder: (_) => ApiSettingsDialog(initialUrl: _baseUrl),
    );
    if (newUrl == null || newUrl.isEmpty) return;
    setState(() {
      _baseUrl = newUrl;
      _api = ApiClient(baseUrl: newUrl);
      _refreshTick++;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingConfig) {
      return const GothicBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScope(
      api: _api,
      baseUrl: _baseUrl,
      refreshAll: _refreshAll,
      child: GothicBackground(
        child: Center(
          child: SizedBox(
            width: 1100,
            child: GothicPanel(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(baseUrl: _baseUrl, onSettings: _openSettings),
                  const SizedBox(height: 14),
                  TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'Profiles'),
                      Tab(text: 'Automation'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        DashboardScreen(key: ValueKey('dash-$_refreshTick')),
                        ProfilesScreen(key: ValueKey('prof-$_refreshTick')),
                        AutomationScreen(key: ValueKey('auto-$_refreshTick')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String baseUrl;
  final VoidCallback onSettings;

  const _Header({required this.baseUrl, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            IconButton(
              tooltip: 'Настройки API',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined, color: Color(0xFFA0A0A0)),
            ),
          ],
        ),
        Text(
          '⚜ ANTIC CODEX ⚜',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'API: $baseUrl',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Профили • Изоляция • Автоматизация',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Theme.of(context).dividerColor,
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
