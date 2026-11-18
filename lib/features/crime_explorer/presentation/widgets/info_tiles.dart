import 'package:flutter/material.dart';
import 'package:street_level_crime_explorer/core/theme/app_colors.dart';
import 'package:street_level_crime_explorer/core/theme/app_theme.dart'; // or app_spacing.dart

class InfoTiles extends StatelessWidget {
  const InfoTiles({super.key});

  static const _tiles = <(IconData, String, String)>[
    (
    Icons.adjust,
    'Fixed 1-mile area',
    'Counted around the middle of your postcode. The police API sets '
        'the radius.',
    ),
    (
    Icons.calendar_month_outlined,
    'Published monthly',
    'Data arrives about two months late, so the latest month is not '
        "today's.",
    ),
    (
    Icons.format_list_numbered,
    'Counts, not rates',
    'Reports only. Not a crime rate or a safety score.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About these numbers', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final tiles = [
              for (final (icon, title, body) in _tiles)
                _InfoTile(icon: icon, title: title, body: body),
            ];
            if (constraints.maxWidth < 560) {
              return Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.xs),
                    SizedBox(width: double.infinity, child: tiles[i]),
                  ],
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(child: tiles[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(body, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}