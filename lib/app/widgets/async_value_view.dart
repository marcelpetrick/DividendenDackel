import 'package:dividendendackel/core/errors/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders an [AsyncValue] with the three states every screen owes the user.
///
/// Vision.md §87 makes loading, empty and error states part of the definition
/// of done, so they live here once rather than being re-invented — and
/// forgotten — per screen. Errors show the failure's user-facing message; raw
/// stack traces never reach this layer (Vision.md §55).
class AsyncValueView<T> extends StatelessWidget {
  /// Creates a view over [value].
  const AsyncValueView({
    required this.value,
    required this.builder,
    this.isEmpty,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.onRetry,
    super.key,
  });

  /// The asynchronous value to render.
  final AsyncValue<T> value;

  /// Builds the loaded state.
  final Widget Function(BuildContext context, T data) builder;

  /// Whether the loaded data should be treated as empty.
  final bool Function(T data)? isEmpty;

  /// Headline for the empty state.
  final String emptyTitle;

  /// Explanation for the empty state.
  final String? emptyMessage;

  /// Icon for the empty state.
  final IconData emptyIcon;

  /// Offered when the value failed to load.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator.adaptive(),
      ),
    ),
    error: (Object error, StackTrace stackTrace) => _MessageState(
      icon: Icons.error_outline,
      title: 'Could not load this',
      message: error is Failure ? error.message : 'Something went wrong.',
      action: onRetry == null
          ? null
          : FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
    ),
    data: (T data) {
      if (isEmpty?.call(data) ?? false) {
        return _MessageState(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
        );
      }
      return builder(context, data);
    },
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? message = this.message;

    // Scrollable so the state degrades gracefully inside a constrained height
    // or at a large text scale, rather than overflowing.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
