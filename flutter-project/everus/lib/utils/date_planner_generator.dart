import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';
import 'api_client.dart';

import '../models/date_plan.dart';

class DatePlannerGenerator {
  static Future<DatePlan> generate(DatePlannerInput input) async {
    final http.Response response;
    try {
      response = await ApiClient.client.post(
        ApiClient.uri('/api/date-planner/generate'),
        // Device id lets the backend apply a guest's dislikes too.
        headers: await ApiClient.headers(),
        body: jsonEncode(input.toJson()),
      );
    } catch (e) {
      throw Exception('Không thể kết nối tới máy chủ EverUs. Vui lòng thử lại!');
    }

    if (response.statusCode != 200) {
      String? detail;
      try {
        detail = (jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>)['detail']?.toString();
      } catch (_) {}
      throw Exception(detail ?? 'Không thể tạo kế hoạch (lỗi ${response.statusCode}). Vui lòng thử lại!');
    }

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
    final rawBudget = data['budgetPerPerson'] ?? data['budget_per_person'] ?? input.budgetPerPerson;

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
      budgetPerPerson: rawBudget != null ? int.tryParse(rawBudget.toString().replaceAll('.0', '')) : input.budgetPerPerson,
      area: data['area']?.toString(),
    );
  }
}
