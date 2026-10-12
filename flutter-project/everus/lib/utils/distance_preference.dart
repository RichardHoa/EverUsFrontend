import 'dart:math';
import 'display_language_helper.dart';

/// How far from the user the date planner should look for places.
enum DistanceChoice {
  gan,
  xa,
  tuyHung;

  String get label {
    final s = DisplayLanguageHelper.strings;
    switch (this) {
      case DistanceChoice.gan:
        return s.distanceNear;
      case DistanceChoice.xa:
        return s.distanceFar;
      case DistanceChoice.tuyHung:
        return s.distanceRandom;
    }
  }

  String get hint {
    final s = DisplayLanguageHelper.strings;
    switch (this) {
      case DistanceChoice.gan:
        return s.distanceNearHint;
      case DistanceChoice.xa:
        return s.distanceFarHint;
      case DistanceChoice.tuyHung:
        return s.distanceRandomHint;
    }
  }

  /// The value sent to the backend. "Tuỳ hứng" is rolled fresh on every call.
  String resolve([Random? random]) {
    switch (this) {
      case DistanceChoice.gan:
        return 'gan';
      case DistanceChoice.xa:
        return 'xa';
      case DistanceChoice.tuyHung:
        return (random ?? Random()).nextBool() ? 'gan' : 'xa';
    }
  }
}
