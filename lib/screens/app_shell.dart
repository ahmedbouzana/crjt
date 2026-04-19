import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'parametres_screen.dart';
import 'employes_screen.dart';
import 'releves_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Employés'),
    (
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Relevés',
    ),
    (
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Paramètres',
    ),
  ];

  Widget _getScreen(int index) {
    return switch (index) {
      0 => const _PlaceholderScreen(title: 'Accueil'),
      1 => const EmployesScreen(),
      2 => const RelevesScreen(),
      3 => const ParametresScreen(),
      _ => const _PlaceholderScreen(title: 'Accueil'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Navigation Rail ──────────────────────────────────────────────
          Container(
            width: 200,
            color: Colors.white,
            child: Column(
              children: [
                // App header
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.border, width: 0.5),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CRJT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'Répartition des heures',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Nav items
                ..._navItems.asMap().entries.map((e) {
                  final idx = e.key;
                  final item = e.value;
                  final selected = _selectedIndex == idx;
                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = idx),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryLight
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: selected
                                ? AppTheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            size: 18,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: selected
                                  ? AppTheme.primary
                                  : const Color(0xFF444441),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // ── Vertical divider ─────────────────────────────────────────────
          const VerticalDivider(width: 0.5, color: AppTheme.border),
          // ── Content ──────────────────────────────────────────────────────
          Expanded(child: _getScreen(_selectedIndex)),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.construction_outlined,
          size: 48,
          color: AppTheme.textMuted.withOpacity(0.4),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          'En cours de développement',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    ),
  );
}
