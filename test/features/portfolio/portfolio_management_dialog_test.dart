import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/portfolio_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows complete management actions and protects the final item', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final DateTime now = DateTime.utc(2026, 8, 23);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portfoliosProvider.overrideWith(
            (Ref ref) =>
                Stream<List<InvestmentPortfolio>>.value(<InvestmentPortfolio>[
                  InvestmentPortfolio(
                    id: InvestmentPortfolio.defaultId,
                    name: 'My portfolio',
                    createdAt: now,
                    updatedAt: now,
                  ),
                ]),
          ),
        ],
        child: const MaterialApp(home: PortfolioManagementDialog()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Manage portfolios'), findsOneWidget);
    expect(find.text('My portfolio'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('create-portfolio')),
      findsOneWidget,
    );
    expect(find.byTooltip('Rename My portfolio'), findsOneWidget);
    expect(find.byTooltip('Clear My portfolio'), findsOneWidget);
    final Finder deleteFinder = find.ancestor(
      of: find.byTooltip('The final portfolio cannot be deleted'),
      matching: find.byType(IconButton),
    );
    final IconButton delete = tester.widget<IconButton>(deleteFinder);
    expect(delete.onPressed, isNull);
  });
}
