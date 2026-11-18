import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/domain/entities/year_month.dart';
import 'package:street_level_crime_explorer/features/crime_explorer/presentation/widgets/month_picker_dialog.dart';

void main() {
  testWidgets('disables months after the latest and returns the tapped one',
          (tester) async {
        YearMonth? picked;
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    picked = await showMonthPicker(
                      context: context,
                      selected: const YearMonth(2026, 9),
                      earliest: const YearMonth(2023, 10),
                      latest: const YearMonth(2026, 9),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ));

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        final oct = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Oct'));
        expect(oct.onSelected, isNull); // after the latest month: not selectable

        await tester.tap(find.text('Aug'));
        await tester.pumpAndSettle();
        expect(picked, const YearMonth(2026, 8));
      });
}