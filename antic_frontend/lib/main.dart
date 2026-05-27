import 'package:flutter/material.dart';

import 'package:antic_frontend/screens/automation_screen.dart';
import 'package:antic_frontend/screens/dashboard_screen.dart';
import 'package:antic_frontend/screens/profiles_screen.dart';
import 'package:antic_frontend/theme/gothic_theme.dart';
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

class _AnticHomeState extends State<AnticHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GothicBackground(
      child: Center(
        child: SizedBox(
          width: 1100,
          child: GothicPanel(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
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
                    children: const [
                      DashboardScreen(),
                      ProfilesScreen(),
                      AutomationScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

