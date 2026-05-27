import 'package:flutter/material.dart';

import 'package:antic_frontend/app_scope.dart';
import 'package:antic_frontend/models/profile_summary.dart';
import 'package:antic_frontend/screens/profile_details_screen.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/services/local_profile_launcher.dart';
import 'package:antic_frontend/widgets/gothic_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<ProfileSummary>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  void _reload() {
    final api = AppScope.of(context).api;
    setState(() {
      _future = api.fetchProfiles();
    });
  }

  Future<void> _createProfile() async {
    final api = AppScope.of(context).api;
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Новый профиль'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Имя'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    try {
      await api.createProfile(name: name);
      if (!mounted) return;
      AppScope.of(context).refreshAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Профиль создан: $name')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.message}')),
        );
      }
    }
  }

  Future<void> _toggleProfile(ProfileSummary profile) async {
    final api = AppScope.of(context).api;
    try {
      if (profile.running || LocalProfileLauncher.isRunning(profile.id)) {
        await LocalProfileLauncher.stop(profile.id);
        await api.stopProfile(profile.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Профиль остановлен: ${profile.name}')),
        );
      } else {
        final urlController = TextEditingController(text: 'https://example.com/');
        final url = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            title: Text('Запуск: ${profile.name}'),
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
        final result = await api.startProfile(profile.id, targetUrl: url);
        if (!mounted) return;

        if (result['mode'] == 'local') {
          final profileJson = Map<String, dynamic>.from(result['profile'] as Map);
          await LocalProfileLauncher.start(
            profileId: profile.id,
            profileJson: profileJson,
            targetUrl: (result['targetUrl'] as String?) ?? url,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Браузер запускается на этом ПК (Chromium + профиль).'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Сессия запущена на сервере (headless).')),
          );
        }
      }
      AppScope.of(context).refreshAll();
      _reload();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProfileSummary>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorView(
            message: snapshot.error.toString(),
            onRetry: _reload,
            onSettings: () async {
              // parent handles settings via header
            },
          );
        }

        final profiles = snapshot.data ?? const [];
        final total = profiles.length;
        final active = profiles.where((p) => p.running).length;
        final completed = total - active;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 6),
            _StatsRow(total: total, active: active, completed: completed),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickActionButton(label: 'Создать профиль', onPressed: _createProfile),
                _QuickActionButton(
                  label: 'Обновить',
                  onPressed: () {
                    AppScope.of(context).refreshAll();
                    _reload();
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('Профили', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (profiles.isEmpty)
              Text(
                'Нет профилей. Создай первый или импортируй db/antic_full.sql',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...profiles.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GothicCard(
                      borderColor: const Color(0xFF3A3A3A),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileDetailsScreen(
                              profileId: p.id,
                              initialName: p.name,
                            ),
                          ),
                        );
                      },
                      child: _ProfileCardContent(
                        profile: p,
                        onToggleRun: () => _toggleProfile(p),
                      ),
                    ),
                  )),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSettings;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Не удалось подключиться к API', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFA0A0A0))),
            const SizedBox(height: 8),
            const Text(
              'Нажми ⚙ справа сверху и укажи URL сервера (например http://IP:3010)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _QuickActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Theme.of(context).dividerColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;
  final int active;
  final int completed;
  const _StatsRow({required this.total, required this.active, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E).withValues(alpha: 153),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(number: total, label: 'Всего'),
          _StatItem(number: active, label: 'Активных'),
          _StatItem(number: completed, label: 'Завершено'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int number;
  final String label;
  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$number', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                letterSpacing: 2,
              ),
        ),
      ],
    );
  }
}

class _ProfileCardContent extends StatelessWidget {
  final ProfileSummary profile;
  final VoidCallback onToggleRun;
  const _ProfileCardContent({required this.profile, required this.onToggleRun});

  @override
  Widget build(BuildContext context) {
    final statusColor = profile.running ? Colors.white : Theme.of(context).dividerColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              if (profile.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  profile.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 14),
        TextButton(
          onPressed: onToggleRun,
          style: TextButton.styleFrom(
            foregroundColor: statusColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            side: BorderSide(color: Theme.of(context).dividerColor),
            backgroundColor: const Color(0xFF121212),
          ),
          child: Text(profile.running ? '■ Стоп' : '▶ Старт'),
        ),
      ],
    );
  }
}
