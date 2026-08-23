import 'package:dividendendackel/app/navigation/destinations.dart';
import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(currentDestination.label), actions: actions),
      body: Column(
        children: <Widget>[
          if (banner case final Widget value) value,
          Expanded(child: useRail ? _railLayout(context, width) : child),
        ],
      ),
      bottomNavigationBar: useRail ? null : _bottomBar(context),
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
              label: Text(destination.label),
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
          label: destination.label,
        ),
    ],
  );
}
