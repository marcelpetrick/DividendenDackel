import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Church-tax choice for a German private investor.
enum ChurchTaxRate {
  /// No church tax.
  none(0),

  /// Bavaria and Baden-Württemberg.
  eightPercent(8),

  /// Other German states.
  ninePercent(9);

  const ChurchTaxRate(this.percent);

  /// Percentage of Kapitalertragsteuer.
  final int percent;

  /// Decimal rate.
  Decimal get rate =>
      (Decimal.fromInt(percent) / Decimal.fromInt(100)).toDecimal();
}

/// Assessment choice controlling the statutory default allowance.
enum TaxAssessment { single, joint }

/// Visible, editable assumptions used by the German tax estimate.
final class DividendTaxProfile {
  /// Creates a tax profile.
  DividendTaxProfile({
    this.taxResidenceCountry = 'DE',
    this.churchTaxRate = ChurchTaxRate.none,
    this.assessment = TaxAssessment.single,
    Money? annualAllowance,
    Money? allowanceAlreadyUsed,
    Map<String, bool> treatyFormsFiled = const <String, bool>{},
    Map<String, WithholdingRule> countryRuleOverrides =
        const <String, WithholdingRule>{},
    Map<String, WithholdingRule> instrumentRuleOverrides =
        const <String, WithholdingRule>{},
  }) : annualAllowance =
           annualAllowance ??
           Money.fromInt(
             assessment == TaxAssessment.joint ? 2000 : 1000,
             Currency.eur,
           ),
       allowanceAlreadyUsed = allowanceAlreadyUsed ?? Money.zero(Currency.eur),
       treatyFormsFiled = Map<String, bool>.unmodifiable(treatyFormsFiled),
       countryRuleOverrides = Map<String, WithholdingRule>.unmodifiable(
         countryRuleOverrides,
       ),
       instrumentRuleOverrides = Map<String, WithholdingRule>.unmodifiable(
         instrumentRuleOverrides,
       ) {
    if (this.annualAllowance.currency != Currency.eur ||
        this.allowanceAlreadyUsed.currency != Currency.eur) {
      throw ArgumentError('The German savings allowance must be in EUR.');
    }
    if (this.annualAllowance.isNegative ||
        this.allowanceAlreadyUsed.isNegative) {
      throw ArgumentError('Savings allowance values cannot be negative.');
    }
  }

  /// ISO residence; only DE is modelled.
  final String taxResidenceCountry;

  /// Optional church tax.
  final ChurchTaxRate churchTaxRate;

  /// Single or joint assessment; users may still edit [annualAllowance].
  final TaxAssessment assessment;

  /// User-editable annual Sparer-Pauschbetrag.
  final Money annualAllowance;

  /// Allowance consumed before the first event being calculated.
  final Money allowanceAlreadyUsed;

  /// Per-source-country treaty paperwork assumption.
  final Map<String, bool> treatyFormsFiled;

  /// User-edited rules by source country.
  final Map<String, WithholdingRule> countryRuleOverrides;

  /// More-specific user-edited rules by instrument id.
  final Map<String, WithholdingRule> instrumentRuleOverrides;

  /// Whether forms are assumed filed; defaults to true as documented.
  bool formsFiledFor(String country) => treatyFormsFiled[country] ?? true;

  /// Resolves an instrument override, then country override, then table rule.
  WithholdingRule? ruleFor(
    TaxableDividend dividend,
    WithholdingRateTable table,
  ) =>
      instrumentRuleOverrides[dividend.instrumentId] ??
      countryRuleOverrides[dividend.sourceCountry.toUpperCase()] ??
      table[dividend.sourceCountry];

  /// Returns a profile with selected assumptions replaced.
  DividendTaxProfile copyWith({
    String? taxResidenceCountry,
    ChurchTaxRate? churchTaxRate,
    TaxAssessment? assessment,
    Money? annualAllowance,
    Money? allowanceAlreadyUsed,
    Map<String, bool>? treatyFormsFiled,
    Map<String, WithholdingRule>? countryRuleOverrides,
    Map<String, WithholdingRule>? instrumentRuleOverrides,
  }) => DividendTaxProfile(
    taxResidenceCountry: taxResidenceCountry ?? this.taxResidenceCountry,
    churchTaxRate: churchTaxRate ?? this.churchTaxRate,
    assessment: assessment ?? this.assessment,
    annualAllowance: annualAllowance ?? this.annualAllowance,
    allowanceAlreadyUsed: allowanceAlreadyUsed ?? this.allowanceAlreadyUsed,
    treatyFormsFiled: treatyFormsFiled ?? this.treatyFormsFiled,
    countryRuleOverrides: countryRuleOverrides ?? this.countryRuleOverrides,
    instrumentRuleOverrides:
        instrumentRuleOverrides ?? this.instrumentRuleOverrides,
  );
}

/// One source-country withholding rule, expressed as percentages.
final class WithholdingRule {
  /// Creates and validates a rule.
  WithholdingRule({
    required this.country,
    required this.statutoryRate,
    required this.treatyRateWithForms,
    required this.creditableCap,
  }) {
    for (final Percentage rate in <Percentage>[
      statutoryRate,
      treatyRateWithForms,
      creditableCap,
    ]) {
      if (rate.isNegative || rate.percent > Decimal.fromInt(100)) {
        throw ArgumentError('Withholding rates must be between 0% and 100%.');
      }
    }
  }

  /// ISO source country.
  final String country;

  /// Domestic rate without treaty relief.
  final Percentage statutoryRate;

  /// Rate normally withheld when forms are effective.
  final Percentage treatyRateWithForms;

  /// Maximum potentially creditable against German tax.
  final Percentage creditableCap;
}

/// Versioned withholding assumptions bundled with the application.
final class WithholdingRateTable {
  /// Creates a table.
  WithholdingRateTable({
    required this.version,
    required this.asOf,
    required this.source,
    required this.sourceUrl,
    required Map<String, WithholdingRule> rates,
  }) : rates = Map<String, WithholdingRule>.unmodifiable(rates) {
    if (version <= 0 || rates.isEmpty) {
      throw ArgumentError('A withholding table needs a version and rates.');
    }
  }

  /// Schema/content version.
  final int version;

  /// Effective/reference date.
  final DateTime asOf;

  /// Human-readable authoritative source.
  final String source;

  /// Link retained for verification.
  final String sourceUrl;

  /// Editable rules by ISO country.
  final Map<String, WithholdingRule> rates;

  /// Looks up a rule, leaving unknown countries explicit.
  WithholdingRule? operator [](String country) => rates[country.toUpperCase()];
}

/// Gross dividend translated to EUR by an explicit FX step before taxation.
final class TaxableDividend {
  /// Creates a taxable cash event.
  TaxableDividend({
    required this.instrumentId,
    required this.sourceCountry,
    required this.paymentDate,
    required this.grossEur,
  }) {
    if (grossEur.currency != Currency.eur || grossEur.isNegative) {
      throw ArgumentError('German taxable gross must be non-negative EUR.');
    }
  }

  /// Instrument identity.
  final String instrumentId;

  /// ISO country whose withholding rule applies.
  final String sourceCountry;

  /// Payment ordering for annual allowance consumption.
  final DateTime paymentDate;

  /// Gross translated using an attributable rate; D7 supplies that step.
  final Money grossEur;
}

/// Result marker for supported and unsupported tax residences.
sealed class DividendTaxResult {
  const DividendTaxResult();
}

/// Explicit refusal to present German numbers for another residence.
final class UnsupportedTaxCalculation extends DividendTaxResult {
  /// Creates a refusal.
  const UnsupportedTaxCalculation(this.explanation);

  /// User-facing reason.
  final String explanation;
}

/// Explainable estimate for one dividend.
final class DividendTaxBreakdown extends DividendTaxResult {
  /// Creates a complete breakdown.
  const DividendTaxBreakdown({
    required this.gross,
    required this.withheldAtSource,
    required this.creditableWithholding,
    required this.withholdingCreditApplied,
    required this.reclaimableWithholding,
    required this.allowanceApplied,
    required this.kapitalertragsteuer,
    required this.solidaritaetszuschlag,
    required this.kirchensteuer,
    required this.net,
    required this.sourceCountry,
    required this.withholdingRate,
    required this.assumptions,
    required this.confidence,
  });

  final Money gross;
  final Money withheldAtSource;
  final Money creditableWithholding;
  final Money withholdingCreditApplied;
  final Money reclaimableWithholding;
  final Money allowanceApplied;
  final Money kapitalertragsteuer;
  final Money solidaritaetszuschlag;
  final Money kirchensteuer;
  final Money net;
  final String sourceCountry;
  final Percentage withholdingRate;
  final List<String> assumptions;
  final Confidence confidence;
}

/// Ordered result for a calendar year and its remaining allowance.
final class AnnualDividendTaxResult {
  /// Creates an annual result.
  const AnnualDividendTaxResult({
    required this.results,
    required this.allowanceRemaining,
  });
  final List<DividendTaxResult> results;
  final Money allowanceRemaining;
}

/// German private-share dividend tax estimator.
final class DividendTaxCalculator {
  /// Creates a calculator using [table].
  const DividendTaxCalculator(this.table);

  final WithholdingRateTable table;
  static final Decimal _quarter = Decimal.parse('0.25');
  static final Decimal _soli = Decimal.parse('0.055');

  /// Calculates events in payment order so the allowance is consumed once.
  AnnualDividendTaxResult calculateYear({
    required List<TaxableDividend> dividends,
    required DividendTaxProfile profile,
  }) {
    final List<TaxableDividend> sorted = List<TaxableDividend>.of(dividends)
      ..sort((a, b) {
        final int byDate = a.paymentDate.compareTo(b.paymentDate);
        return byDate != 0 ? byDate : a.instrumentId.compareTo(b.instrumentId);
      });
    if (sorted.map((dividend) => dividend.paymentDate.year).toSet().length >
        1) {
      throw ArgumentError('Allowance tracking requires one calendar year.');
    }
    Decimal allowance =
        profile.annualAllowance.amount - profile.allowanceAlreadyUsed.amount;
    allowance = _max(Decimal.zero, allowance);
    final List<DividendTaxResult> results = <DividendTaxResult>[];
    for (final TaxableDividend dividend in sorted) {
      final (DividendTaxResult, Decimal) calculated = _calculate(
        dividend,
        profile,
        allowance,
      );
      results.add(calculated.$1);
      allowance = calculated.$2;
    }
    return AnnualDividendTaxResult(
      results: List<DividendTaxResult>.unmodifiable(results),
      allowanceRemaining: Money(allowance, Currency.eur),
    );
  }

  (DividendTaxResult, Decimal) _calculate(
    TaxableDividend dividend,
    DividendTaxProfile profile,
    Decimal allowanceRemaining,
  ) {
    if (profile.taxResidenceCountry.toUpperCase() != 'DE') {
      return (
        UnsupportedTaxCalculation(
          'Tax residence ${profile.taxResidenceCountry.toUpperCase()} is not modelled; no German estimate was applied.',
        ),
        allowanceRemaining,
      );
    }
    final WithholdingRule? rule = profile.ruleFor(dividend, table);
    if (rule == null) {
      return (
        UnsupportedTaxCalculation(
          'No verified withholding rule exists for ${dividend.sourceCountry.toUpperCase()}.',
        ),
        allowanceRemaining,
      );
    }

    final bool formsFiled = profile.formsFiledFor(rule.country);
    final Percentage withholdingRate = formsFiled
        ? rule.treatyRateWithForms
        : rule.statutoryRate;
    Money percent(Percentage rate) => Money(
      dividend.grossEur.amount * rate.rate,
      Currency.eur,
    ).roundedToCurrency();
    final Money withheld = percent(withholdingRate);
    final Money creditable = Money(
      _min(withheld.amount, percent(rule.creditableCap).amount),
      Currency.eur,
    );
    final Money reclaimable = Money(
      _max(Decimal.zero, withheld.amount - creditable.amount),
      Currency.eur,
    );
    final Decimal allowanceUsed = _min(
      allowanceRemaining,
      dividend.grossEur.amount,
    );
    final Decimal taxableBase = dividend.grossEur.amount - allowanceUsed;
    final Decimal maxCredit = taxableBase * _quarter;
    final Decimal creditApplied = _min(creditable.amount, maxCredit);
    final Decimal churchRate = profile.churchTaxRate.rate;
    Decimal kest = churchRate == Decimal.zero
        ? taxableBase * _quarter - creditApplied
        : ((taxableBase - Decimal.fromInt(4) * creditApplied) /
                  (Decimal.fromInt(4) + churchRate))
              .toDecimal(scaleOnInfinitePrecision: 16);
    kest = _max(Decimal.zero, kest);
    final Money kestMoney = Money(kest, Currency.eur).roundedToCurrency();
    final Money soli = Money(
      kestMoney.amount * _soli,
      Currency.eur,
    ).roundedToCurrency();
    final Money church = Money(
      kestMoney.amount * churchRate,
      Currency.eur,
    ).roundedToCurrency();
    final Money net = Money(
      dividend.grossEur.amount -
          withheld.amount -
          kestMoney.amount -
          soli.amount -
          church.amount,
      Currency.eur,
    ).roundedToCurrency();

    return (
      DividendTaxBreakdown(
        gross: dividend.grossEur,
        withheldAtSource: withheld,
        creditableWithholding: creditable,
        withholdingCreditApplied: Money(
          creditApplied,
          Currency.eur,
        ).roundedToCurrency(),
        reclaimableWithholding: reclaimable,
        allowanceApplied: Money(allowanceUsed, Currency.eur),
        kapitalertragsteuer: kestMoney,
        solidaritaetszuschlag: soli,
        kirchensteuer: church,
        net: net,
        sourceCountry: rule.country,
        withholdingRate: withholdingRate,
        assumptions: List<String>.unmodifiable(<String>[
          'German private-share taxation under §32d EStG.',
          'Gross income was supplied in EUR after an explicit FX conversion.',
          formsFiled
              ? 'Treaty forms are assumed filed for ${rule.country}.'
              : 'Treaty forms are assumed not filed for ${rule.country}.',
          'Reclaimable withholding is not added back to net cash.',
          'Funds, loss pots and broker-specific rounding are not modelled.',
          'Estimate only; not tax advice.',
        ]),
        confidence: Confidence.low,
      ),
      allowanceRemaining - allowanceUsed,
    );
  }

  static Decimal _min(Decimal left, Decimal right) =>
      left <= right ? left : right;

  static Decimal _max(Decimal left, Decimal right) =>
      left >= right ? left : right;
}
