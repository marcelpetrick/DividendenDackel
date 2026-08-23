import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/features/notifications/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-controlled local notification modes.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotificationSettingsState settings = ref.watch(
      notificationSettingsProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        children: <Widget>[
          const Text(
            'Notifications describe scheduled events. They never tell you to '
            'buy, sell or act urgently.',
          ),
          const SizedBox(height: AppTheme.space * 2),
          IgnorePointer(
            ignoring: settings.isLoading || settings.isSaving,
            child: RadioGroup<NotificationMode>(
              groupValue: settings.mode,
              onChanged: (NotificationMode? value) {
                if (value != null) {
                  ref.read(notificationSettingsProvider.notifier).select(value);
                }
              },
              child: const Column(
                children: <Widget>[
                  RadioListTile<NotificationMode>(
                    value: NotificationMode.disabled,
                    secondary: Icon(Icons.notifications_off_outlined),
                    title: Text('Disabled'),
                    subtitle: Text('No operating-system notifications.'),
                  ),
                  RadioListTile<NotificationMode>(
                    value: NotificationMode.importantOnly,
                    secondary: Icon(Icons.notification_important_outlined),
                    title: Text('Important only'),
                    subtitle: Text(
                      'Payments and earnings today, plus material filings.',
                    ),
                  ),
                  RadioListTile<NotificationMode>(
                    value: NotificationMode.all,
                    secondary: Icon(Icons.notifications_active_outlined),
                    title: Text('All events'),
                    subtitle: Text(
                      'Also ex-dates, tomorrow’s earnings and company events.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (settings.isLoading || settings.isSaving)
            const LinearProgressIndicator(
              semanticsLabel: 'Saving notification settings',
            ),
          if (settings.errorMessage case final String message)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.space),
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: AppTheme.space * 2),
          Text(
            'Android asks for notification permission only after you enable a '
            'mode. Linux desktop notification servers cannot schedule in the '
            'background, so due events are reconciled when the app starts, '
            'resumes or refreshes. The operating system may still suppress '
            'delivery.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
