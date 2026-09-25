import 'dart:convert';

import 'package:everus/utils/api_client.dart';
import 'package:everus/utils/auth_helper.dart';
import 'package:everus/utils/device_id_helper.dart';
import 'package:everus/utils/questionnaire_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A request captured by [RecordingClient].
class RecordedRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final String body;

  RecordedRequest(this.method, this.url, this.headers, this.body);

  Map<String, dynamic> get json => jsonDecode(body) as Map<String, dynamic>;
}

typedef Responder = http.Response Function(RecordedRequest request);

/// Installs a fake HTTP backend on [ApiClient] and records every request.
class RecordingClient {
  final List<RecordedRequest> requests = [];

  RecordingClient(Responder responder) {
    ApiClient.client = MockClient((request) async {
      final recorded = RecordedRequest(request.method, request.url, request.headers, request.body);
      requests.add(recorded);
      return responder(recorded);
    });
  }

  List<RecordedRequest> to(String method, String path) =>
      requests.where((r) => r.method == method && r.url.path == path).toList();
}

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Resets all global state the app keeps in static helpers.
Future<void> resetAppState({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(prefs));
  GoogleFonts.config.allowRuntimeFetching = false;
  DeviceIdHelper.resetForTesting();
  AuthHelper.sessionNotifier.value = null;
  QuestionnaireHelper.isCompletedNotifier.value = false;
}

void logIn({String token = 'jwt-token'}) {
  AuthHelper.sessionNotifier.value = {'access_token': token, 'email': 'a@b.c', 'name': 'A'};
}
