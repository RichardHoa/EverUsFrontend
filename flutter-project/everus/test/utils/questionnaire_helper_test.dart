import 'package:everus/utils/questionnaire_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

const flagKey = 'has_completed_couple_onboarding_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  group('initialize', () {
    test('cached flag is a fast path: no network call', () async {
      await resetAppState(prefs: {flagKey: true});
      final backend = RecordingClient((_) => jsonResponse({'answered': false}));

      await QuestionnaireHelper.initialize();

      expect(QuestionnaireHelper.isCompleted, isTrue);
      expect(backend.requests, isEmpty);
    });

    test('cache miss asks the server with the device id and caches a yes', () async {
      final backend = RecordingClient((_) => jsonResponse({'answered': true}));

      await QuestionnaireHelper.initialize();

      expect(QuestionnaireHelper.isCompleted, isTrue);
      final call = backend.to('GET', '/questionnaire/status').single;
      expect(call.headers['X-Device-Id'], isNotEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(flagKey), isTrue);
    });

    test('server says not answered: questionnaire is shown and nothing cached', () async {
      RecordingClient((_) => jsonResponse({'answered': false}));

      await QuestionnaireHelper.initialize();

      expect(QuestionnaireHelper.isCompleted, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(flagKey), isNull);
    });

    test('logged-in users are checked with their token', () async {
      logIn(token: 'tok');
      final backend = RecordingClient((_) => jsonResponse({'answered': true}));

      await QuestionnaireHelper.initialize();

      expect(backend.requests.single.headers['Authorization'], 'Bearer tok');
    });

    test('network failure falls back to asking', () async {
      RecordingClient((_) => throw http.ClientException('offline'));
      await QuestionnaireHelper.initialize();
      expect(QuestionnaireHelper.isCompleted, isFalse);
    });
  });

  group('submit', () {
    test('successful submit posts answers and caches the flag', () async {
      final backend = RecordingClient((_) => jsonResponse({'success': true}));

      final ok = await QuestionnaireHelper.submitToBackend(answers: {'q1': ['Cafe']}, freeText: 'hi');

      expect(ok, isTrue);
      final call = backend.to('POST', '/questionnaire/submit').single;
      expect(call.json['answers'], {'q1': ['Cafe']});
      expect(call.json['free_text'], 'hi');
      expect(call.headers['X-Device-Id'], isNotEmpty);
      expect(QuestionnaireHelper.isCompleted, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(flagKey), isTrue);
    });

    test('failed submit lets the user through this session without caching', () async {
      RecordingClient((_) => jsonResponse({'detail': 'boom'}, 500));

      final ok = await QuestionnaireHelper.submitToBackend(answers: {});

      expect(ok, isFalse);
      expect(QuestionnaireHelper.isCompleted, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(flagKey), isNull);
    });
  });

  group('edit (logged-in only)', () {
    test('guests cannot edit', () async {
      expect(QuestionnaireHelper.canEditAnswers, isFalse);
      logIn();
      expect(QuestionnaireHelper.canEditAnswers, isTrue);
    });

    test('update uses PUT with the token', () async {
      logIn(token: 'tok');
      final backend = RecordingClient((_) => jsonResponse({'success': true}));

      final ok = await QuestionnaireHelper.updateOnBackend(answers: {'q1': ['Bar']});

      expect(ok, isTrue);
      final call = backend.to('PUT', '/questionnaire/submit').single;
      expect(call.headers['Authorization'], 'Bearer tok');
      expect(call.json['answers'], {'q1': ['Bar']});
    });

    test('fetchMyAnswers returns prior answers, or null when none', () async {
      logIn();
      RecordingClient((_) => jsonResponse({'answers': {'q1': ['Cafe']}, 'free_text': 'x'}));
      final mine = await QuestionnaireHelper.fetchMyAnswers();
      expect(mine!.answers, {'q1': ['Cafe']});
      expect(mine.freeText, 'x');

      RecordingClient((_) => jsonResponse({'detail': 'none'}, 404));
      expect(await QuestionnaireHelper.fetchMyAnswers(), isNull);
    });
  });
}
