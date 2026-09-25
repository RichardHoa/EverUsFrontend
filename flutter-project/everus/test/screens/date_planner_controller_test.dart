import 'dart:math';

import 'package:everus/models/date_plan.dart';
import 'package:everus/screens/date_planner/date_planner_controller.dart';
import 'package:everus/utils/distance_preference.dart';
import 'package:everus/utils/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

class FakeLocationService implements LocationService {
  UserLocation? current;
  bool deny = false;
  final Map<String, UserLocation> addresses = {};

  @override
  Future<UserLocation> currentLocation() async {
    if (deny) throw const LocationPermissionDeniedException();
    return current!;
  }

  @override
  Future<UserLocation> geocode(String address) async {
    final hit = addresses[address];
    if (hit == null) throw const LocationLookupException('Không tìm thấy địa chỉ này.');
    return hit;
  }
}

Map<String, dynamic> planJson() => {
      'dateType': 'Casual',
      'emoji': '🍃',
      'totalDurationMinutes': 180,
      'purpose': 'p',
      'area': 'Gần bạn (≤5km)',
      'stages': [
        {
          'stageNum': 1,
          'title': 'Eat',
          'purpose': '',
          'category': 'Cafe',
          'durationMinutes': 60,
          'startTime': '18:00',
          'endTime': '19:00',
          'tasks': [],
          'tips': [],
          'options': [
            {'id': 1, 'name': 'Main', 'address': '', 'maps_url': 'https://maps/1'},
            {'id': 2, 'name': 'Backup', 'address': '', 'maps_url': 'https://maps/2'},
          ],
        }
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLocationService location;

  setUp(() async {
    await resetAppState();
    location = FakeLocationService();
  });

  group('location', () {
    test('uses the device position when permission is granted', () async {
      location.current = const UserLocation(latitude: 10.78, longitude: 106.70);
      final controller = DatePlannerController(locationService: location);

      await controller.useCurrentLocation();

      expect(controller.userLocation!.latitude, 10.78);
      expect(controller.locationPermissionDenied, isFalse);
    });

    test('permission denial switches to the manual address fallback', () async {
      location.deny = true;
      final controller = DatePlannerController(locationService: location);

      await controller.useCurrentLocation();

      expect(controller.userLocation, isNull);
      expect(controller.locationPermissionDenied, isTrue);
    });

    test('a manual address is geocoded into the user location', () async {
      location.addresses['Nhà thờ Đức Bà'] = const UserLocation(latitude: 10.7798, longitude: 106.699, label: 'Nhà thờ Đức Bà');
      final controller = DatePlannerController(locationService: location);

      await controller.setManualAddress('Nhà thờ Đức Bà');

      expect(controller.userLocation!.longitude, 106.699);
      expect(controller.locationError, isNull);
    });

    test('an unknown manual address reports an error', () async {
      final controller = DatePlannerController(locationService: location);

      await controller.setManualAddress('zzz');

      expect(controller.userLocation, isNull);
      expect(controller.locationError, contains('Không tìm thấy'));
    });
  });

  group('generatePlan', () {
    test('refuses to generate without a location', () async {
      final controller = DatePlannerController(locationService: location);
      expect(controller.generatePlan(), throwsA(predicate((e) => e.toString().contains('vị trí'))));
    });

    test('sends coordinates, distance and device id instead of an area', () async {
      final backend = RecordingClient((_) => jsonResponse(planJson()));
      location.current = const UserLocation(latitude: 10.78, longitude: 106.70);
      final controller = DatePlannerController(locationService: location);
      await controller.useCurrentLocation();
      controller.setDistanceChoice(DistanceChoice.xa);

      await controller.generatePlan();

      final call = backend.to('POST', '/api/date-planner/generate').single;
      expect(call.json['userLatitude'], 10.78);
      expect(call.json['userLongitude'], 106.70);
      expect(call.json['distancePreference'], 'xa');
      expect(call.json.containsKey('area'), isFalse);
      expect(call.headers['X-Device-Id'], isNotEmpty);
      expect(controller.isGenerating, isFalse);
      expect(controller.generatedPlan!.stages.single.options.first.id, 1);
    });

    test('tuỳ hứng is re-rolled on every generation', () async {
      final backend = RecordingClient((_) => jsonResponse(planJson()));
      location.current = const UserLocation(latitude: 10.78, longitude: 106.70);
      final controller = DatePlannerController(locationService: location, random: Random(7));
      await controller.useCurrentLocation();
      controller.setDistanceChoice(DistanceChoice.tuyHung);

      for (var i = 0; i < 12; i++) {
        await controller.generatePlan();
      }

      final sent = backend.to('POST', '/api/date-planner/generate').map((r) => r.json['distancePreference']).toSet();
      expect(sent, {'gan', 'xa'});
      expect(controller.distanceChoice, DistanceChoice.tuyHung);
    });
  });

  group('preferences', () {
    const main = LocationOption(id: 1, name: 'Main', address: '', mapsUrl: '');

    test('loads existing preferences from the server', () async {
      RecordingClient((_) => jsonResponse({
            'preferences': [
              {'place_id': 1, 'preference': 'like'},
              {'place_id': 9, 'preference': 'dislike'},
            ]
          }));
      final controller = DatePlannerController(locationService: location);

      await controller.loadPreferences();

      expect(controller.preferenceFor(main), 'like');
      expect(controller.preferenceFor(const LocationOption(id: 9, name: 'x', address: '', mapsUrl: '')), 'dislike');
    });

    test('like, switch to dislike, then tap again to clear', () async {
      final backend = RecordingClient((_) => jsonResponse({}));
      final controller = DatePlannerController(locationService: location);

      await controller.setPreference(main, 'like');
      expect(controller.preferenceFor(main), 'like');
      final put = backend.to('PUT', '/api/preferences/1').single;
      expect(put.json, {'preference': 'like'});
      expect(put.headers['X-Device-Id'], isNotEmpty);

      await controller.setPreference(main, 'dislike');
      expect(controller.preferenceFor(main), 'dislike');

      await controller.setPreference(main, 'dislike');
      expect(controller.preferenceFor(main), isNull);
      expect(backend.to('DELETE', '/api/preferences/1'), hasLength(1));
    });

    test('a failed request restores the previous state', () async {
      RecordingClient((_) => jsonResponse({'detail': 'boom'}, 500));
      final controller = DatePlannerController(locationService: location);

      await controller.setPreference(main, 'like');

      expect(controller.preferenceFor(main), isNull);
    });

    test('options without a place id cannot be rated', () async {
      final backend = RecordingClient((_) => jsonResponse({}));
      final controller = DatePlannerController(locationService: location);

      await controller.setPreference(const LocationOption(name: 'x', address: '', mapsUrl: ''), 'like');

      expect(backend.requests, isEmpty);
    });
  });
}
