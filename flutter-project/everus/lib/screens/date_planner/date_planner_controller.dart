import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/date_plan.dart';
import '../../utils/auth_helper.dart';
import '../../utils/date_planner_generator.dart';

/// Controller managing state and logic for the Date Planner screen.
///
/// Separates the raw business rules, API requests, and local caching from
/// the UI rendering code, extending [ChangeNotifier] to trigger UI rebuilds.
class DatePlannerController extends ChangeNotifier {
  // Input parameters
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  double _durationHours = 3.5;
  final TextEditingController areaController = TextEditingController(text: "");
  int _budgetPerPerson = 250000;
  String _selectedVibe = 'romantic';
  int _stageCount = 3;
  String _transportation = 'motorbike';

  // Operational states
  bool _isGenerating = false;
  bool _isLoadingPlan = false;
  DatePlan? _generatedPlan;
  DatePlan? _savedPlan;
  String? _existingInviteUrl;
  String? _inviteExpiresAt;
  bool _inviteAccepted = false;
  List<Map<String, dynamic>> _notifications = [];
  final Set<int> expandedStageBackups = {};

  /// Notifier driving the progress percentage on the generating view page.
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  Timer? _progressTimer;

  // Getters for properties
  DateTime get selectedDate => _selectedDate;
  TimeOfDay get startTime => _startTime;
  double get durationHours => _durationHours;
  int get budgetPerPerson => _budgetPerPerson;
  String get selectedVibe => _selectedVibe;
  int get stageCount => _stageCount;
  String get transportation => _transportation;

  bool get isGenerating => _isGenerating;
  bool get isLoadingPlan => _isLoadingPlan;
  DatePlan? get generatedPlan => _generatedPlan;
  DatePlan? get savedPlan => _savedPlan;
  String? get existingInviteUrl => _existingInviteUrl;
  String? get inviteExpiresAt => _inviteExpiresAt;
  bool get inviteAccepted => _inviteAccepted;
  List<Map<String, dynamic>> get notifications => _notifications;

  /// Updates the selected date and notifies views.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Updates the selected starting time and notifies views.
  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  /// Updates the selected duration in hours and notifies views.
  void setDurationHours(double hours) {
    _durationHours = hours;
    notifyListeners();
  }

  /// Updates the selected budget range and notifies views.
  void setBudgetPerPerson(int budget) {
    _budgetPerPerson = budget;
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

  /// Clears the currently viewed plan to show the input form again.
  void clearPlan() {
    _generatedPlan = null;
    notifyListeners();
  }

  /// Sets the generated plan and fetches invitation data.
  void setGeneratedPlan(DatePlan? plan) {
    _generatedPlan = plan;
    _existingInviteUrl = null;
    _inviteExpiresAt = null;
    _inviteAccepted = false;
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
    areaController.dispose();
    progressNotifier.dispose();
    _progressTimer?.cancel();
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

  /// Saves the specified plan locally and keeps track of it.
  Future<void> savePlan(DatePlan plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(plan.toJson());
      await prefs.setString('saved_date_plan', jsonStr);
      _savedPlan = plan;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to save plan: $e");
    }
  }

  /// Triggers a simulated counting progress indicator matching the generator wait-time.
  void _startProgressTimer() {
    progressNotifier.value = 0.0;
    _progressTimer?.cancel();
    
    const duration = Duration(milliseconds: 100);
    const totalTime = Duration(seconds: 25);
    final increment = 1.0 / (totalTime.inMilliseconds / duration.inMilliseconds);
    
    _progressTimer = Timer.periodic(duration, (timer) {
      final currentVal = progressNotifier.value;
      if (currentVal < 0.95) {
        progressNotifier.value = currentVal + increment;
      } else if (currentVal < 0.99) {
        progressNotifier.value = currentVal + 0.001;
      }
    });
  }

  /// Instantly completes progress to 100% with a quick ease animation.
  Future<void> _completeProgress() async {
    _progressTimer?.cancel();
    
    const steps = 10;
    final remaining = 1.0 - progressNotifier.value;
    final stepVal = remaining / steps;
    
    for (int i = 0; i < steps; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      progressNotifier.value = (progressNotifier.value + stepVal).clamp(0.0, 1.0);
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Generates a new date plan by requesting the backend API.
  Future<void> generatePlan() async {
    final areaText = areaController.text.trim();
    if (areaText.isEmpty) {
      throw Exception('Vui lòng nhập khu vực muốn hẹn hò!');
    }

    _isGenerating = true;
    progressNotifier.value = 0.0;
    notifyListeners();

    _startProgressTimer();

    final input = DatePlannerInput(
      date: _selectedDate,
      startTime: _startTime,
      totalDurationHours: _durationHours,
      area: areaText,
      budgetPerPerson: _budgetPerPerson,
      vibe: _selectedVibe,
      stageCount: _stageCount,
      transportation: _transportation,
      preferences: const [],
    );

    try {
      final plan = await DatePlannerGenerator.generate(input);
      await _completeProgress();
      await savePlan(plan);
      _isGenerating = false;
      setGeneratedPlan(plan);
    } catch (e) {
      _progressTimer?.cancel();
      _isGenerating = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Checks if an invitation link has already been generated for this plan ID.
  Future<void> checkExistingInvitation(String planId) async {
    if (!AuthHelper.isLoggedIn) return;
    
    _existingInviteUrl = null;
    _inviteExpiresAt = null;
    _inviteAccepted = false;
    notifyListeners();

    final client = HttpClient();
    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/invitations/by-plan/$planId');
      final request = await client.getUrl(uri);
      final token = AuthHelper.currentAccessToken;
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = json.decode(responseBody);
        if (data['exists'] == true) {
          _existingInviteUrl = data['url'];
          _inviteExpiresAt = data['expires_at'];
          _inviteAccepted = data['accepted'] as bool? ?? false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error checking existing invitation: $e");
    } finally {
      client.close();
    }
  }

  /// Fetches system notifications.
  ///
  /// Returns the first unread notification if any, enabling views to trigger alert dialogs.
  Future<Map<String, dynamic>?> fetchNotifications() async {
    if (!AuthHelper.isLoggedIn) return null;
    final client = HttpClient();
    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/notifications');
      final request = await client.getUrl(uri);
      final token = AuthHelper.currentAccessToken;
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = json.decode(responseBody);
        _notifications = List<Map<String, dynamic>>.from(data);
        notifyListeners();
        
        final unread = _notifications.firstWhere(
          (n) => n['is_read'] == false,
          orElse: () => {},
        );
        if (unread.isNotEmpty) {
          return unread;
        }
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      client.close();
    }
    return null;
  }

  /// Marks a specific notification as read.
  Future<void> markNotificationAsRead(String notifId) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/notifications/$notifId/read');
      final request = await client.postUrl(uri);
      final token = AuthHelper.currentAccessToken;
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      final response = await request.close();
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    } finally {
      client.close();
    }
  }

  /// Pulls a plan details from database by ID.
  Future<void> loadAndDirectToPlan(String planId) async {
    _isLoadingPlan = true;
    notifyListeners();
    final client = HttpClient();
    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans/$planId');
      final request = await client.getUrl(uri);
      final token = AuthHelper.currentAccessToken;
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = json.decode(responseBody);
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
      client.close();
      _isLoadingPlan = false;
      notifyListeners();
    }
  }

  /// Updates the priority location order of a stage if backup is clicked.
  void selectBackupLocation(DateStage stage, LocationOption opt) {
    final index = stage.options.indexOf(opt);
    if (index > 0) {
      final selectedOpt = stage.options.removeAt(index);
      stage.options.insert(0, selectedOpt);
      
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
    
    String getPlaceLoc(LocationOption p) {
      if (p.latitude != null && p.longitude != null) {
        return "${p.latitude},${p.longitude}";
      }
      return Uri.encodeComponent("${p.name} ${p.address}");
    }
    
    final origin = getPlaceLoc(places.first);
    final destination = getPlaceLoc(places.last);
    
    List<String> waypoints = [];
    if (places.length > 2) {
      for (int i = 1; i < places.length - 1; i++) {
        waypoints.add(getPlaceLoc(places[i]));
      }
    }
    
    String url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=$mode";
    if (waypoints.isNotEmpty) {
      final waypointsStr = waypoints.join("|");
      url += "&waypoints=${Uri.encodeComponent(waypointsStr)}";
    }
    
    _generatedPlan = _generatedPlan!.copyWith(googleMapsRouteUrl: url);
  }

  /// Pushes mutated updates of locations order to server database.
  Future<void> _updatePlanOnServer(DatePlan plan) async {
    if (plan.id == null || !AuthHelper.isLoggedIn) return;
    final client = HttpClient();
    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans/${plan.id}');
      final request = await client.putUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      final token = AuthHelper.currentAccessToken;
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      
      final payload = {
        'date': _selectedDate.toIso8601String().split('T')[0],
        'plan_data': plan.toJson(),
      };
      
      request.write(jsonEncode(payload));
      final response = await request.close();
      if (response.statusCode == 200) {
        debugPrint("Plan updated successfully on database");
      }
    } catch (e) {
      debugPrint("Error updating plan on database: $e");
    } finally {
      client.close();
    }
  }

  /// Syncs newly generated plan to the server.
  Future<void> syncLocalPlanToServer() async {
    if (!AuthHelper.isLoggedIn) return;
    if (_generatedPlan == null || _generatedPlan!.id != null) return;
    
    final client = HttpClient();
    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/date-planner/save');
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      final token = AuthHelper.currentAccessToken;
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      
      final payload = {
        'date': _selectedDate.toIso8601String().split('T')[0],
        'plan_data': _generatedPlan!.toJson(),
      };
      
      request.write(jsonEncode(payload));
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> responseData = json.decode(responseBody);
        final planId = responseData['id']?.toString();
        if (planId != null) {
          _generatedPlan = _generatedPlan!.copyWith(id: planId);
          await savePlan(_generatedPlan!);
          debugPrint("Synced local plan to server, new ID: $planId");
        }
      }
    } catch (e) {
      debugPrint("Error syncing local plan to server: $e");
    } finally {
      client.close();
    }
  }
}
