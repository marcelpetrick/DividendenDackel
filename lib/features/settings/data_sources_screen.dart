import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enables providers and manages user-supplied credentials.
class DataSourcesScreen extends ConsumerWidget {
  /// Creates the data-source settings screen.
  const DataSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DataSourceSettingsState settings = ref.watch(
      dataSourceSettingsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Data sources')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        children: <Widget>[
          Text(
            'Keyless sources work without setup. Optional provider keys stay '
            'in this device\'s secure credential store and are never bundled '
            'with the app.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space * 2),
          if (settings.isLoading)
            LinearProgressIndicator(
              semanticsLabel: context.tr('Loading data-source settings'),
            ),
          if (settings.errorMessage case final String message)
            _ErrorBanner(
              message: message,
              onRetry: () =>
                  ref.read(dataSourceSettingsProvider.notifier).reload(),
            ),
          for (final DataSourceConfiguration configuration
              in settings.configurations) ...<Widget>[
            _DataSourceCard(
              configuration: configuration,
              isBusy: settings.busySources.contains(configuration.source),
              onEnabledChanged: (bool enabled) => ref
                  .read(dataSourceSettingsProvider.notifier)
                  .setEnabled(configuration.source, enabled),
              onSetKey: () => _setKey(context, ref, configuration.source),
              onRemoveKey: () => _removeKey(context, ref, configuration.source),
            ),
            const SizedBox(height: AppTheme.space),
          ],
          const SizedBox(height: AppTheme.space),
          Text(
            'Provider availability and licensing are documented before an '
            'adapter is enabled. Sample data remains available offline.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setKey(
    BuildContext context,
    WidgetRef ref,
    MarketDataSource source,
  ) async {
    final String? key = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _ApiKeyDialog(source: source),
    );
    if (key != null && context.mounted) {
      await ref
          .read(dataSourceSettingsProvider.notifier)
          .setApiKey(source, key);
    }
  }

  Future<void> _removeKey(
    BuildContext context,
    WidgetRef ref,
    MarketDataSource source,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Remove ${source.label} key?'),
        content: const Text(
          'The provider will be disabled. You can add a new key later.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove key'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await ref.read(dataSourceSettingsProvider.notifier).removeApiKey(source);
    }
  }
}

class _DataSourceCard extends StatelessWidget {
  const _DataSourceCard({
    required this.configuration,
    required this.isBusy,
    required this.onEnabledChanged,
    required this.onSetKey,
    required this.onRemoveKey,
  });

  final DataSourceConfiguration configuration;
  final bool isBusy;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onSetKey;
  final VoidCallback onRemoveKey;

  @override
  Widget build(BuildContext context) {
    final MarketDataSource source = configuration.source;
    final ThemeData theme = Theme.of(context);
    final bool canEnable = !source.requiresApiKey || configuration.hasApiKey;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SwitchListTile(
            value: configuration.enabled,
            onChanged: isBusy || (!canEnable && !configuration.enabled)
                ? null
                : onEnabledChanged,
            secondary: Icon(
              source.requiresApiKey
                  ? Icons.key_outlined
                  : Icons.public_outlined,
            ),
            title: Text(source.label),
            subtitle: Text(source.description),
          ),
          if (source.requiresApiKey)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.space * 2,
                0,
                AppTheme.space * 2,
                AppTheme.space * 2,
              ),
              child: Wrap(
                spacing: AppTheme.space,
                runSpacing: AppTheme.space,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Icon(
                    configuration.hasApiKey
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  Text(
                    configuration.hasApiKey
                        ? 'API key stored securely'
                        : 'API key required',
                    style: theme.textTheme.bodySmall,
                  ),
                  OutlinedButton(
                    onPressed: isBusy ? null : onSetKey,
                    child: Text(
                      configuration.hasApiKey ? 'Replace key' : 'Add key',
                    ),
                  ),
                  if (configuration.hasApiKey)
                    TextButton(
                      onPressed: isBusy ? null : onRemoveKey,
                      child: const Text('Remove key'),
                    ),
                  if (isBusy)
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: Text(message),
    leading: const Icon(Icons.warning_amber_outlined),
    actions: <Widget>[
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ],
  );
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog({required this.source});

  final MarketDataSource source;

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _obscured = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${widget.source.label} API key'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        obscureText: _obscured,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: context.tr('API key'),
          suffixIcon: IconButton(
            tooltip: context.tr(_obscured ? 'Show API key' : 'Hide API key'),
            onPressed: () => setState(() => _obscured = !_obscured),
            icon: Icon(
              _obscured ? Icons.visibility_outlined : Icons.visibility_off,
            ),
          ),
        ),
        validator: (String? value) =>
            (value?.trim().isEmpty ?? true) ? 'Enter an API key' : null,
        onFieldSubmitted: (_) => _submit(),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Save securely')),
    ],
  );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text.trim());
    }
  }
}
