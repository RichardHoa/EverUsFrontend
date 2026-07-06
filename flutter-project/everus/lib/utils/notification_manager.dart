import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  HttpClient? _sseClient;
  bool _isConnectingSse = false;
  Timer? _reconnectTimer;


  Future<void> initialize() async {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    AuthHelper.sessionNotifier.addListener(_onAuthStateChanged);

    // Initialize Local Notifications
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
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // When notification is clicked, navigate to planner screen
        if (details.payload != null) {
          _navigateToPlanner();
        }
      },
    );

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
      }
    } else {
      stopSseConnection();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Immediate check when coming back to the app
      checkInvitationStatus(forceCheck: true);
      startSseConnection();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      stopSseConnection();
    }
  }

  void startMonitoring() {
    checkInvitationStatus();
    startSseConnection();
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

      _sseClient?.close(force: true);
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      _sseClient = client;

      final sseUri = Uri.parse('${AuthHelper.baseUrl}/api/notifications/sse');
      final request = await client.getUrl(sseUri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');

      final response = await request.close();
      _isConnectingSse = false;

      if (response.statusCode == 200) {
        _sseSubscription = response
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
        debugPrint("Failed to establish SSE: status ${response.statusCode}");
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
    _sseClient?.close(force: true);
    _sseClient = null;
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
      
      _handleInvitationAccepted(inviteData);
      refreshNotifier.value = !refreshNotifier.value;
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
    final isBackground = WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;

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
      999, // notification id
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  void _showForegroundModal(Map<String, dynamic> inviteData) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

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
    
    // Open the DatePlannerScreen (EverUsHomePage handles tabs or displays date planner)
    nav.push(
      MaterialPageRoute(builder: (context) => const DatePlannerScreen()),
    );
  }
}
