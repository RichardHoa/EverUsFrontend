import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../main.dart'; // For navigatorKey
import '../screens/date_planner_screen.dart';
import 'auth_helper.dart';

class NotificationManager with WidgetsBindingObserver {
  static final NotificationManager instance = NotificationManager._internal();
  static final ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);

  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  Timer? _pollingTimer;
  bool _isInitialized = false;

  StreamSubscription<String>? _sseSubscription;
  http.Client? _sseHttpClient;
  bool _isConnectingSse = false;
  Timer? _reconnectTimer;

  // Dedup: track notification IDs already shown this session
  final Set<String> _shownNotificationIds = {};
  bool _isFetchingNotifications = false;

  // Centralized notifications cache
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;


  Future<void> initialize() async {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    AuthHelper.sessionNotifier.addListener(_onAuthStateChanged);

    if (!kIsWeb) {
      // Initialize Local Notifications on native platforms
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // When notification is clicked, navigate to planner screen
          if (details.payload != null) {
            _navigateToPlanner();
          }
        },
      );
    }

    _isInitialized = true;
    startMonitoring();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthHelper.sessionNotifier.removeListener(_onAuthStateChanged);
    stopPolling();
    stopSseConnection();
  }

  void _onAuthStateChanged() {
    if (AuthHelper.isLoggedIn) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed ||
          WidgetsBinding.instance.lifecycleState == null) {
        startSseConnection();
        fetchAndShowUnreadNotification();
      }
    } else {
      _shownNotificationIds.clear();
      _notifications.clear();
      stopSseConnection();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkInvitationStatus(forceCheck: true);
      startSseConnection();
      fetchAndShowUnreadNotification();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      stopSseConnection();
      stopPolling();
    }
  }

  void startMonitoring() {
    checkInvitationStatus();
    startSseConnection();
    fetchAndShowUnreadNotification();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void startSseConnection() async {
    if (!AuthHelper.isLoggedIn) {
      stopSseConnection();
      return;
    }
    
    if (_sseSubscription != null || _isConnectingSse) {
      return; // Already connected or connecting
    }

    _isConnectingSse = true;

    try {
      final token = AuthHelper.currentAccessToken;
      if (token == null) {
        _isConnectingSse = false;
        return;
      }

      _sseHttpClient?.close();
      
      final client = http.Client();
      _sseHttpClient = client;

      final sseUri = Uri.parse('${AuthHelper.baseUrl}/api/notifications/sse');
      final request = http.Request('GET', sseUri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final streamedResponse = await client.send(request);
      _isConnectingSse = false;

      if (streamedResponse.statusCode == 200) {
        _sseSubscription = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.startsWith('data: ')) {
              try {
                final dataStr = line.substring(6);
                final data = jsonDecode(dataStr);
                _handleSseMessage(data);
              } catch (e) {
                debugPrint("Error parsing SSE line: $e");
              }
            }
          },
          onError: (e) {
            debugPrint("SSE stream error: $e");
            stopSseConnection();
            _retrySseConnection();
          },
          onDone: () {
            debugPrint("SSE stream closed by server");
            stopSseConnection();
            _retrySseConnection();
          },
          cancelOnError: true,
        );
      } else {
        debugPrint("Failed to establish SSE: status ${streamedResponse.statusCode}");
        stopSseConnection();
        _retrySseConnection();
      }
    } catch (e) {
      debugPrint("Error establishing SSE connection: $e");
      _isConnectingSse = false;
      stopSseConnection();
      _retrySseConnection();
    }
  }

  void _retrySseConnection() {
    _reconnectTimer?.cancel();
    if (!AuthHelper.isLoggedIn || 
        (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed && 
         WidgetsBinding.instance.lifecycleState != null)) {
      return;
    }
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      startSseConnection();
    });
  }

  void stopSseConnection() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sseSubscription?.cancel();
    _sseSubscription = null;
    _sseHttpClient?.close();
    _sseHttpClient = null;
    _isConnectingSse = false;
  }

  void _handleSseMessage(Map<String, dynamic> data) {
    if (data['type'] == 'invitation_accepted') {
      final inviteData = {
        'id': data['invite_id'] ?? data['id'],
        'receiver_name': data['receiver_name'],
        'date': data['date'],
        'time': data['time'],
        'location': data['location'],
      };
      
      final planId = data['plan_id'] as String?;
      if (planId != null) {
        SharedPreferences.getInstance().then((prefs) {
          final modalShownKey = 'invitation_accepted_modal_shown_$planId';
          prefs.setBool(modalShownKey, true);
        });
      }
      
      final notifId = data['notif_id']?.toString();
      if (notifId != null) {
        _shownNotificationIds.add(notifId);
      }

      _handleInvitationAccepted(inviteData);
      
      // Delay updating the bell shape to guarantee the modal appears first
      Future.delayed(const Duration(milliseconds: 300), () {
        refreshNotifier.value = !refreshNotifier.value;
        fetchAndShowUnreadNotification();
      });
    }
  }

  Future<void> checkInvitationStatus({bool forceCheck = false}) async {
    if (!AuthHelper.isLoggedIn) {
      stopPolling();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = prefs.getString('saved_date_plan');
      if (planJson == null) {
        stopPolling();
        return;
      }

      final planData = jsonDecode(planJson);
      final planId = planData['id'] as String?;
      if (planId == null) {
        stopPolling();
        return;
      }

      final token = AuthHelper.currentAccessToken;
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/invitations/by-plan/$planId');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final exists = data['exists'] as bool? ?? false;
        final accepted = data['accepted'] as bool? ?? false;

        if (exists && !accepted) {
          _pollingTimer ??= Timer.periodic(const Duration(seconds: 15), (timer) {
            checkInvitationStatus();
          });
        } else {
          // No active unaccepted invitation, stop polling
          stopPolling();
        }

        if (exists && accepted) {
          final modalShownKey = 'invitation_accepted_modal_shown_$planId';
          final alreadyShown = prefs.getBool(modalShownKey) ?? false;

          if (!alreadyShown) {
            await prefs.setBool(modalShownKey, true);
            _handleInvitationAccepted(data);
          }
        }
      }
    } catch (e) {
      debugPrint("Error in NotificationManager check: $e");
    }
  }

  void _handleInvitationAccepted(Map<String, dynamic> inviteData) {
    final isBackground = WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed &&
                         WidgetsBinding.instance.lifecycleState != null;

    if (isBackground) {
      _showLocalNotification(
        title: "Lời mời được chấp nhận! 🎉",
        body: "${inviteData['receiver_name']} đã chấp nhận lời mời hẹn hò của bạn.",
        payload: inviteData['id'],
      );
    } else {
      _showForegroundModal(inviteData);
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    if (kIsWeb) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'everus_invitations_channel',
      'Lời mời EverUs',
      channelDescription: 'Thông báo khi đối phương chấp nhận lời mời',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  void _showForegroundModal(Map<String, dynamic> inviteData, [int retryCount = 0]) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (retryCount >= 3) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showForegroundModal(inviteData, retryCount + 1);
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildModalContent(context, inviteData),
        );
      },
    );
  }

  Widget _buildModalContent(BuildContext context, Map<String, dynamic> inviteData) {
    final receiverName = inviteData['receiver_name'] ?? 'Đối phương';
    final dateStr = inviteData['date'] ?? '';
    final timeStr = inviteData['time'] ?? '';
    final location = inviteData['location'] ?? '';

    return Container(
      padding: const EdgeInsets.all(28), // increased padding from 24 to 28 for elegance
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF0F5), // lavender blush
            Colors.white,
            Color(0xFFFCE4EC), // soft pink
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Header with animated/pulsing heart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFECDD3), width: 2),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFEC4899),
              size: 48,
            ),
          ),
          const SizedBox(height: 24), // increased space between heart and title
          
          // Title
          Text(
            'Lời Mời Đã Được Đồng Ý! 🎉',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16), // increased space between title and message
          
          // Message
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: receiverName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEC4899)),
                ),
                const TextSpan(text: ' đã chấp nhận lời mời hẹn hò lãng mạn của bạn. Hãy chuẩn bị tinh thần hẹn hò nhé! 💕'),
              ],
            ),
          ),
          const SizedBox(height: 24), // increased space between message and details box

          // Date Details Box
          Container(
            padding: const EdgeInsets.all(20), // increased padding from 16 to 20
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                if (dateStr.isNotEmpty)
                  _buildDetailRow(Icons.calendar_today_rounded, "Ngày", dateStr),
                if (timeStr.isNotEmpty)
                  _buildDetailRow(Icons.access_time_rounded, "Giờ", timeStr),
                if (location.isNotEmpty)
                  _buildDetailRow(Icons.location_on_rounded, "Nơi hẹn", location),
              ],
            ),
          ),
          const SizedBox(height: 28), // increased space between details box and action buttons

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Đóng',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF4B5563)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToPlanner();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Xem Lộ Trình ➔',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // increased from 8.0 to 12.0 for breathing room
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8), // added clear horizontal separation between label and value
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlanner() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    
    nav.push(
      MaterialPageRoute(builder: (context) => const DatePlannerScreen()),
    );
  }

  /// Centralized logic to fetch all notifications and notify listeners
  Future<void> fetchNotifications() async {
    if (!AuthHelper.isLoggedIn) return;
    try {
      final token = AuthHelper.currentAccessToken;
      if (token == null) return;

      final uri = Uri.parse('${AuthHelper.baseUrl}/api/notifications');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _notifications = List<Map<String, dynamic>>.from(data);
        refreshNotifier.value = !refreshNotifier.value;
      }
    } catch (e) {
      debugPrint("Error fetching notifications in NotificationManager: $e");
    }
  }

  /// Fetches notifications silently from the server without updating UI listeners.
  Future<List<Map<String, dynamic>>> _fetchNotificationsSilently() async {
    if (!AuthHelper.isLoggedIn) return [];
    try {
      final token = AuthHelper.currentAccessToken;
      if (token == null) return [];

      final uri = Uri.parse('${AuthHelper.baseUrl}/api/notifications');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint("Error fetching notifications silently: $e");
    }
    return [];
  }

  /// Fetches unread notifications from the server and shows a dialog globally.
  ///
  /// This is page-agnostic — it uses [navigatorKey] so the dialog appears
  /// regardless of which screen the user is on.
  Future<void> fetchAndShowUnreadNotification() async {
    if (!AuthHelper.isLoggedIn || _isFetchingNotifications) return;
    
    if (navigatorKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchAndShowUnreadNotification();
      });
      return;
    }
    
    _isFetchingNotifications = true;

    try {
      // 1. Fetch notifications silently first
      final list = await _fetchNotificationsSilently();
      final prefs = await SharedPreferences.getInstance();

      // 2. Find the first unread notification we haven't shown yet
      Map<String, dynamic>? unreadNotif;
      for (final notif in list) {
        final isRead = notif['is_read'] as bool? ?? true;
        final notifId = notif['id']?.toString();
        final planId = notif['plan_id']?.toString();
        
        if (!isRead && notifId != null) {
          // If the elegant invitation accepted modal was already shown for this plan,
          // automatically mark this notification as read and skip the alert dialog.
          if (planId != null) {
            final modalShownKey = 'invitation_accepted_modal_shown_$planId';
            final alreadyShown = prefs.getBool(modalShownKey) ?? false;
            if (alreadyShown) {
              _shownNotificationIds.add(notifId);
              _markNotificationAsRead(notifId);
              continue;
            }
          }
          
          if (!_shownNotificationIds.contains(notifId)) {
            unreadNotif = notif;
            _shownNotificationIds.add(notifId);
            break; // Show one at a time
          }
        }
      }

      // 3. If there is an unread notification modal to show, present it first
      if (unreadNotif != null) {
        _showGlobalNotificationDialog(unreadNotif);
      }

      // 4. Update the notifications cache and notify the bell UI after modal triggers
      _notifications = list;
      refreshNotifier.value = !refreshNotifier.value;

    } catch (e) {
      debugPrint("Error in fetchAndShowUnreadNotification: $e");
    } finally {
      _isFetchingNotifications = false;
    }
  }

  void _showGlobalNotificationDialog(Map<String, dynamic> notif, [int retryCount = 0]) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (retryCount >= 3) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGlobalNotificationDialog(notif, retryCount + 1);
      });
      return;
    }

    final notifId = notif['id']?.toString() ?? '';
    final planId = notif['plan_id'] as String?;
    final title = notif['title'] ?? 'Thông báo';
    final message = notif['message'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _markNotificationAsRead(notifId);
              },
              child: Text(
                'Đóng',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            if (planId != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _markNotificationAsRead(notifId);
                  _navigateToPlanner();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Xem kế hoạch ➔',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _markNotificationAsRead(String notifId) async {
    try {
      final token = AuthHelper.currentAccessToken;
      if (token == null) return;

      final uri = Uri.parse('${AuthHelper.baseUrl}/api/notifications/$notifId/read');
      await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      // Trigger refresh so page-specific UIs (bell badge) update
      refreshNotifier.value = !refreshNotifier.value;
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }
}
