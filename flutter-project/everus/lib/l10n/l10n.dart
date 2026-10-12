import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Display label for a date-plan transportation key ('walking' | 'motorbike' | 'taxi').
String transportLabel(AppLocalizations l, String key) {
  switch (key) {
    case 'walking':
      return l.transportWalking;
    case 'taxi':
      return l.transportTaxi;
    default:
      return l.transportMotorbike;
  }
}

/// Display label for the preference dimension at [index] (order of `dimensions` in activity.dart).
String dimensionLabel(AppLocalizations l, int index) {
  return [
    l.dimensionRomance,
    l.dimensionAdventure,
    l.dimensionCreative,
    l.dimensionIndoor,
    l.dimensionEnergy,
  ][index];
}
