import 'package:flutter/material.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';

/// Returns the chosen month, or null if the user cancels.
Future<YearMonth?> showMonthPicker({
  required BuildContext context,
  required YearMonth selected,
  required YearMonth earliest,
  required YearMonth latest,
}) {
  return showDialog<YearMonth>(
    context: context,
    builder: (_) => _MonthPickerDialog(
      selected: selected,
      earliest: earliest,
      latest: latest,
    ),
  );
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({
    required this.selected,
    required this.earliest,
    required this.latest,
  });

  final YearMonth selected;
  final YearMonth earliest;
  final YearMonth latest;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year = widget.selected.year;

  bool _isAvailable(YearMonth m) =>
      m.compareTo(widget.earliest) >= 0 && m.compareTo(widget.latest) <= 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Previous year',
                    onPressed: _year > widget.earliest.year
                        ? () => setState(() => _year--)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$_year', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    tooltip: 'Next year',
                    onPressed: _year < widget.latest.year
                        ? () => setState(() => _year++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var m = 1; m <= 12; m++) _monthChip(YearMonth(_year, m)),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthChip(YearMonth m) {
    return SizedBox(
      width: 88,
      child: ChoiceChip(
        showCheckmark: false,
        selected: m == widget.selected,
        onSelected: _isAvailable(m) ? (_) => Navigator.pop(context, m) : null,
        label: SizedBox(
          width: double.infinity,
          child: Text(m.shortLabel, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}