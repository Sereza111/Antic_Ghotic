import 'package:flutter/material.dart';

import 'package:antic_frontend/models/profile_summary.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/screens/profile_details_screen.dart';
import 'package:antic_frontend/widgets/gothic_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const api = ApiClient(baseUrl: ApiClient.defaultBaseUrl);

    return FutureBuilder<List<ProfileSummary>>(
      future: api.fetchProfiles(),
      builder: (context, snapshot) {
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
                _QuickActionButton(
                  label: 'Создать профиль',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пока заглушка UI')),
                    );
                  },
                ),
                _QuickActionButton(
                  label: 'Запустить все',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пока заглушка UI')),
                    );
                  },
                ),
                _QuickActionButton(
                  label: 'Остановить все',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пока заглушка UI')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Профили',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else
              ...profiles.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GothicCard(
                      borderColor: const Color(0xFF3A3A3A),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileDetailsScreen(profileId: p.id),
                          ),
                        );
                      },
                      child: _ProfileCardContent(profile: p),
                    ),
                  )),
            const SizedBox(height: 10),
          ],
        );
      },
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
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;
  final int active;
  final int completed;
  const _StatsRow({
    required this.total,
    required this.active,
    required this.completed,
  });

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
        Text(
          '$number',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
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
  const _ProfileCardContent({required this.profile});

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
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            color: const Color(0xFF121212),
          ),
          child: Text(
            profile.running ? 'RUNNING' : 'STOPPED',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: statusColor,
                ),
          ),
        ),
      ],
    );
  }
}

