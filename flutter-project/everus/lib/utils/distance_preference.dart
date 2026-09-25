import 'dart:math';

/// How far from the user the date planner should look for places.
enum DistanceChoice {
  gan('Gần', '≤ 5km'),
  xa('Xa', '5 – 15km'),
  tuyHung('Tuỳ hứng', 'Để EverUs chọn');

  final String label;
  final String hint;

  const DistanceChoice(this.label, this.hint);

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
