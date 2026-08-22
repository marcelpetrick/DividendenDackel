import 'package:flutter/material.dart';

/// A top-level section of the app (Vision.md §6).
///
/// The primary navigation is deliberately small. Everything else is reached
/// from within a section or from the overflow, so the four things that matter
/// stay one tap away.
enum AppDestination {
  /// What matters right now.
  today('/today', 'Today', Icons.today_outlined, Icons.today),

  /// Dividend and event calendar.
  calendar(
    '/calendar',
    'Calendar',
    Icons.calendar_month_outlined,
    Icons.calendar_month,
  ),

  /// Holdings and watchlist.
  portfolio(
    '/portfolio',
    'Portfolio',
    Icons.pie_chart_outline,
    Icons.pie_chart,
  ),

  /// Instrument research.
  research('/research', 'Research', Icons.insights_outlined, Icons.insights);

  const AppDestination(this.path, this.label, this.icon, this.selectedIcon);

  /// Route path.
  final String path;

  /// Label shown in the navigation bar and rail.
  final String label;

  /// Icon when unselected.
  final IconData icon;

  /// Icon when selected.
  final IconData selectedIcon;

  /// The destination whose path prefixes [location], defaulting to [today].
  static AppDestination fromLocation(String location) => values.firstWhere(
    (AppDestination d) => location.startsWith(d.path),
    orElse: () => AppDestination.today,
  );
}
