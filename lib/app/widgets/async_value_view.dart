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
  Widget build(BuildContext context) {
    if (value.hasValue) {
      final T data = value.requireValue;
      final Widget content = (isEmpty?.call(data) ?? false)
          ? _MessageState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            )
          : builder(context, data);
      if (value.hasError) {
        return _ContentWithNotice(
          message: _safeFailureMessage(value.error),
          icon: Icons.cloud_off_outlined,
          content: content,
          onRetry: onRetry,
        );
      }
      if (value.isLoading) {
        return _ContentWithNotice(
          message: 'Updating saved data…',
          icon: Icons.sync,
          showProgress: true,
          content: content,
        );
      }
      return content;
    }
    if (value.hasError) {
      return _MessageState(
        icon: Icons.error_outline,
        title: 'Data unavailable',
        message: _safeFailureMessage(value.error),
        action: onRetry == null
            ? null
            : FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
      );
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator.adaptive(
          semanticsLabel: 'Loading saved data',
        ),
      ),
    );
  }
}

String _safeFailureMessage(Object? error) =>
    error is Failure ? error.message : 'Something went wrong.';

class _ContentWithNotice extends StatelessWidget {
  const _ContentWithNotice({
    required this.message,
    required this.icon,
    required this.content,
    this.showProgress = false,
    this.onRetry,
  });

  final String message;
  final IconData icon;
  final Widget content;
  final bool showProgress;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget notice = Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            if (showProgress)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(icon, size: 18),
              ),
            Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.hasBoundedHeight) {
          return Column(
            children: <Widget>[
              notice,
              Expanded(child: content),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[notice, content],
        );
      },
    );
  }
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
