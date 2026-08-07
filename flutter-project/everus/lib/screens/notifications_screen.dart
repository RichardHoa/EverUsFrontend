import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/auth_helper.dart';
import '../widgets/everus_footer.dart';
import '../models/date_plan.dart';
import '../widgets/preference_matcher.dart'; // For GlassCard
import '../utils/notification_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    NotificationManager.refreshNotifier.addListener(_onRefreshNotifications);
  }

  @override
  void dispose() {
    NotificationManager.refreshNotifier.removeListener(_onRefreshNotifications);
    super.dispose();
  }

  void _onRefreshNotifications() {
    if (mounted) {
      _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    if (!AuthHelper.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Vui lòng đăng nhập để xem thông báo.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthHelper.currentAccessToken;
      final response = await http.get(
        Uri.parse('${AuthHelper.baseUrl}/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _notifications = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Không thể tải danh sách thông báo (${response.statusCode}).";
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch notifications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Có lỗi xảy ra khi kết nối tới máy chủ.";
        });
      }
    }
  }

  Future<void> _markAsRead(String notifId) async {
    final token = AuthHelper.currentAccessToken;
    try {
      final response = await http.post(
        Uri.parse('${AuthHelper.baseUrl}/api/notifications/$notifId/read'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final index = _notifications.indexWhere((n) => n['id'] == notifId);
            if (index != -1) {
              _notifications[index]['is_read'] = true;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> _loadAndDirectToPlan(String planId, String notifId) async {
    bool isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      ),
    );

    await _markAsRead(notifId);
    final token = AuthHelper.currentAccessToken;

    try {
      final response = await http.get(
        Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans/$planId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (mounted && isDialogShowing) {
        Navigator.of(context).pop();
        isDialogShowing = false;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final planData = data['plan_data'] ?? {};
        final Map<String, dynamic> mutableData = Map<String, dynamic>.from(planData);
        mutableData['id'] = planId;
        final plan = DatePlan.fromJson(mutableData);
        
        if (mounted) {
          Navigator.of(context).pop(plan);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải kế hoạch hẹn hò này.')),
          );
        }
      }
    } catch (e) {
      if (mounted && isDialogShowing) {
        Navigator.of(context).pop();
        isDialogShowing = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải kế hoạch: $e')),
        );
      }
    }
  }

  String _formatDateTime(String? isoStr) {
    if (isoStr == null) return '';
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      return "$hour:$min - $day/$month/$year";
    } catch (e) {
      return isoStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFF7F7),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF0F3), // very soft rose pink
              Colors.white,
              Color(0xFFF3E8FF), // very soft violet
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF8B5CF6)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Thông Báo Hẹn Hò',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const EverUsFooter(currentTab: 'other'),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔔',
                style: GoogleFonts.inter(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa có thông báo nào.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Các hoạt động tương tác từ đối phương sẽ hiển thị tại đây.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        final notifId = notif['id'] ?? '';
        final planId = notif['plan_id'] as String?;
        final title = notif['title'] ?? 'Thông báo';
        final message = notif['message'] ?? '';
        final isRead = notif['is_read'] ?? false;
        final createdAt = notif['created_at'] as String?;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () {
              if (planId != null) {
                _loadAndDirectToPlan(planId, notifId);
              } else if (!isRead) {
                _markAsRead(notifId);
              }
            },
            child: GlassCard(
              enableBlur: false,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.grey.shade100 : const Color(0xFFFDF2F8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: isRead ? Colors.grey : const Color(0xFFEC4899),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isRead ? const Color(0xFF6B7280) : const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEC4899),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thời gian chấp nhận: ${_formatDateTime(createdAt)}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF9CA3AF),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (planId != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _loadAndDirectToPlan(planId, notifId),
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                                  label: Text(
                                    'Xem lộ trình',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFF1F2),
                                    foregroundColor: const Color(0xFFEC4899),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(color: Color(0xFFFECDD3), width: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (!isRead) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _markAsRead(notifId),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFF5F3FF),
                                    foregroundColor: const Color(0xFF8B5CF6),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(color: Color(0xFFDDD6FE), width: 1),
                                    ),
                                  ),
                                  child: Text(
                                    'Đã đọc',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
