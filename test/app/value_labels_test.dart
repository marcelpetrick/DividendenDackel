import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('money uses stable tabular figures', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MoneyText(Money.parse('20', Currency.eur))),
    );

    final Text rendered = tester.widget<Text>(find.text('€20.00'));
    expect(
      rendered.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
