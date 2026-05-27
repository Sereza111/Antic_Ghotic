import 'package:flutter/material.dart';

import 'package:antic_frontend/app_scope.dart';
import 'package:antic_frontend/models/automation_script_summary.dart';
import 'package:antic_frontend/models/profile_summary.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/widgets/gothic_card.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  late Future<({List<AutomationScriptSummary> scripts, List<ProfileSummary> profiles})> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = AppScope.of(context).api;
    _future = () async {
      final scripts = await api.fetchScripts();
      final profiles = await api.fetchProfiles();
      return (scripts: scripts, profiles: profiles);
    }();
  }

  Future<void> _run(AutomationScriptSummary script, List<ProfileSummary> profiles) async {
    final api = AppScope.of(context).api;
    if (profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала создай профиль')),
      );
      return;
    }

    final profile = profiles.length == 1
        ? profiles.first
        : await showDialog<ProfileSummary>(
            context: context,
            builder: (ctx) => SimpleDialog(
              backgroundColor: const Color(0xFF111111),
              title: const Text('Выбери профиль'),
              children: profiles
                  .map((p) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(ctx, p),
                        child: Text(p.name),
                      ))
                  .toList(),
            ),
          );

    if (profile == null) return;

    try {
      await api.runScript(profileId: profile.id, scriptId: script.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Запуск записан: ${script.name} → ${profile.name}')),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({List<AutomationScriptSummary> scripts, List<ProfileSummary> profiles})>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        final data = snapshot.data;
        final scripts = data?.scripts ?? const [];
        final profiles = data?.profiles ?? const [];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 6),
            Text('Automation', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else
              ...scripts.map((s) => Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                    child: GothicCard(
                      borderColor: const Color(0xFF3A3A3A),
                      onTap: () => _run(s, profiles),
                      child: _ScriptCardContent(script: s),
                    ),
                  )),
          ],
        );
      },
    );
  }
}

class _ScriptCardContent extends StatelessWidget {
  final AutomationScriptSummary script;
  const _ScriptCardContent({required this.script});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(script.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (script.description != null)
          Text(
            script.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Run →',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, letterSpacing: 2),
          ),
        ),
      ],
    );
  }
}
