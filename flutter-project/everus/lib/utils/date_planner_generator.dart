import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/activity.dart';

class LocationOption {
  final String name;
  final String address;
  final double? rating;
  final int? ratingCount;
  final String mapsUrl;
  final String? thumbnailUrl;
  final double? latitude;
  final double? longitude;
  final String? priceLevel;

  const LocationOption({
    required this.name,
    required this.address,
    this.rating,
    this.ratingCount,
    required this.mapsUrl,
    this.thumbnailUrl,
    this.latitude,
    this.longitude,
    this.priceLevel,
  });

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      ratingCount: json['ratingCount'],
      mapsUrl: json['maps_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      priceLevel: json['price_level'] ?? json['priceLevel'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'rating': rating,
      'ratingCount': ratingCount,
      'maps_url': mapsUrl,
      'thumbnail_url': thumbnailUrl,
      'latitude': latitude,
      'longitude': longitude,
      'price_level': priceLevel,
    };
  }
}

class DateStage {
  final int stageNum;
  final String title;
  final String purpose;
  final String category;
  final int durationMinutes;
  final String startTime;
  final String endTime;
  final List<String> tasks;
  final List<String> tips;
  final List<LocationOption> options;
  final double? transitDistanceKm;
  final int? transitDurationMinutes;

  const DateStage({
    required this.stageNum,
    required this.title,
    required this.purpose,
    required this.category,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.tasks,
    required this.tips,
    required this.options,
    this.transitDistanceKm,
    this.transitDurationMinutes,
  });

  factory DateStage.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    var tasksList = json['tasks'] as List? ?? [];
    var tipsList = json['tips'] as List? ?? [];

    return DateStage(
      stageNum: json['stageNum'] ?? json['stage_num'] ?? 0,
      title: json['title'] ?? '',
      purpose: json['purpose'] ?? '',
      category: json['category'] ?? '',
      durationMinutes: json['durationMinutes'] ?? json['duration_minutes'] ?? 0,
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
      options: optionsList.map((e) => LocationOption.fromJson(e)).toList(),
      tasks: tasksList.map((e) => e.toString()).toList(),
      tips: tipsList.map((e) => e.toString()).toList(),
      transitDistanceKm: json['transit_distance_km'] != null ? (json['transit_distance_km'] as num).toDouble() : null,
      transitDurationMinutes: json['transit_duration_minutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageNum': stageNum,
      'title': title,
      'purpose': purpose,
      'category': category,
      'durationMinutes': durationMinutes,
      'startTime': startTime,
      'endTime': endTime,
      'options': options.map((e) => e.toJson()).toList(),
      'tasks': tasks,
      'tips': tips,
      'transit_distance_km': transitDistanceKm,
      'transit_duration_minutes': transitDurationMinutes,
    };
  }
}

class DatePlan {
  final String dateType;
  final String vibe;
  final String emoji;
  final int totalDurationMinutes;
  final ActivityTheme theme;
  final List<DateStage> stages;
  final String oath;
  final String endingQuote;
  final String? googleMapsRouteUrl;

  const DatePlan({
    required this.dateType,
    required this.vibe,
    required this.emoji,
    required this.totalDurationMinutes,
    required this.theme,
    required this.stages,
    required this.oath,
    required this.endingQuote,
    this.googleMapsRouteUrl,
  });

  factory DatePlan.fromJson(Map<String, dynamic> json) {
    var stagesList = json['stages'] as List? ?? [];
    
    // Recover theme
    ActivityTheme theme;
    switch (json['vibe']) {
      case 'romantic':
        theme = ActivityTheme.fromHex(primary: '#EC4899', secondary: '#F43F5E', accent: '#DB2777', light: '#FFF1F2', dark: '#9D174D');
        break;
      case 'fun':
        theme = ActivityTheme.fromHex(primary: '#F97316', secondary: '#FBBF24', accent: '#EA580C', light: '#FFF7ED', dark: '#7C2D12');
        break;
      case 'chill':
      default:
        theme = ActivityTheme.fromHex(primary: '#0D9488', secondary: '#2DD4BF', accent: '#0F766E', light: '#F0FDFA', dark: '#115E59');
        break;
    }

    return DatePlan(
      dateType: json['dateType'] ?? '',
      vibe: json['vibe'] ?? 'quiet',
      emoji: json['emoji'] ?? '📅',
      totalDurationMinutes: json['totalDurationMinutes'] ?? 0,
      theme: theme,
      stages: stagesList.map((e) => DateStage.fromJson(e)).toList(),
      oath: json['oath'] ?? '',
      endingQuote: json['endingQuote'] ?? '',
      googleMapsRouteUrl: json['google_maps_route_url'] ?? json['googleMapsRouteUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateType': dateType,
      'vibe': vibe,
      'emoji': emoji,
      'totalDurationMinutes': totalDurationMinutes,
      'stages': stages.map((e) => e.toJson()).toList(),
      'oath': oath,
      'endingQuote': endingQuote,
      'google_maps_route_url': googleMapsRouteUrl,
    };
  }
}

class DatePlannerInput {
  final DateTime date;
  final TimeOfDay startTime;
  final double totalDurationHours;
  final String area;
  final int budgetPerPerson;
  final String vibe; // 'romantic' | 'fun' | 'chill'
  final int stageCount;
  final String transportation; // 'walking' | 'motorbike' | 'taxi'
  final List<String> preferences;

  const DatePlannerInput({
    required this.date,
    required this.startTime,
    required this.totalDurationHours,
    required this.area,
    required this.budgetPerPerson,
    required this.vibe,
    required this.stageCount,
    required this.transportation,
    required this.preferences,
  });
  
  Map<String, dynamic> toJson() {
    final hourStr = startTime.hour.toString().padLeft(2, '0');
    final minStr = startTime.minute.toString().padLeft(2, '0');
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return {
      'date': dateStr,
      'startTime': '$hourStr:$minStr',
      'totalDurationHours': totalDurationHours,
      'area': area,
      'budgetPerPerson': budgetPerPerson,
      'vibe': vibe,
      'stageCount': stageCount,
      'transportation': transportation,
      'preferences': preferences,
    };
  }
}

class DatePlannerGenerator {
  static String get apiUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8009/api/date-planner/generate';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8009/api/date-planner/generate';
    } else {
      return 'http://127.0.0.1:8009/api/date-planner/generate';
    }
  }

  static Future<DatePlan> generate(DatePlannerInput input) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
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
            theme = ActivityTheme.fromHex(primary: '#F97316', secondary: '#FBBF24', accent: '#EA580C', light: '#FFF7ED', dark: '#7C2D12');
            break;
          case 'chill':
          default:
            theme = ActivityTheme.fromHex(primary: '#0D9488', secondary: '#2DD4BF', accent: '#0F766E', light: '#F0FDFA', dark: '#115E59');
            break;
        }

        var stagesList = data['stages'] as List? ?? [];
        
        return DatePlan(
          dateType: data['dateType'] ?? 'Kế hoạch Hẹn hò',
          vibe: input.vibe,
          emoji: data['emoji'] ?? '📅',
          totalDurationMinutes: data['totalDurationMinutes'] ?? 0,
          theme: theme,
          stages: stagesList.map((e) => DateStage.fromJson(e)).toList(),
          oath: data['oath'] ?? '',
          endingQuote: data['endingQuote'] ?? '',
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
