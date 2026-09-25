import 'package:flutter/material.dart';
import 'activity.dart';

/// Represents a specific location recommendation for a date stage.
class LocationOption {
  /// Backend place id, used for like/dislike. Null for "not found" placeholders and legacy saved plans.
  final int? id;

  /// Name of the location.
  final String name;

  /// Address or description of the location.
  final String address;

  /// Average user rating, if available.
  final double? rating;

  /// Total count of reviews/ratings, if available.
  final int? ratingCount;

  /// Google Maps route or coordinate link.
  final String mapsUrl;

  /// Thumbnail image URL for the location, if available.
  final String? thumbnailUrl;

  /// Latitude of the location.
  final double? latitude;

  /// Longitude of the location.
  final double? longitude;

  /// Price level tier or formatted price string.
  final String? priceLevel;

  /// Minimum price in VND.
  final double? minPrice;

  /// Maximum price in VND.
  final double? maxPrice;

  /// Numeric price value in VND.
  final double? priceValue;

  /// Const constructor for [LocationOption].
  const LocationOption({
    this.id,
    required this.name,
    required this.address,
    this.rating,
    this.ratingCount,
    required this.mapsUrl,
    this.thumbnailUrl,
    this.latitude,
    this.longitude,
    this.priceLevel,
    this.minPrice,
    this.maxPrice,
    this.priceValue,
  });

  /// Formatted min-max price range string.
  String get formattedPriceRange {
    if (priceLevel != null && priceLevel!.isNotEmpty && priceLevel!.contains('-')) {
      return priceLevel!;
    }
    final min = minPrice ?? 0.0;
    final max = maxPrice ?? 50000.0;
    final minStr = min.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    final maxStr = max.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return '$minStr ₫ - $maxStr ₫';
  }

  /// Decodes a JSON object into a [LocationOption] model instance.
  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      ratingCount: json['ratingCount'] != null ? int.tryParse(json['ratingCount'].toString()) : null,
      mapsUrl: json['maps_url'] ?? json['mapsUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      priceLevel: json['price_level'] ?? json['priceLevel'],
      minPrice: json['min_price'] != null ? double.tryParse(json['min_price'].toString()) : (json['minPrice'] != null ? double.tryParse(json['minPrice'].toString()) : 0.0),
      maxPrice: json['max_price'] != null ? double.tryParse(json['max_price'].toString()) : (json['maxPrice'] != null ? double.tryParse(json['maxPrice'].toString()) : 50000.0),
      priceValue: json['price_value'] != null ? double.tryParse(json['price_value'].toString()) : 0.0,
    );
  }

  /// Encodes this [LocationOption] model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'ratingCount': ratingCount,
      'maps_url': mapsUrl,
      'thumbnail_url': thumbnailUrl,
      'latitude': latitude,
      'longitude': longitude,
      'price_level': priceLevel,
      'min_price': minPrice,
      'max_price': maxPrice,
      'price_value': priceValue,
    };
  }
}

/// Represents one stage/chặng in the structured date schedule.
class DateStage {
  /// Chronological sequence number of this stage.
  final int stageNum;

  /// Descriptional title of this stage (e.g., "Ăn chiều").
  final String title;

  /// Objective/aim of this stage.
  final String purpose;

  /// Genre/category of recommended spots (e.g., "coffee", "restaurant").
  final String category;

  /// Duration in minutes.
  final int durationMinutes;

  /// Formatted start time string (e.g., "18:00").
  final String startTime;

  /// Formatted end time string (e.g., "19:30").
  final String endTime;

  /// List of recommended interactive tasks to perform during this stage.
  final List<String> tasks;

  /// Handy tips for optimization/mood creation.
  final List<String> tips;

  /// Recommending spots / locations.
  final List<LocationOption> options;

  /// Travel distance in kilometers from previous stage, if any.
  final double? transitDistanceKm;

  /// Travel duration in minutes from previous stage, if any.
  final int? transitDurationMinutes;

  /// Const constructor for [DateStage].
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

  /// Decodes a JSON object into a [DateStage] model instance.
  factory DateStage.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] is List ? json['options'] as List : [];
    var tasksList = json['tasks'] is List ? json['tasks'] as List : [];
    var tipsList = json['tips'] is List ? json['tips'] as List : [];

    return DateStage(
      stageNum: int.tryParse((json['stageNum'] ?? json['stage_num'] ?? 0).toString()) ?? 0,
      title: json['title'] ?? '',
      purpose: json['purpose'] ?? '',
      category: json['category'] ?? '',
      durationMinutes: int.tryParse((json['durationMinutes'] ?? json['duration_minutes'] ?? 0).toString()) ?? 0,
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
      options: optionsList.whereType<Map<String, dynamic>>().map((e) => LocationOption.fromJson(e)).toList(),
      tasks: tasksList.map((e) => e.toString()).toList(),
      tips: tipsList.map((e) => e.toString()).toList(),
      transitDistanceKm: json['transit_distance_km'] != null ? double.tryParse(json['transit_distance_km'].toString()) : null,
      transitDurationMinutes: json['transit_duration_minutes'] != null ? int.tryParse(json['transit_duration_minutes'].toString()) : null,
    );
  }

  /// Encodes this [DateStage] model to a JSON map.
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

/// Represents a compiled, multi-stage Date Plan.
class DatePlan {
  /// The unique identifier of the date plan, if saved.
  final String? id;

  /// General type label of the date.
  final String dateType;

  /// Vibe selection (e.g., "romantic", "adventure", "casual").
  final String vibe;

  /// Emoji representation.
  final String emoji;

  /// Combined length in minutes.
  final int totalDurationMinutes;

  /// Calculated custom styling configurations.
  final ActivityTheme theme;

  /// Chronological sequence of date stages.
  final List<DateStage> stages;

  /// Overall core purpose of this date.
  final String purpose;

  /// Combined Google Maps routing navigation link.
  final String? googleMapsRouteUrl;

  /// Estimated budget threshold per user.
  final int? budgetPerPerson;

  /// Distance label from the backend (e.g. "Gần bạn (≤5km)"); older saved plans hold a district name.
  final String? area;

  /// Const constructor for [DatePlan].
  const DatePlan({
    this.id,
    required this.dateType,
    required this.vibe,
    required this.emoji,
    required this.totalDurationMinutes,
    required this.theme,
    required this.stages,
    required this.purpose,
    this.googleMapsRouteUrl,
    this.budgetPerPerson,
    this.area,
  });

  /// Returns a duplicate instance of [DatePlan] with overrides.
  DatePlan copyWith({
    String? id,
    String? dateType,
    String? vibe,
    String? emoji,
    int? totalDurationMinutes,
    ActivityTheme? theme,
    List<DateStage>? stages,
    String? purpose,
    String? googleMapsRouteUrl,
    int? budgetPerPerson,
    String? area,
  }) {
    return DatePlan(
      id: id ?? this.id,
      dateType: dateType ?? this.dateType,
      vibe: vibe ?? this.vibe,
      emoji: emoji ?? this.emoji,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      theme: theme ?? this.theme,
      stages: stages ?? this.stages,
      purpose: purpose ?? this.purpose,
      googleMapsRouteUrl: googleMapsRouteUrl ?? this.googleMapsRouteUrl,
      budgetPerPerson: budgetPerPerson ?? this.budgetPerPerson,
      area: area ?? this.area,
    );
  }

  /// Decodes a JSON object into a [DatePlan] model instance.
  factory DatePlan.fromJson(Map<String, dynamic> json) {
    var stagesList = json['stages'] is List ? json['stages'] as List : [];
    
    // Recover theme based on vibe
    ActivityTheme theme;
    switch (json['vibe']) {
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

    final rawBudget = json['budgetPerPerson'] ?? json['budget_per_person'];

    return DatePlan(
      id: json['id']?.toString(),
      dateType: json['dateType'] ?? json['date_type'] ?? '',
      vibe: json['vibe'] ?? 'casual',
      emoji: json['emoji'] ?? '📅',
      totalDurationMinutes: int.tryParse((json['totalDurationMinutes'] ?? json['total_duration_minutes'] ?? 0).toString()) ?? 0,
      theme: theme,
      stages: stagesList.whereType<Map<String, dynamic>>().map((e) => DateStage.fromJson(e)).toList(),
      purpose: json['purpose'] ?? '',
      googleMapsRouteUrl: json['google_maps_route_url'] ?? json['googleMapsRouteUrl'],
      budgetPerPerson: rawBudget != null ? int.tryParse(rawBudget.toString().replaceAll('.0', '')) : null,
      area: json['area']?.toString(),
    );
  }

  /// Encodes this [DatePlan] model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateType': dateType,
      'vibe': vibe,
      'emoji': emoji,
      'totalDurationMinutes': totalDurationMinutes,
      'stages': stages.map((e) => e.toJson()).toList(),
      'purpose': purpose,
      'google_maps_route_url': googleMapsRouteUrl,
      'budgetPerPerson': budgetPerPerson,
      'area': area,
    };
  }
}

/// Represents the input fields required to build a date plan.
class DatePlannerInput {
  /// Targeted date.
  final DateTime date;

  /// Targeted starting hour.
  final TimeOfDay startTime;

  /// Duration limit (hours).
  final double totalDurationHours;

  /// User's position, from GPS or a geocoded manual address.
  final double userLatitude;
  final double userLongitude;

  /// Resolved distance band sent to the backend: 'gan' (≤5km) or 'xa' (5-15km).
  final String distancePreference;

  /// Budget target.
  final int budgetPerPerson;

  /// Style vibe.
  final String vibe;

  /// Quantity of stages.
  final int stageCount;

  /// Mode of transit.
  final String transportation;

  /// User tags.
  final List<String> preferences;

  /// Optional list of place IDs to exclude (for regeneration diversity).
  final List<String>? excludePlaceIds;

  /// Optional list of place names to exclude (for regeneration diversity).
  final List<String>? excludePlaceNames;

  /// Const constructor for [DatePlannerInput].
  const DatePlannerInput({
    required this.date,
    required this.startTime,
    required this.totalDurationHours,
    required this.userLatitude,
    required this.userLongitude,
    required this.distancePreference,
    required this.budgetPerPerson,
    required this.vibe,
    required this.stageCount,
    required this.transportation,
    required this.preferences,
    this.excludePlaceIds,
    this.excludePlaceNames,
  });
  
  /// Encodes parameters into JSON mapping for transmission to backend API.
  Map<String, dynamic> toJson() {
    final hourStr = startTime.hour.toString().padLeft(2, '0');
    final minStr = startTime.minute.toString().padLeft(2, '0');
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final data = <String, dynamic>{
      'date': dateStr,
      'startTime': '$hourStr:$minStr',
      'totalDurationHours': totalDurationHours,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'distancePreference': distancePreference,
      'budgetPerPerson': budgetPerPerson,
      'vibe': vibe,
      'stageCount': stageCount,
      'transportation': transportation,
      'preferences': preferences,
    };
    if (excludePlaceIds != null && excludePlaceIds!.isNotEmpty) {
      data['excludePlaceIds'] = excludePlaceIds;
    }
    if (excludePlaceNames != null && excludePlaceNames!.isNotEmpty) {
      data['excludePlaceNames'] = excludePlaceNames;
    }
    return data;
  }
}
