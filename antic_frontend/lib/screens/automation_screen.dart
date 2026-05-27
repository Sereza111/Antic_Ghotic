import 'package:flutter/material.dart';

import 'package:antic_frontend/models/automation_script_summary.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/widgets/gothic_card.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const api = ApiClient(baseUrl: ApiClient.defaultBaseUrl);

    return FutureBuilder<List<AutomationScriptSummary>>(
      future: api.fetchScripts(),
      builder: (context, snapshot) {
        final scripts = snapshot.data ?? const [];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Automation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ...scripts.map((s) => Padding(
                    padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                    child: GothicCard(
                      borderColor: const Color(0xFF3A3A3A),
                      onTap: () async {
                        // В UI пока нет выбора profile — используем demo.
                        await api.runScript(profileId: 'p1', scriptId: s.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Запуск: ${s.name}')),
                          );
                        }
                      },
                      child: _ScriptCardContent(script: s),
                    ),
                  )),
            const SizedBox(height: 10),
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
        Text(
          script.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
          ),
        ),
      ],
    );
  }
}

