import 'dart:math';

import 'package:everus/utils/distance_preference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gần and xa map straight to the API values', () {
    expect(DistanceChoice.gan.resolve(), 'gan');
    expect(DistanceChoice.xa.resolve(), 'xa');
  });

  test('tuỳ hứng re-rolls to gan or xa on every call', () {
    final rng = Random(42);
    final results = List.generate(40, (_) => DistanceChoice.tuyHung.resolve(rng));
    expect(results.toSet(), {'gan', 'xa'});
  });

  test('every choice has a Vietnamese label', () {
    expect(DistanceChoice.gan.label, 'Gần');
    expect(DistanceChoice.xa.label, 'Xa');
    expect(DistanceChoice.tuyHung.label, 'Tuỳ hứng');
  });
}
