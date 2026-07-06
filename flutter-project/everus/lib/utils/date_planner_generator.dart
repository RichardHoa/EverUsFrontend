import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';
import 'auth_helper.dart';

import '../models/date_plan.dart';

class DatePlannerGenerator {
  static String get apiUrl => '${AuthHelper.baseUrl}/api/date-planner/generate';

  static Future<DatePlan> generate(DatePlannerInput input) async {
    try {
      final Map<String, String> headers = {'Content-Type': 'application/json'};
      if (AuthHelper.isLoggedIn && AuthHelper.currentAccessToken != null) {
        headers['Authorization'] = 'Bearer ${AuthHelper.currentAccessToken}';
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Theme logic remains here based on vibe
        ActivityTheme theme;
        switch (input.vibe) {
          case 'romantic':
            theme = ActivityTheme.fromHex(primary: '#EC4899', secondary: '#F43F5E', accent: '#DB2777', light: '#FFF1F2', dark: '#9D174D');
            break;
          case 'fun':
          case 'adventure':
            theme = ActivityTheme.fromHex(primary: '#F97316', secondary: '#FBBF24', accent: '#EA580C', light: '#FFF7ED', dark: '#7C2D12');
            break;
          case 'chill':
          case 'casual':
          default:
            theme = ActivityTheme.fromHex(primary: '#0D9488', secondary: '#2DD4BF', accent: '#0F766E', light: '#F0FDFA', dark: '#115E59');
            break;
        }

        var stagesList = data['stages'] as List? ?? [];
        
        return DatePlan(
          id: data['id']?.toString(),
          dateType: data['dateType'] ?? 'Kế hoạch Hẹn hò',
          vibe: input.vibe,
          emoji: data['emoji'] ?? '📅',
          totalDurationMinutes: data['totalDurationMinutes'] ?? 0,
          theme: theme,
          stages: stagesList.map((e) => DateStage.fromJson(e)).toList(),
          purpose: data['purpose'] ?? '',
          googleMapsRouteUrl: data['google_maps_route_url'] ?? data['googleMapsRouteUrl'],
        );
      } else {
        throw Exception('Failed to generate date plan from server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}
