import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/research/research_screen.dart';
import 'package:dividendendackel/features/research/research_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Instrument allianz = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    mic: 'XETR',
    sector: 'Financials',
  );
  const Instrument munichRe = Instrument(
    internalId: 'isin:DE0008430026',
    symbol: 'MUV2',
    name: 'Munich Re',
    currency: Currency.eur,
    mic: 'XETR',
    sector: 'Financials',
  );
  final DateTime now = DateTime.utc(2026, 9, 14, 12);
  ScoredAssessment assessment(int score, String summary) => ScoredAssessment(
    score: score,
    summary: summary,
    factors: <ScoreFactor>[
      ScoreFactor(label: summary, impact: FactorImpact.neutral),
    ],
  );
  final ResearchSnapshot snapshot = ResearchSnapshot(
    instrumentId: allianz.internalId,
    takenAt: now,
    overall: assessment(67, 'Available evidence is mixed.'),
    dimensions: <ResearchDimension, ScoredAssessment>{
      ResearchDimension.dividend: assessment(
        80,
        'Dividend evidence is strong.',
      ),
      ResearchDimension.eventRisk: assessment(40, 'Event risk is elevated.'),
    },
    provenance: Provenance(source: 'test', fetchedAt: now),
  );

  Future<void> pumpResearch(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              const <String, Instrument>{
                'isin:DE0008404005': allianz,
                'isin:DE0008430026': munichRe,
              },
            ),
          ),
          currentResearchSnapshotProvider.overrideWith(
            (Ref ref, String id) async =>
                id == allianz.internalId ? snapshot : null,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ResearchScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('previews scores and evidence without inventing missing values', (
    WidgetTester tester,
  ) async {
    await pumpResearch(tester, const Size(1000, 800));

    expect(find.text('Evidence-led research'), findsOneWidget);
    expect(find.text('67 / 100'), findsOneWidget);
    expect(find.text('2 of 6 dimensions'), findsOneWidget);
    expect(find.text('Dividend'), findsOneWidget);
    expect(find.text('Event risk'), findsOneWidget);
    expect(find.text('Not enough cached evidence'), findsOneWidget);
    expect(find.text('0 / 100'), findsNothing);

    final Offset allianzPosition = tester.getTopLeft(
      find.byKey(const ValueKey<String>('research-card-isin:DE0008404005')),
    );
    final Offset munichRePosition = tester.getTopLeft(
      find.byKey(const ValueKey<String>('research-card-isin:DE0008430026')),
    );
    expect(allianzPosition.dx, lessThan(munichRePosition.dx));
    expect(allianzPosition.dy, munichRePosition.dy);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapses the research grid to one column on a phone', (
    WidgetTester tester,
  ) async {
    await pumpResearch(tester, const Size(400, 800));

    final Offset allianzPosition = tester.getTopLeft(
      find.byKey(const ValueKey<String>('research-card-isin:DE0008404005')),
    );
    final Offset munichRePosition = tester.getTopLeft(
      find.byKey(const ValueKey<String>('research-card-isin:DE0008430026')),
    );
    expect(allianzPosition.dx, munichRePosition.dx);
    expect(allianzPosition.dy, lessThan(munichRePosition.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('research cards remain usable at large text scale', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpResearch(tester, const Size(400, 800));
    await tester.drag(
      find.byKey(const ValueKey<String>('research-card-grid')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('67 / 100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('starts assessments only for visible research cards', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final Map<String, Instrument> instruments = <String, Instrument>{
      for (int index = 0; index < 100; index++)
        'instrument-$index': Instrument(
          internalId: 'instrument-$index',
          symbol: 'S$index',
          name: 'Instrument $index',
          currency: Currency.eur,
        ),
    };
    var assessmentsStarted = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(instruments),
          ),
          currentResearchSnapshotProvider.overrideWith((Ref ref, String id) {
            assessmentsStarted++;
            return Future<ResearchSnapshot?>.value();
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: ResearchScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(assessmentsStarted, greaterThan(0));
    expect(assessmentsStarted, lessThan(instruments.length));
    expect(tester.takeException(), isNull);
  });
}
