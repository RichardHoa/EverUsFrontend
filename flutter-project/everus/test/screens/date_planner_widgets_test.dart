import 'package:everus/screens/date_planner/date_planner_controller.dart';
import 'package:everus/screens/date_planner/widgets/date_planner_form.dart';
import 'package:everus/screens/date_planner/widgets/date_planner_generating.dart';
import 'package:everus/screens/date_planner/widgets/date_planner_loading.dart';
import 'package:everus/screens/date_planner/widgets/date_planner_results.dart';
import 'package:everus/utils/distance_preference.dart';
import 'package:everus/models/date_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';
import 'date_planner_controller_test.dart' show FakeLocationService, planJson;

/// Pumps [build] the way DatePlannerScreen hosts it: rebuilt whenever the controller notifies.
Future<void> pumpTall(WidgetTester tester, DatePlannerController controller, Widget Function() build) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: ListenableBuilder(listenable: controller, builder: (context, _) => build())),
  ));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  group('DatePlannerGenerating', () {
    testWidgets('shows no percentage and falls back to the spinner when the video cannot load', (tester) async {
      final controller = DatePlannerController(locationService: FakeLocationService());
      await pumpTall(tester, controller, () => DatePlannerGenerating(controller: controller));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('%'), findsNothing);
      expect(find.byType(DatePlannerLoading), findsOneWidget);
    });
  });

  group('DatePlannerForm', () {
    testWidgets('offers gần / xa / tuỳ hứng instead of a district picker', (tester) async {
      final controller = DatePlannerController(locationService: FakeLocationService());
      await pumpTall(tester, controller, () => DatePlannerForm(controller: controller));

      expect(find.text('Gần'), findsOneWidget);
      expect(find.text('Xa'), findsOneWidget);
      expect(find.text('Tuỳ hứng'), findsOneWidget);
      expect(find.textContaining('Quận 1'), findsNothing);

      await tester.tap(find.text('Xa'));
      await tester.pump();
      expect(controller.distanceChoice, DistanceChoice.xa);
    });

    testWidgets('shows the manual address field once location permission is denied', (tester) async {
      final location = FakeLocationService()..deny = true;
      final controller = DatePlannerController(locationService: location);
      await pumpTall(tester, controller, () => DatePlannerForm(controller: controller));
      expect(find.byKey(const ValueKey('manual-address-field')), findsNothing);

      await controller.useCurrentLocation();
      await tester.pump();

      expect(find.byKey(const ValueKey('manual-address-field')), findsOneWidget);
    });

    testWidgets('uses at most two Material icons', (tester) async {
      final controller = DatePlannerController(locationService: FakeLocationService());
      await pumpTall(tester, controller, () => DatePlannerForm(controller: controller));
      expect(find.byType(Icon).evaluate().length, lessThanOrEqualTo(2));
    });
  });

  group('DatePlannerResults', () {
    late DatePlannerController controller;
    late List<Uri> opened;
    late RecordingClient backend;

    Future<void> pumpResults(WidgetTester tester) async {
      backend = RecordingClient((_) => jsonResponse({'preferences': []}));
      controller = DatePlannerController(locationService: FakeLocationService());
      final json = planJson()..['vibe'] = 'casual';
      controller.setGeneratedPlan(DatePlan.fromJson(json));
      opened = [];
      await pumpTall(tester, controller, () => DatePlannerResults(controller: controller, openUrl: (uri) async => opened.add(uri)));
    }

    testWidgets('location cards drop the map button and gain like/dislike', (tester) async {
      await pumpResults(tester);

      expect(find.text('Mở bản đồ'), findsNothing);
      expect(find.byKey(const ValueKey('like-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dislike-1')), findsOneWidget);
    });

    testWidgets('liking a place calls the API and fills the icon', (tester) async {
      await pumpResults(tester);

      await tester.tap(find.byKey(const ValueKey('like-1')));
      await tester.pump();

      expect(backend.to('PUT', '/api/preferences/1'), hasLength(1));
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('tapping a backup card opens maps; the main card does not', (tester) async {
      await pumpResults(tester);

      await tester.tap(find.text('Main'));
      await tester.pump();
      expect(opened, isEmpty);

      await tester.tap(find.textContaining('Xem thêm'));
      await tester.pump();
      await tester.tap(find.text('Backup'));
      await tester.pump();
      expect(opened, [Uri.parse('https://maps/2')]);
      expect(find.text('Đặt làm chính'), findsOneWidget);
    });

    testWidgets('decorative icons are gone', (tester) async {
      await pumpResults(tester);
      for (final icon in [Icons.sell, Icons.star, Icons.assistant_navigation, Icons.keyboard_arrow_down, Icons.map]) {
        expect(find.byIcon(icon), findsNothing, reason: '$icon should be removed');
      }
    });
  });
}
