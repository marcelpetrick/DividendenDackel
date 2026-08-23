import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Display-currency choice and transparent ECB reference-rate status.
class CurrencySettingsScreen extends ConsumerWidget {
  /// Creates the currency settings screen.
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DisplayCurrencyState preference = ref.watch(displayCurrencyProvider);
    final FxRefreshState refresh = ref.watch(fxRefreshProvider);
    final AsyncValue<List<FxRate>> ratesValue = ref.watch(
      cachedFxRatesProvider,
    );
    final List<FxRate> rates = ratesValue.value ?? const <FxRate>[];
    final AsyncValue<Set<Currency>> trackedValue = ref.watch(
      trackedCurrenciesProvider,
    );
    final Set<Currency> tracked =
        trackedValue.value ?? <Currency>{preference.currency};
    final DateTime now = ref.watch(clockProvider).now().toUtc();
    final Map<Currency, FxRate> latest = <Currency, FxRate>{};
    for (final FxRate rate in rates) {
      final FxRate? current = latest[rate.quote];
      if (current == null || rate.observedAt.isAfter(current.observedAt)) {
        latest[rate.quote] = rate;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Currency & exchange rates')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        children: <Widget>[
          Text(
            'Display currency',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space),
          DropdownButtonFormField<Currency>(
            initialValue: preference.currency,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Native amounts stay visible; this controls converted totals.',
            ),
            items: <DropdownMenuItem<Currency>>[
              for (final Currency currency in Currency.known.values)
                DropdownMenuItem<Currency>(
                  value: currency,
                  child: Text(currency.code),
                ),
            ],
            onChanged: preference.isLoading || preference.isSaving
                ? null
                : (Currency? currency) {
                    if (currency != null) {
                      ref
                          .read(displayCurrencyProvider.notifier)
                          .select(currency);
                    }
                  },
          ),
          if (preference.isSaving) const LinearProgressIndicator(),
          if (preference.errorMessage case final String message)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.space),
              child: Text(message),
            ),
          const SizedBox(height: AppTheme.space * 3),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'ECB reference rates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: refresh.isRefreshing
                    ? null
                    : () => ref.read(fxRefreshProvider.notifier).refresh(),
                icon: refresh.isRefreshing
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space / 2),
          const Text(
            'One EUR equals the shown amount. Conversion uses the newest rate '
            'on or before the valuation date; rates older than 7 days are stale.',
          ),
          if (ratesValue.hasError || trackedValue.hasError)
            const Padding(
              padding: EdgeInsets.only(top: AppTheme.space),
              child: Text(
                'Saved exchange-rate data could not be read. Native amounts '
                'remain available; converted values are unavailable.',
              ),
            ),
          if (refresh.errorMessage case final String message)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.space),
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: AppTheme.space),
          for (final Currency currency in tracked.where(
            (item) => item != Currency.eur,
          ))
            _RateTile(currency: currency, rate: latest[currency], now: now),
          if (tracked.every((Currency item) => item == Currency.eur))
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('No exchange rate needed'),
              subtitle: Text('All tracked and displayed amounts are EUR.'),
            ),
          const SizedBox(height: AppTheme.space),
          Text(
            'Source: Frankfurter API restricted to provider=ECB. These are '
            'daily reference rates, not executable broker prices.',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.currency,
    required this.rate,
    required this.now,
  });
  final Currency currency;
  final FxRate? rate;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final FxRate? rate = this.rate;
    if (rate == null) {
      return ListTile(
        leading: const Icon(Icons.currency_exchange),
        title: Text('EUR/${currency.code}'),
        subtitle: const Text('No cached rate. Refresh when online.'),
      );
    }
    final int age = now.difference(rate.observedAt).inDays;
    final bool stale = age > 7;
    return ListTile(
      leading: Icon(
        stale ? Icons.warning_amber_outlined : Icons.check_circle_outline,
      ),
      title: Text('1 EUR = ${rate.rate} ${currency.code}'),
      subtitle: Text(
        '${rate.provenance.source} · ${_date(rate.observedAt)} · '
        '${stale ? 'stale ($age days old)' : '$age days old'}',
      ),
    );
  }

  static String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
