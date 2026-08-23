import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/dividend_event.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 22);
  final Provenance provenance = Provenance(source: 'fmp', fetchedAt: now);

  DividendEvent eventWith({
    DividendStatus status = DividendStatus.confirmed,
    DateTime? exDate,
    DateTime? paymentDate,
  }) => DividendEvent(
    instrumentId: 'isin:DE0008404005',
    amountPerShare: Money.parse('13.80', Currency.eur),
    status: status,
    exDate: exDate,
    paymentDate: paymentDate,
    provenance: provenance,
  );

  group('DividendStatus', () {
    test('covers every status the vision names', () {
      expect(DividendStatus.values, <DividendStatus>[
        DividendStatus.confirmed,
        DividendStatus.announced,
        DividendStatus.expected,
        DividendStatus.historicallyEstimated,
        DividendStatus.unknown,
      ]);
    });

    test('separates reported facts from estimates', () {
      expect(DividendStatus.confirmed.isEstimate, isFalse);
      expect(DividendStatus.announced.isEstimate, isFalse);
      expect(DividendStatus.expected.isEstimate, isTrue);
      expect(DividendStatus.historicallyEstimated.isEstimate, isTrue);
      expect(DividendStatus.unknown.isEstimate, isTrue);
    });

    test('identifies what the company itself stated', () {
      expect(DividendStatus.confirmed.isConfirmedByCompany, isTrue);
      expect(DividendStatus.announced.isConfirmedByCompany, isTrue);
      expect(DividendStatus.expected.isConfirmedByCompany, isFalse);
    });
  });

  group('DividendFrequency', () {
    test('knows how many payments a year each schedule implies', () {
      expect(DividendFrequency.monthly.paymentsPerYear, 12);
      expect(DividendFrequency.quarterly.paymentsPerYear, 4);
      expect(DividendFrequency.semiAnnual.paymentsPerYear, 2);
      expect(DividendFrequency.annual.paymentsPerYear, 1);
      expect(DividendFrequency.irregular.paymentsPerYear, isNull);
      expect(DividendFrequency.unknown.paymentsPerYear, isNull);
    });

    test('infers a schedule from observed payments', () {
      expect(
        DividendFrequency.fromPaymentsPerYear(4),
        DividendFrequency.quarterly,
      );
      expect(
        DividendFrequency.fromPaymentsPerYear(1),
        DividendFrequency.annual,
      );
    });

    test('does not force an odd count into a standard schedule', () {
      expect(
        DividendFrequency.fromPaymentsPerYear(3),
        DividendFrequency.irregular,
      );
      expect(
        DividendFrequency.fromPaymentsPerYear(0),
        DividendFrequency.unknown,
      );
    });
  });

  group('DividendEvent', () {
    test('computes the gross payment for a holding', () {
      // Vision.md §9.3: €13.80 per share on 20 shares is €276.00.
      expect(
        eventWith().grossPaymentFor(Decimal.fromInt(20)),
        Money.parse('276', Currency.eur),
      );
    });

    test('handles fractional holdings', () {
      expect(
        eventWith().grossPaymentFor(Decimal.parse('2.5')),
        Money.parse('34.50', Currency.eur),
      );
    });

    test('selects the date for the calendar mode in use', () {
      final DateTime ex = DateTime.utc(2026, 8, 15);
      final DateTime pay = DateTime.utc(2026, 8, 19);
      final DividendEvent event = eventWith(exDate: ex, paymentDate: pay);

      expect(event.dateFor(DividendDateMode.exDate), ex);
      expect(event.dateFor(DividendDateMode.paymentDate), pay);
    });

    test('reports an unknown payment date instead of inventing one', () {
      final DividendEvent event = eventWith(exDate: DateTime.utc(2026, 8, 15));

      expect(event.paymentDate, isNull);
      expect(event.hasUnconfirmedPaymentDate, isTrue);
      expect(event.dateFor(DividendDateMode.paymentDate), isNull);
    });

    test('surfaces whether it is an estimate', () {
      expect(eventWith().isEstimate, isFalse);
      expect(
        eventWith(status: DividendStatus.historicallyEstimated).isEstimate,
        isTrue,
      );
    });

    test('copyWith replaces only the named fields', () {
      final DividendEvent confirmed = eventWith(status: DividendStatus.expected)
          .copyWith(status: DividendStatus.confirmed);

      expect(confirmed.status, DividendStatus.confirmed);
      expect(confirmed.amountPerShare, Money.parse('13.80', Currency.eur));
    });

    test('compares by value', () {
      expect(eventWith(), eventWith());
      expect(eventWith().hashCode, eventWith().hashCode);
      expect(eventWith(), isNot(eventWith(status: DividendStatus.expected)));
    });
  });
}
