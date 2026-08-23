import 'dart:convert';

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/data/tax/withholding_rate_loader.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted tax profile together with the editable withholding table.
final class TaxSettings {
  /// Creates settings.
  const TaxSettings({required this.profile, required this.table});

  /// User assumptions.
  final DividendTaxProfile profile;

  /// Bundled table plus persisted edits.
  final WithholdingRateTable table;
}

/// Persistence boundary for tax settings.
abstract interface class TaxSettingsStore {
  /// Loads saved settings for [portfolioId] or [defaults].
  Future<TaxSettings> load(
    WithholdingRateTable defaults, {
    required String portfolioId,
  });

  /// Saves all non-sensitive tax assumptions for [portfolioId].
  Future<void> save(String portfolioId, TaxSettings settings);
}

/// SharedPreferences implementation for Android and Linux.
final class PlatformTaxSettingsStore implements TaxSettingsStore {
  /// Creates the platform store.
  PlatformTaxSettingsStore({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _legacyKey = 'tax.settings.v1';
  static const String _keyPrefix = 'tax.settings.v2.';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<TaxSettings> load(
    WithholdingRateTable defaults, {
    required String portfolioId,
  }) async {
    final SharedPreferences preferences = await _preferences();
    final String? scoped = preferences.getString(_key(portfolioId));
    final String? migrated = portfolioId == InvestmentPortfolio.defaultId
        ? preferences.getString(_legacyKey)
        : null;
    final String? saved = scoped ?? migrated;
    return saved == null
        ? _defaults(defaults)
        : TaxSettingsCodec.decode(saved, defaults);
  }

  @override
  Future<void> save(String portfolioId, TaxSettings settings) async {
    final bool saved = await (await _preferences()).setString(
      _key(portfolioId),
      TaxSettingsCodec.encode(settings),
    );
    if (!saved) {
      throw StateError('The platform preference store rejected the write.');
    }
  }

  static TaxSettings _defaults(WithholdingRateTable table) =>
      TaxSettings(profile: DividendTaxProfile(), table: table);

  static String _key(String portfolioId) =>
      '$_keyPrefix${Uri.encodeComponent(portfolioId)}';
}

/// Stable JSON representation used by platform storage and tests.
abstract final class TaxSettingsCodec {
  /// Encodes settings without user portfolio data.
  static String encode(TaxSettings settings) => jsonEncode(<String, Object>{
    'taxResidence': settings.profile.taxResidenceCountry,
    'churchTax': settings.profile.churchTaxRate.name,
    'assessment': settings.profile.assessment.name,
    'annualAllowance': settings.profile.annualAllowance.amount.toString(),
    'allowanceAlreadyUsed': settings.profile.allowanceAlreadyUsed.amount
        .toString(),
    'treatyFormsFiled': settings.profile.treatyFormsFiled,
    'rates': <String, Object>{
      for (final MapEntry<String, WithholdingRule> entry
          in settings.table.rates.entries)
        entry.key: <String, String>{
          'statutory': entry.value.statutoryRate.percent.toString(),
          'treatyWithForms': entry.value.treatyRateWithForms.percent.toString(),
          'creditableCap': entry.value.creditableCap.percent.toString(),
        },
    },
  });

  /// Decodes user fields while retaining the bundled table metadata.
  static TaxSettings decode(String source, WithholdingRateTable defaults) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Tax settings must be an object.');
    }
    final Map<String, WithholdingRule> rates = <String, WithholdingRule>{
      ...defaults.rates,
    };
    if (decoded['rates'] case final Map<String, dynamic> edited) {
      for (final MapEntry<String, dynamic> entry in edited.entries) {
        if (entry.value is! Map<String, dynamic>) continue;
        final Map<String, dynamic> value = entry.value as Map<String, dynamic>;
        rates[entry.key] = WithholdingRule(
          country: entry.key,
          statutoryRate: Percentage.parsePercent('${value['statutory']}'),
          treatyRateWithForms: Percentage.parsePercent(
            '${value['treatyWithForms']}',
          ),
          creditableCap: Percentage.parsePercent('${value['creditableCap']}'),
        );
      }
    }
    T named<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((T value) => value.name == name).firstOrNull ?? fallback;
    final Map<String, bool> forms = <String, bool>{};
    if (decoded['treatyFormsFiled'] case final Map<String, dynamic> raw) {
      for (final MapEntry<String, dynamic> entry in raw.entries) {
        if (entry.value is bool) forms[entry.key] = entry.value as bool;
      }
    }
    final TaxAssessment assessment = named<TaxAssessment>(
      TaxAssessment.values,
      decoded['assessment'] as String?,
      TaxAssessment.single,
    );
    return TaxSettings(
      profile: DividendTaxProfile(
        taxResidenceCountry: decoded['taxResidence'] as String? ?? 'DE',
        churchTaxRate: named<ChurchTaxRate>(
          ChurchTaxRate.values,
          decoded['churchTax'] as String?,
          ChurchTaxRate.none,
        ),
        assessment: assessment,
        annualAllowance: Money.parse(
          decoded['annualAllowance'] as String? ??
              (assessment == TaxAssessment.joint ? '2000' : '1000'),
          Currency.eur,
        ),
        allowanceAlreadyUsed: Money.parse(
          decoded['allowanceAlreadyUsed'] as String? ?? '0',
          Currency.eur,
        ),
        treatyFormsFiled: forms,
      ),
      table: WithholdingRateTable(
        version: defaults.version,
        asOf: defaults.asOf,
        source: defaults.source,
        sourceUrl: defaults.sourceUrl,
        rates: rates,
      ),
    );
  }
}

/// Loads and saves tax settings as one consistent value.
final class TaxSettingsController extends AsyncNotifier<TaxSettings> {
  String _scopeId = InvestmentPortfolio.defaultId;

  @override
  Future<TaxSettings> build() async {
    _scopeId =
        ref.watch(effectivePortfolioIdProvider) ??
        InvestmentPortfolio.consolidatedId;
    return ref
        .watch(taxSettingsStoreProvider)
        .load(await WithholdingRateLoader.load(), portfolioId: _scopeId);
  }

  /// Persists a changed profile.
  Future<void> updateProfile(DividendTaxProfile profile) async {
    final TaxSettings current = state.requireValue;
    await _save(TaxSettings(profile: profile, table: current.table));
  }

  /// Persists one edited country rule while retaining source metadata.
  Future<void> updateRule(WithholdingRule rule) async {
    final TaxSettings current = state.requireValue;
    await _save(
      TaxSettings(
        profile: current.profile,
        table: WithholdingRateTable(
          version: current.table.version,
          asOf: current.table.asOf,
          source: current.table.source,
          sourceUrl: current.table.sourceUrl,
          rates: <String, WithholdingRule>{
            ...current.table.rates,
            rule.country: rule,
          },
        ),
      ),
    );
  }

  Future<void> _save(TaxSettings next) async {
    final String scopeId = _scopeId;
    state = AsyncData<TaxSettings>(next);
    try {
      await ref.read(taxSettingsStoreProvider).save(scopeId, next);
    } on Object catch (error, stackTrace) {
      if (scopeId == _scopeId) {
        state = AsyncError<TaxSettings>(error, stackTrace);
      }
    }
  }
}

/// Platform store, overridden by tests.
final Provider<TaxSettingsStore> taxSettingsStoreProvider =
    Provider<TaxSettingsStore>((Ref ref) => PlatformTaxSettingsStore());

/// Current tax assumptions and table.
final AsyncNotifierProvider<TaxSettingsController, TaxSettings>
taxSettingsProvider = AsyncNotifierProvider<TaxSettingsController, TaxSettings>(
  TaxSettingsController.new,
);
