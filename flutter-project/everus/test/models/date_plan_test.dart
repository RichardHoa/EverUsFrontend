import 'package:everus/models/date_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocationOption round-trips the place id', () {
    final opt = LocationOption.fromJson({'id': 42, 'name': 'Cafe', 'address': 'x', 'maps_url': 'u'});
    expect(opt.id, 42);
    expect(opt.toJson()['id'], 42);
    expect(LocationOption.fromJson({'name': 'Legacy', 'address': '', 'maps_url': ''}).id, isNull);
  });

  test('DatePlannerInput sends location and distance instead of area', () {
    final input = DatePlannerInput(
      date: DateTime(2026, 9, 28),
      startTime: const TimeOfDay(hour: 18, minute: 0),
      totalDurationHours: 3,
      userLatitude: 10.78,
      userLongitude: 106.70,
      distancePreference: 'xa',
      budgetPerPerson: 250000,
      vibe: 'casual',
      stageCount: 3,
      transportation: 'motorbike',
      preferences: const [],
    );
    final json = input.toJson();
    expect(json['userLatitude'], 10.78);
    expect(json['userLongitude'], 106.70);
    expect(json['distancePreference'], 'xa');
    expect(json.containsKey('area'), isFalse);
  });
}
