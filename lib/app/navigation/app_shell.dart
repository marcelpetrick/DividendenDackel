import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/navigation/destinations.dart';
import 'package:flutter/services.dart';

/// Width at or above which the layout uses a navigation rail.
///
/// Below it the app uses a bottom bar. This is a size decision, not a platform
/// one: Vision.md §25 requires one product that adapts, so a narrow window on
/// Linux gets the same layout as a phone.
const double kRailBreakpoint = 700;

/// Width at or above which the rail shows extended labels.
const double kExtendedRailBreakpoint = 1200;

/// The responsive frame around every top-level screen (Vision.md §6, §25).
class AppShell extends StatelessWidget {
  /// Creates the shell.
  const AppShell({
    required this.child,
    required this.currentDestination,
    required this.onDestinationSelected,
    this.actions = const <Widget>[],
    this.banner,
    super.key,
  });

  /// The active screen.
  final Widget child;

  /// The selected top-level destination.
  final AppDestination currentDestination;

  /// Called when the user picks a destination.
  final ValueChanged<AppDestination> onDestinationSelected;

  /// Extra actions for the app bar.
  final List<Widget> actions;

  /// Optional data-freshness context shared by every top-level screen.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool useRail = width >= kRailBreakpoint;

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Focus(
        autofocus: true,
        child: CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () =>
                onDestinationSelected(AppDestination.today),
            const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () =>
                onDestinationSelected(AppDestination.calendar),
            const SingleActivator(LogicalKeyboardKey.digit3, alt: true): () =>
                onDestinationSelected(AppDestination.portfolio),
            const SingleActivator(LogicalKeyboardKey.digit4, alt: true): () =>
                onDestinationSelected(AppDestination.research),
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.tr(currentDestination.label)),
              actions: actions,
            ),
            body: Column(
              children: <Widget>[
                if (banner case final Widget value) value,
                Expanded(child: useRail ? _railLayout(context, width) : child),
              ],
            ),
            bottomNavigationBar: useRail ? null : _bottomBar(context),
          ),
        ),
      ),
    );
  }

  Widget _railLayout(BuildContext context, double width) => Row(
    children: <Widget>[
      NavigationRail(
        selectedIndex: currentDestination.index,
        extended: width >= kExtendedRailBreakpoint,
        onDestinationSelected: (int index) =>
            onDestinationSelected(AppDestination.values[index]),
        destinations: <NavigationRailDestination>[
          for (final AppDestination destination in AppDestination.values)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Tooltip(
                message: context.trFormat(
                  '{label} (Alt+{index})',
                  <String, Object?>{
                    'label': context.tr(destination.label),
                    'index': destination.index + 1,
                  },
                ),
                child: Text(context.tr(destination.label)),
              ),
            ),
        ],
      ),
      const VerticalDivider(width: 1),
      Expanded(child: child),
    ],
  );

  Widget _bottomBar(BuildContext context) => NavigationBar(
    selectedIndex: currentDestination.index,
    onDestinationSelected: (int index) =>
        onDestinationSelected(AppDestination.values[index]),
    destinations: <NavigationDestination>[
      for (final AppDestination destination in AppDestination.values)
        NavigationDestination(
          icon: Icon(destination.icon),
          selectedIcon: Icon(destination.selectedIcon),
          label: context.tr(destination.label),
          tooltip: context.trFormat('{label} (Alt+{index})', <String, Object?>{
            'label': context.tr(destination.label),
            'index': destination.index + 1,
          }),
        ),
    ],
  );
}
