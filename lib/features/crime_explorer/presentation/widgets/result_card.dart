import 'package:flutter/material.dart';
import 'package:street_level_crime_explorer/core/theme/app_colors.dart';
import 'package:street_level_crime_explorer/core/theme/app_theme.dart';
import 'package:street_level_crime_explorer/core/utils/format.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/incident_summary.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/widgets/category_bars.dart';

/// Plain-words comparison with the previous month. Never says good or bad.
String comparisonText(IncidentSummary summary) {
  final previous = summary.previous;
  if (previous == null) {
    return 'Comparison with the previous month could not be loaded.';
  }
  final label = YearMonth.tryParse(previous.month)?.label ?? previous.month;
  final change = summary.changePercent;
  if (change == null) return 'No comparison available for $label.';
  final rounded = change.abs().toStringAsFixed(1);
  if (rounded == '0.0') return 'About the same as $label';
  return '$rounded% ${change < 0 ? 'lower' : 'higher'} than $label';
}

class ResultsCard extends StatelessWidget {
  const ResultsCard({super.key, required this.summary});

  final IncidentSummary summary;

  IconData get _changeIcon {
    final change = summary.changePercent;
    if (change == null || change.abs() < 0.05) return Icons.remove;
    return change < 0 ? Icons.arrow_downward : Icons.arrow_upward;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTotalCard(context),
        const SizedBox(height: AppSpacing.sm),
        _buildChangeCard(context),
        const SizedBox(height: AppSpacing.sm),
        _buildChartCard(context),
        const SizedBox(height: AppSpacing.sm),
        _buildDisclaimer(context),
      ],
    );
  }

  Widget _iconLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.teal),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    final theme = Theme.of(context);
    final month = YearMonth.tryParse(summary.current.month);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatCount(summary.current.total),
              style: theme.textTheme.displayMedium?.copyWith(color: AppColors.navy),
            ),
            Text(
              'incidents reported',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _iconLabel(
              Icons.location_on_outlined,
              'Within 1 mile of ${summary.location.postcode}',
            ),
            const SizedBox(height: AppSpacing.xs),
            _iconLabel(
              Icons.calendar_month_outlined,
              month?.label ?? summary.current.month,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_changeIcon, color: AppColors.teal),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compared with previous month',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    comparisonText(summary),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.teal),
                const SizedBox(width: AppSpacing.xs),
                Text('Top categories', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Largest first', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            CategoryBars(categories: summary.topCategories),
            if (summary.otherCategoryCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '+ ${summary.otherCategoryCount} other categories: '
                    '${formatCount(summary.otherIncidentCount)} incidents',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Street-level incidents reported to police, within '
                  '1-mile radius. This is a count of reports, not a crime rate '
                  'or a safety measure.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}