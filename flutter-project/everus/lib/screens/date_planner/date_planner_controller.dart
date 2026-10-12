import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/date_plan.dart';
import '../../utils/api_client.dart';
import '../../utils/auth_helper.dart';
import '../../utils/date_planner_generator.dart';
import '../../utils/date_time_span.dart';
import '../../utils/distance_preference.dart';
import '../../utils/location_service.dart';
import '../../utils/vnd_budget.dart';
import '../../utils/display_language_helper.dart';

/// Controller managing state and logic for the Date Planner screen.
///
/// Separates the raw business rules, API requests, and local caching from
/// the UI rendering code, extending [ChangeNotifier] to trigger UI rebuilds.
class DatePlannerController extends ChangeNotifier {
  DatePlannerController({LocationService? locationService, Random? random})
      : _locationService = locationService ?? const DeviceLocationService(),
        _random = random ?? Random();

  final LocationService _locationService;
  final Random _random;

  // Input parameters
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 30);
  DistanceChoice _distanceChoice = DistanceChoice.gan;
  int? _budgetPerPerson;
  String _selectedVibe = 'romantic';
  int _stageCount = 3;
  String _transportation = 'motorbike';

  // Operational states
  bool _isGenerating = false;
  bool _isLoadingPlan = false;
  DatePlan? _generatedPlan;
  String? _generationError;
  DatePlan? _savedPlan;
  String? _existingInviteUrl;
  String? _inviteExpiresAt;
  bool _inviteAccepted = false;
  final Set<int> expandedStageBackups = {};

  // History of generated place names to ensure different locations on regeneration
  final List<String> _recentPlaceNames = [];
  final List<String> _recentPlaceIds = [];

  // User location: device GPS, or a geocoded manual address when permission is denied
  UserLocation? _userLocation;
  bool _isLocating = false;
  bool _locationPermissionDenied = false;
  String? _locationError;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  /// Days (date-only) that already have a saved plan, circled on the calendar.
  Set<DateTime> _plannedDates = {};

  /// Like/dislike state per backend place id, cached so cards keep their state across rebuilds.
  final Map<int, String> _placePreferences = {};

  // Getters for properties
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get startTime => _startTime;
  TimeOfDay get endTime => _endTime;
  double get durationHours => dateDurationMinutes(_startTime, _endTime) / 60.0;
  bool get isEndNextDay => endsNextDay(_startTime, _endTime);
  int? get budgetPerPerson => _budgetPerPerson;
  bool get canGenerate => isValidBudget(_budgetPerPerson);
  Set<DateTime> get plannedDates => _plannedDates;
  String get selectedVibe => _selectedVibe;
  int get stageCount => _stageCount;
  String get transportation => _transportation;
  DistanceChoice get distanceChoice => _distanceChoice;
  UserLocation? get userLocation => _userLocation;
  bool get isLocating => _isLocating;
  bool get locationPermissionDenied => _locationPermissionDenied;
  String? get locationError => _locationError;

  bool get isGenerating => _isGenerating;
  bool get isLoadingPlan => _isLoadingPlan;
  DatePlan? get generatedPlan => _generatedPlan;
  String? get generationError => _generationError;
  DatePlan? get savedPlan => _savedPlan;
  String? get existingInviteUrl => _existingInviteUrl;
  String? get inviteExpiresAt => _inviteExpiresAt;
  bool get inviteAccepted => _inviteAccepted;

  /// Updates the selected date and notifies views.
  void setSelectedDate(DateTime date) {
    _selectedDate = DateUtils.dateOnly(date);
    notifyListeners();
  }

  /// Updates the start time; an end time that would leave under an hour moves to start + 1 hour.
  void setStartTime(TimeOfDay time) {
    _startTime = time;
    if (!isValidDateSpan(_startTime, _endTime)) {
      _endTime = addMinutes(_startTime, minDateDurationMinutes);
    }
    notifyListeners();
  }

  /// Updates the end time, or returns false and keeps the old one when the date would be under an hour.
  bool setEndTime(TimeOfDay time) {
    if (!isValidDateSpan(_startTime, time)) return false;
    _endTime = time;
    notifyListeners();
    return true;
  }

  /// Updates the budget and keeps the budget field showing it.
  void setBudgetPerPerson(int? budget) {
    _budgetPerPerson = budget;
    final text = budget == null ? '' : formatVnd(budget);
    if (budgetController.text != text) {
      budgetController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    notifyListeners();
  }

  /// Updates the vibe type and notifies views.
  void setSelectedVibe(String vibe) {
    _selectedVibe = vibe;
    notifyListeners();
  }

  /// Updates target stage count.
  void setStageCount(int count) {
    _stageCount = count;
    notifyListeners();
  }

  /// Updates mode of transport.
  void setTransportation(String trans) {
    _transportation = trans;
    notifyListeners();
  }

  /// Updates the gần / xa / tuỳ hứng choice.
  void setDistanceChoice(DistanceChoice choice) {
    _distanceChoice = choice;
    notifyListeners();
  }

  /// Requests the device position; on refusal, switches the form to the manual address field.
  Future<void> useCurrentLocation() async {
    _isLocating = true;
    _locationError = null;
    notifyListeners();
    try {
      _userLocation = await _locationService.currentLocation();
      _locationPermissionDenied = false;
    } on LocationPermissionDeniedException {
      _locationPermissionDenied = true;
    } catch (e) {
      _locationPermissionDenied = true;
      _locationError = e.toString();
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  /// Geocodes a typed address into the user location (fallback when GPS is unavailable).
  Future<void> setManualAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      _locationError = DisplayLanguageHelper.strings.plannerAddressRequired;
      notifyListeners();
      return;
    }
    _isLocating = true;
    _locationError = null;
    notifyListeners();
    try {
      _userLocation = await _locationService.geocode(trimmed);
    } catch (e) {
      _userLocation = null;
      _locationError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  /// Clears the currently viewed plan or error to show the input form again.
  void clearPlan() {
    _generatedPlan = null;
    _generationError = null;
    notifyListeners();
  }

  /// Sets the generated plan and fetches invitation data.
  void setGeneratedPlan(DatePlan? plan) {
    _generatedPlan = plan;
    _existingInviteUrl = null;
    _inviteExpiresAt = null;
    _inviteAccepted = false;
    if (plan != null) {
      for (final stage in plan.stages) {
        for (final opt in stage.options) {
          if (!_recentPlaceNames.contains(opt.name)) {
            _recentPlaceNames.add(opt.name);
          }
          if (opt.id != null && !_recentPlaceIds.contains(opt.id.toString())) {
            _recentPlaceIds.add(opt.id.toString());
          }
        }
      }
      if (_recentPlaceNames.length > 40) {
        _recentPlaceNames.removeRange(0, _recentPlaceNames.length - 40);
      }
      if (_recentPlaceIds.length > 40) {
        _recentPlaceIds.removeRange(0, _recentPlaceIds.length - 40);
      }
    }
    notifyListeners();
    if (plan != null && plan.id != null) {
      checkExistingInvitation(plan.id!);
    }
  }

  /// Toggle accordion card visibility for fallback spots.
  void toggleStageBackupExpanded(int stageNum) {
    if (expandedStageBackups.contains(stageNum)) {
      expandedStageBackups.remove(stageNum);
    } else {
      expandedStageBackups.add(stageNum);
    }
    notifyListeners();
  }

  /// Disposes controllers and active timers.
  @override
  void dispose() {
    addressController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  /// Loads locally cached plans on initialization.
  Future<void> loadSavedPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = prefs.getString('saved_date_plan');
      if (planJson != null) {
        final data = jsonDecode(planJson);
        final plan = DatePlan.fromJson(data);
        _savedPlan = plan;
        notifyListeners();
        
        if (AuthHelper.isLoggedIn) {
          if (plan.id == null) {
            syncLocalPlanToServer();
          } else {
            checkExistingInvitation(plan.id!);
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to load saved plan: $e");
    }
  }

  /// Loads the days that already have a plan: the server's saved plans when logged in,
  /// otherwise the day of the one plan cached on this device.
  Future<void> loadPlannedDates() async {
    try {
      final dates = <DateTime>{};
      if (AuthHelper.isLoggedIn) {
        final token = AuthHelper.currentAccessToken;
        final response = await http.get(
          Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans'),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode != 200) return;
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        for (final item in data) {
          final date = DateTime.tryParse(item['date']?.toString() ?? '');
          if (date != null) dates.add(DateUtils.dateOnly(date));
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final date = DateTime.tryParse(prefs.getString(_savedPlanDateKey) ?? '');
        if (date != null) dates.add(DateUtils.dateOnly(date));
      }
      _plannedDates = dates;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load planned dates: $e");
    }
  }

  static const String _savedPlanDateKey = 'saved_date_plan_date';

  /// Saves the specified plan locally and keeps track of it.
  /// Pass [date] for a newly generated plan so a guest's calendar can circle its day.
  Future<void> savePlan(DatePlan plan, {DateTime? date}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(plan.toJson());
      await prefs.setString('saved_date_plan', jsonStr);
      if (date != null) {
        await prefs.setString(_savedPlanDateKey, DateUtils.dateOnly(date).toIso8601String());
      }
      _savedPlan = plan;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to save plan: $e");
    }
  }

  /// Generates a new date plan by requesting the backend API.
  ///
  /// [isGenerating] stays true until the real API call returns, which is what
  /// swaps the looping loading video for the results.
  Future<void> generatePlan() async {
    final location = _userLocation;
    if (location == null) {
      throw Exception(DisplayLanguageHelper.strings.plannerLocationRequired);
    }
    final budget = _budgetPerPerson;
    if (!isValidBudget(budget)) {
      throw Exception(DisplayLanguageHelper.strings.plannerMinBudget(formatVnd(minBudgetVnd)));
    }

    _isGenerating = true;
    _generationError = null;
    notifyListeners();

    final input = DatePlannerInput(
      date: _selectedDate,
      startTime: _startTime,
      totalDurationHours: durationHours,
      userLatitude: location.latitude,
      userLongitude: location.longitude,
      // "Tuỳ hứng" is re-rolled on every generation, never remembered.
      distancePreference: _distanceChoice.resolve(_random),
      budgetPerPerson: budget!,
      vibe: _selectedVibe,
      stageCount: _stageCount,
      transportation: _transportation,
      preferences: const [],
      excludePlaceIds: _recentPlaceIds.isNotEmpty ? List.from(_recentPlaceIds) : null,
      excludePlaceNames: _recentPlaceNames.isNotEmpty ? List.from(_recentPlaceNames) : null,
    );

    try {
      final plan = await DatePlannerGenerator.generate(input);
      await savePlan(plan, date: _selectedDate);
      _plannedDates = AuthHelper.isLoggedIn ? {..._plannedDates, _selectedDate} : {_selectedDate};
      _isGenerating = false;
      setGeneratedPlan(plan);
    } catch (e) {
      _isGenerating = false;
      _generationError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Current like/dislike for a place, or null.
  String? preferenceFor(LocationOption opt) => opt.id == null ? null : _placePreferences[opt.id];

  /// Fetches the caller's existing likes/dislikes so cards render their state.
  Future<void> loadPreferences() async {
    try {
      final response = await ApiClient.client.get(ApiClient.uri('/api/preferences'), headers: await ApiClient.headers());
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _placePreferences.clear();
        for (final item in (data['preferences'] as List? ?? [])) {
          final placeId = int.tryParse(item['place_id'].toString());
          final pref = item['preference']?.toString();
          if (placeId != null && pref != null) {
            _placePreferences[placeId] = pref;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to load place preferences: $e");
    }
  }

  /// Likes or dislikes a place; choosing the current preference again clears it.
  /// Updates optimistically and restores the previous state if the request fails.
  Future<void> setPreference(LocationOption opt, String preference) async {
    final placeId = opt.id;
    if (placeId == null) return;

    final previous = _placePreferences[placeId];
    final clearing = previous == preference;
    if (clearing) {
      _placePreferences.remove(placeId);
    } else {
      _placePreferences[placeId] = preference;
    }
    notifyListeners();

    try {
      final uri = ApiClient.uri('/api/preferences/$placeId');
      final headers = await ApiClient.headers();
      final response = clearing
          ? await ApiClient.client.delete(uri, headers: headers)
          : await ApiClient.client.put(uri, headers: headers, body: jsonEncode({'preference': preference}));
      if (response.statusCode != 200) {
        throw Exception('status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Failed to save place preference: $e");
      if (previous == null) {
        _placePreferences.remove(placeId);
      } else {
        _placePreferences[placeId] = previous;
      }
      notifyListeners();
    }
  }

  /// Checks if an invitation link has already been generated for this plan ID.
  Future<void> checkExistingInvitation(String planId) async {
    if (!AuthHelper.isLoggedIn) return;
    
    _existingInviteUrl = null;
    _inviteExpiresAt = null;
    _inviteAccepted = false;
    notifyListeners();

    try {
      final token = AuthHelper.currentAccessToken;
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/invitations/by-plan/$planId?base_url=${Uri.encodeComponent(AuthHelper.baseUrl)}');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (data['exists'] == true) {
          _existingInviteUrl = data['url'];
          _inviteExpiresAt = data['expires_at'];
          _inviteAccepted = data['accepted'] as bool? ?? false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error checking existing invitation: $e");
    }
  }

  /// Pulls a plan details from database by ID.
  Future<void> loadAndDirectToPlan(String planId) async {
    _isLoadingPlan = true;
    notifyListeners();
    try {
      final token = AuthHelper.currentAccessToken;
      final response = await http.get(
        Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans/$planId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final planData = data['plan_data'] ?? {};
        final Map<String, dynamic> mutableData = Map<String, dynamic>.from(planData);
        mutableData['id'] = planId;
        final plan = DatePlan.fromJson(mutableData);
        setGeneratedPlan(plan);
      } else {
        throw Exception('Failed to load plan');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingPlan = false;
      notifyListeners();
    }
  }

  /// Updates the priority location order of a stage if backup is clicked.
  /// Updates the priority location order of a stage if backup is clicked.
  void selectBackupLocation(DateStage stage, LocationOption opt) {
    if (_generatedPlan == null) return;
    final stageIdx = _generatedPlan!.stages.indexOf(stage);
    if (stageIdx == -1) return;

    final optionsCopy = List<LocationOption>.from(stage.options);
    final index = optionsCopy.indexOf(opt);
    if (index > 0) {
      final selectedOpt = optionsCopy.removeAt(index);
      optionsCopy.insert(0, selectedOpt);

      final updatedStage = DateStage(
        stageNum: stage.stageNum,
        title: stage.title,
        purpose: stage.purpose,
        category: stage.category,
        durationMinutes: stage.durationMinutes,
        startTime: stage.startTime,
        endTime: stage.endTime,
        tasks: stage.tasks,
        tips: stage.tips,
        options: optionsCopy,
        transitDistanceKm: stage.transitDistanceKm,
        transitDurationMinutes: stage.transitDurationMinutes,
      );

      final updatedStages = List<DateStage>.from(_generatedPlan!.stages);
      updatedStages[stageIdx] = updatedStage;

      _generatedPlan = _generatedPlan!.copyWith(stages: updatedStages);

      recalculateRouteUrl();
      expandedStageBackups.remove(stage.stageNum);

      if (_generatedPlan != null) {
        savePlan(_generatedPlan!);
        _updatePlanOnServer(_generatedPlan!);
      }
      notifyListeners();
    }
  }

  /// Recalculates google maps route parameters based on selected locations.
  void recalculateRouteUrl() {
    if (_generatedPlan == null) return;
    
    final places = _generatedPlan!.stages
        .where((s) => s.options.isNotEmpty)
        .map((s) => s.options.first)
        .toList();
        
    if (places.isEmpty) return;
    
    String mode = "driving";
    if (_transportation == 'walking') {
      mode = "walking";
    }
    
    String getRawPlaceLoc(LocationOption p) {
      if (p.latitude != null && p.longitude != null) {
        return "${p.latitude},${p.longitude}";
      }
      return "${p.name} ${p.address}";
    }
    
    final origin = Uri.encodeComponent(getRawPlaceLoc(places.first));
    final destination = Uri.encodeComponent(getRawPlaceLoc(places.last));
    
    List<String> waypoints = [];
    if (places.length > 2) {
      for (int i = 1; i < places.length - 1; i++) {
        waypoints.add(Uri.encodeComponent(getRawPlaceLoc(places[i])));
      }
    }
    
    String url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=$mode";
    if (waypoints.isNotEmpty) {
      final waypointsStr = waypoints.join("%7C");
      url += "&waypoints=$waypointsStr";
    }
    
    _generatedPlan = _generatedPlan!.copyWith(googleMapsRouteUrl: url);
  }

  /// Pushes mutated updates of locations order to server database.
  Future<void> _updatePlanOnServer(DatePlan plan) async {
    if (plan.id == null || !AuthHelper.isLoggedIn) return;
    try {
      final token = AuthHelper.currentAccessToken;
      final payload = {
        'date': _selectedDate.toIso8601String().split('T')[0],
        'plan_data': plan.toJson(),
      };
      final response = await http.put(
        Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans/${plan.id}'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        debugPrint("Plan updated successfully on database");
      }
    } catch (e) {
      debugPrint("Error updating plan on database: $e");
    }
  }

  /// Syncs newly generated plan to the server.
  Future<void> syncLocalPlanToServer() async {
    if (!AuthHelper.isLoggedIn) return;
    if (_generatedPlan == null || _generatedPlan!.id != null) return;
    
    try {
      final token = AuthHelper.currentAccessToken;
      final payload = {
        'date': _selectedDate.toIso8601String().split('T')[0],
        'plan_data': _generatedPlan!.toJson(),
      };
      final response = await http.post(
        Uri.parse('${AuthHelper.baseUrl}/api/date-planner/save'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        final planId = responseData['id']?.toString();
        if (planId != null) {
          _generatedPlan = _generatedPlan!.copyWith(id: planId);
          await savePlan(_generatedPlan!);
          debugPrint("Synced local plan to server, new ID: $planId");
        }
      }
    } catch (e) {
      debugPrint("Error syncing local plan to server: $e");
    }
  }
}
