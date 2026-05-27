import 'package:flutter/material.dart';

import 'package:antic_frontend/models/profile_summary.dart';
import 'package:antic_frontend/screens/profile_details_screen.dart';
import 'package:antic_frontend/services/api_client.dart';
import 'package:antic_frontend/widgets/gothic_card.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const api = ApiClient(baseUrl: ApiClient.defaultBaseUrl);

    return FutureBuilder<List<ProfileSummary>>(
      future: api.fetchProfiles(),
      builder: (context, snapshot) {
        final profiles = snapshot.data ?? const [];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Профили',
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
              ...profiles.map(
                (p) => Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
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
                    child: _ProfileListItem(profile: p),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  final ProfileSummary profile;
  const _ProfileListItem({required this.profile});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 6),
              if (profile.description != null)
                Text(
                  profile.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            color: const Color(0xFF121212),
          ),
          child: Text(
            profile.running ? 'RUNNING' : 'STOPPED',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: profile.running ? Colors.white : Theme.of(context).dividerColor,
                ),
          ),
        ),
      ],
    );
  }
}

