import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Visible, editable dividend-tax assumptions (Vision.md §50).
class TaxSettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const TaxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(effectivePortfolioIdProvider) == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dividend tax estimate')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Select one portfolio before editing tax assumptions. Tax '
              'allowances and estimated net income are never combined across '
              'portfolio boundaries.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final AsyncValue<TaxSettings> settings = ref.watch(taxSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dividend tax estimate')),
      body: AsyncValueView<TaxSettings>(
        value: settings,
        onRetry: () => ref.invalidate(taxSettingsProvider),
        builder: (BuildContext context, TaxSettings data) => _TaxSettingsBody(
          settings: data,
          updateProfile: (DividendTaxProfile profile) =>
              ref.read(taxSettingsProvider.notifier).updateProfile(profile),
          updateRule: (WithholdingRule rule) =>
              ref.read(taxSettingsProvider.notifier).updateRule(rule),
        ),
      ),
    );
  }
}

class _TaxSettingsBody extends StatelessWidget {
  const _TaxSettingsBody({
    required this.settings,
    required this.updateProfile,
    required this.updateRule,
  });

  final TaxSettings settings;
  final Future<void> Function(DividendTaxProfile) updateProfile;
  final Future<void> Function(WithholdingRule) updateRule;

  @override
  Widget build(BuildContext context) {
    final DividendTaxProfile profile = settings.profile;
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: <Widget>[
        MaterialBanner(
          leading: const Icon(Icons.info_outline),
          content: const Text(
            'Estimate only—not tax advice or broker reconciliation. The model '
            'currently supports German tax residence and individual shares.',
          ),
          actions: const <Widget>[SizedBox.shrink()],
        ),
        _heading(context, 'Profile'),
        ListTile(
          leading: const Icon(Icons.public),
          title: const Text('Tax residence'),
          subtitle: Text(
            profile.taxResidenceCountry == 'DE'
                ? 'Germany'
                : '${profile.taxResidenceCountry} · not modelled',
          ),
          trailing: DropdownButton<String>(
            value: profile.taxResidenceCountry,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'DE', child: Text('DE')),
              DropdownMenuItem<String>(value: 'AT', child: Text('AT')),
              DropdownMenuItem<String>(value: 'CH', child: Text('CH')),
            ],
            onChanged: (String? value) {
              if (value != null) {
                updateProfile(profile.copyWith(taxResidenceCountry: value));
              }
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: const Text('Assessment'),
          subtitle: const Text('Controls the default savings allowance'),
          trailing: SegmentedButton<TaxAssessment>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<TaxAssessment>>[
              ButtonSegment<TaxAssessment>(
                value: TaxAssessment.single,
                label: Text('Single'),
              ),
              ButtonSegment<TaxAssessment>(
                value: TaxAssessment.joint,
                label: Text('Joint'),
              ),
            ],
            selected: <TaxAssessment>{profile.assessment},
            onSelectionChanged: (Set<TaxAssessment> values) {
              final TaxAssessment assessment = values.single;
              updateProfile(
                profile.copyWith(
                  assessment: assessment,
                  annualAllowance: Money.fromInt(
                    assessment == TaxAssessment.joint ? 2000 : 1000,
                    Currency.eur,
                  ),
                ),
              );
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_outlined),
          title: const Text('Church tax'),
          trailing: DropdownButton<ChurchTaxRate>(
            value: profile.churchTaxRate,
            items: const <DropdownMenuItem<ChurchTaxRate>>[
              DropdownMenuItem<ChurchTaxRate>(
                value: ChurchTaxRate.none,
                child: Text('None'),
              ),
              DropdownMenuItem<ChurchTaxRate>(
                value: ChurchTaxRate.eightPercent,
                child: Text('8%'),
              ),
              DropdownMenuItem<ChurchTaxRate>(
                value: ChurchTaxRate.ninePercent,
                child: Text('9%'),
              ),
            ],
            onChanged: (ChurchTaxRate? value) {
              if (value != null) {
                updateProfile(profile.copyWith(churchTaxRate: value));
              }
            },
          ),
        ),
        _MoneySetting(
          title: 'Annual savings allowance',
          value: profile.annualAllowance,
          onChanged: (Money value) =>
              updateProfile(profile.copyWith(annualAllowance: value)),
        ),
        _MoneySetting(
          title: 'Allowance already used',
          value: profile.allowanceAlreadyUsed,
          onChanged: (Money value) =>
              updateProfile(profile.copyWith(allowanceAlreadyUsed: value)),
        ),
        _heading(context, 'Withholding assumptions'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Table v${settings.table.version} · ${_date(settings.table.asOf)}\n'
            '${settings.table.source}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        for (final WithholdingRule rule in settings.table.rates.values)
          if (rule.country != 'DE')
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(rule.country),
              subtitle: Text(
                'With forms ${rule.treatyRateWithForms.format()} · statutory '
                '${rule.statutoryRate.format()} · credit cap ${rule.creditableCap.format()}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: context.tr('Edit ${rule.country} rates'),
                    onPressed: () => _editRule(context, rule),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  Semantics(
                    label: context.tr('Treaty forms filed for ${rule.country}'),
                    child: Switch(
                      value: profile.formsFiledFor(rule.country),
                      onChanged: (bool value) {
                        updateProfile(
                          profile.copyWith(
                            treatyFormsFiled: <String, bool>{
                              ...profile.treatyFormsFiled,
                              rule.country: value,
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Edit a country to override its rates. Treaty paperwork and '
            'broker handling cannot be detected automatically.',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Future<void> _editRule(BuildContext context, WithholdingRule rule) async {
    final WithholdingRule? edited = await showDialog<WithholdingRule>(
      context: context,
      builder: (BuildContext context) => _RuleDialog(rule: rule),
    );
    if (edited != null) await updateRule(edited);
  }

  static Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  static String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class _MoneySetting extends StatelessWidget {
  const _MoneySetting({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final Money value;
  final ValueChanged<Money> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.euro_outlined),
    title: Text(title),
    subtitle: Text(value.format(withSymbol: true)),
    trailing: const Icon(Icons.edit_outlined),
    onTap: () async {
      final Money? changed = await _moneyDialog(context, title, value);
      if (changed != null) onChanged(changed);
    },
  );

  static Future<Money?> _moneyDialog(
    BuildContext context,
    String title,
    Money value,
  ) {
    final TextEditingController controller = TextEditingController(
      text: value.amount.toString(),
    );
    return showDialog<Money>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'EUR',
            helperText: context.tr('Enter 0 or a positive amount'),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              try {
                final Money parsed = Money.parse(controller.text, Currency.eur);
                if (!parsed.isNegative) Navigator.pop(context, parsed);
              } on FormatException {
                // Keep the dialog open so the user can correct the value.
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _RuleDialog extends StatefulWidget {
  const _RuleDialog({required this.rule});
  final WithholdingRule rule;

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  late final TextEditingController statutory = TextEditingController(
    text: widget.rule.statutoryRate.percent.toString(),
  );
  late final TextEditingController treaty = TextEditingController(
    text: widget.rule.treatyRateWithForms.percent.toString(),
  );
  late final TextEditingController credit = TextEditingController(
    text: widget.rule.creditableCap.percent.toString(),
  );
  String? error;

  @override
  void dispose() {
    statutory.dispose();
    treaty.dispose();
    credit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Edit ${widget.rule.country} rates'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _field(statutory, 'Statutory %'),
        _field(treaty, 'With treaty forms %'),
        _field(credit, 'Creditable cap %'),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );

  Widget _field(TextEditingController controller, String label) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
  );

  void _save() {
    try {
      Navigator.pop(
        context,
        WithholdingRule(
          country: widget.rule.country,
          statutoryRate: Percentage.parsePercent(statutory.text),
          treatyRateWithForms: Percentage.parsePercent(treaty.text),
          creditableCap: Percentage.parsePercent(credit.text),
        ),
      );
    } on Object {
      setState(() => error = 'Enter percentages from 0 to 100.');
    }
  }
}
