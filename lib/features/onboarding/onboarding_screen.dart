import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';

/// Three-step first-run introduction (Vision.md §23).
class OnboardingScreen extends StatefulWidget {
  /// Creates the walkthrough. [onComplete] persists before the screen closes.
  const OnboardingScreen({required this.onComplete, super.key});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _saving = false;
  String? _error;

  static const List<_OnboardingStep> _steps = <_OnboardingStep>[
    _OnboardingStep(
      icon: Icons.offline_pin_outlined,
      title: 'Your portfolio stays on this device',
      body:
          'DividendenDackel reads from a local database first. Saved holdings, '
          'calendar events, forecasts and research remain useful offline.',
    ),
    _OnboardingStep(
      icon: Icons.playlist_add_outlined,
      title: 'Follow only what matters to you',
      body:
          'Add shares you own or place companies on the watchlist from '
          'Portfolio. Today and Calendar then focus on those instruments.',
    ),
    _OnboardingStep(
      icon: Icons.fact_check_outlined,
      title: 'Facts keep their context',
      body:
          'Sources and “Last updated” ages stay visible. Confirmed and '
          'estimated dividends are labelled separately, and every forecast is '
          'a scenario—not a promise.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final _OnboardingStep step = _steps[_step];
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.space * 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Semantics(
                    label: context.trFormat(
                      'Step {current} of {total}',
                      <String, Object?>{
                        'current': _step + 1,
                        'total': _steps.length,
                      },
                    ),
                    child: Text(
                      '${_step + 1} / ${_steps.length}',
                      translate: false,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space * 3),
                  Icon(step.icon, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: AppTheme.space * 3),
                  Text(
                    step.title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.space * 2),
                  Text(
                    step.body,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (_error case final String message) ...<Widget>[
                    const SizedBox(height: AppTheme.space * 2),
                    Text(
                      message,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppTheme.space * 4),
                  Row(
                    children: <Widget>[
                      if (_step > 0)
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () => setState(() => _step--),
                          child: const Text('Back'),
                        )
                      else
                        const Spacer(),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _saving ? null : _advance,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _step == _steps.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward,
                              ),
                        label: Text(
                          _step == _steps.length - 1 ? 'Go to Today' : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _advance() async {
    if (_step < _steps.length - 1) {
      setState(() {
        _step++;
        _error = null;
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onComplete();
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save completion. Try again.';
        });
      }
    }
  }
}

final class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}
