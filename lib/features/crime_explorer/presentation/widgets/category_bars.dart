import 'package:flutter/material.dart';
import 'package:street_level_crime_explorer/core/utils/format.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/category_count.dart';
import 'package:street_level_crime_explorer/core/theme/app_colors.dart';
import 'package:street_level_crime_explorer/core/theme/app_typography.dart';

/// Custom horizontal bars. The highest category is full width.
class CategoryBars extends StatelessWidget {
  const CategoryBars({super.key, required this.categories});

  final List<CategoryCount> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final biggest = categories.first.count;

    return Column(
      children: [
        for (final c in categories)
          Semantics(
            container: true,
            excludeSemantics: true,
            label: '${prettyCategory(c.category)}: '
                '${formatCount(c.count)} incidents',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(prettyCategory(c.category))),
                      Text(
                        formatCount(c.count),
                        style: AppTypography.bodyBold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          color: const Color(0xFFE5E7EB),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: (c.count / biggest).clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, factor, _) => FractionallySizedBox(
                            widthFactor: factor,
                            child: Container(height: 10, color: AppColors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}