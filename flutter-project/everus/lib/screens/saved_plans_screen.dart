import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/auth_helper.dart';
import '../utils/date_planner_generator.dart';
import '../widgets/preference_matcher.dart'; // For GlassCard

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  List<Map<String, dynamic>> _savedPlans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSavedPlans();
  }

  Future<void> _fetchSavedPlans() async {
    if (!AuthHelper.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Vui lòng đăng nhập để xem các kế hoạch đã lưu.";
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
        Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _savedPlans = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Không thể tải danh sách kế hoạch từ máy chủ (${response.statusCode}).";
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch saved plans: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Có lỗi xảy ra khi kết nối tới máy chủ.";
        });
      }
    }
  }

  Future<void> _deletePlan(String planId) async {
    final token = AuthHelper.currentAccessToken;
    try {
      final response = await http.delete(
        Uri.parse('${AuthHelper.baseUrl}/api/date-planner/plans/$planId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _savedPlans.removeWhere((p) => p['id'] == planId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xoá kế hoạch thành công 💖'),
              backgroundColor: Color(0xFF8B5CF6),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xoá thất bại: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to delete plan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi kết nối để xoá kế hoạch.')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Xác nhận xoá',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xoá kế hoạch hẹn hò này không? Thao tác này không thể hoàn tác.',
            style: GoogleFonts.inter(
              color: const Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Huỷ',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deletePlan(planId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Xoá',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getVibeColor(String vibe) {
    switch (vibe.toLowerCase()) {
      case 'romantic':
        return const Color(0xFFEC4899); // romantic pink
      case 'fun':
      case 'adventure':
        return const Color(0xFFF97316); // fun orange
      case 'chill':
      case 'casual':
      default:
        return const Color(0xFF0D9488); // chill teal
    }
  }

  String _getVibeLabel(String vibe) {
    switch (vibe.toLowerCase()) {
      case 'romantic':
        return 'Lãng mạn';
      case 'fun':
        return 'Sôi nổi';
      case 'adventure':
        return 'Trải nghiệm';
      case 'casual':
        return 'Đời thường';
      case 'chill':
      default:
        return 'Chill';
    }
  }

  String _formatBudget(int val) {
    if (val >= 1000000) {
      return "${(val / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M VND";
    }
    return "${(val / 1000).toStringAsFixed(0)}K VND";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Kế Hoạch Hẹn Hò Đã Lưu',
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
                onPressed: _fetchSavedPlans,
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

    if (_savedPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '💖',
                style: GoogleFonts.inter(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa lưu kế hoạch hẹn hò nào.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy lên lịch và tạo kế hoạch mới nhé, hệ thống sẽ tự động lưu lại ở đây!',
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
      itemCount: _savedPlans.length,
      itemBuilder: (context, index) {
        final planMap = _savedPlans[index];
        final planId = planMap['id'] ?? '';
        final String dateStr = planMap['date'] ?? '';
        final List<dynamic> locs = planMap['locations'] ?? [];
        final String locsStr = locs.join(' ➔ ');
        final planData = planMap['plan_data'] ?? {};
        final vibe = planData['vibe'] ?? 'chill';
        final emoji = planData['emoji'] ?? '📅';
        final dateType = planData['dateType'] ?? 'Kế hoạch Hẹn hò';

        // Extract area
        String displayArea = planData['area']?.toString() ?? '';
        if (displayArea.isEmpty && planData['stages'] != null && (planData['stages'] as List).isNotEmpty) {
          try {
            final stages = planData['stages'] as List;
            final firstStage = stages.first as Map<String, dynamic>;
            final options = firstStage['options'] as List;
            if (options.isNotEmpty) {
              final firstOption = options.first as Map<String, dynamic>;
              final address = firstOption['address']?.toString() ?? '';
              final parts = address.split(',');
              if (parts.length > 1) {
                displayArea = parts[parts.length - 2].trim();
              }
            }
          } catch (_) {}
        }

        // Extract pricing
        String displayPrice = '';
        final rawBudget = planData['budgetPerPerson'] ?? planData['budgetTotal'];
        if (rawBudget != null) {
          final intVal = int.tryParse(rawBudget.toString());
          if (intVal != null) {
            displayPrice = _formatBudget(intVal);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final Map<String, dynamic> mutableData = Map<String, dynamic>.from(planData);
                mutableData['id'] = planId;
                final plan = DatePlan.fromJson(mutableData);
                Navigator.of(context).pop(plan);
              },
              borderRadius: BorderRadius.circular(24),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateType,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ngày: $dateStr${displayArea.isNotEmpty ? " • $displayArea" : ""}${displayPrice.isNotEmpty ? " • $displayPrice" : ""}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                          onPressed: () => _confirmDelete(context, planId),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getVibeColor(vibe).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getVibeLabel(vibe),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getVibeColor(vibe),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${planData['stages']?.length ?? 0} chặng',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        if (planData['budgetPerPerson'] != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.monetization_on_outlined, size: 14, color: Colors.green),
                          const SizedBox(width: 2),
                          Text(
                            _formatBudget(int.parse(planData['budgetPerPerson'].toString())),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                        if (planData['area'] != null && planData['area'].toString().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.pin_drop_outlined, size: 14, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              planData['area'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Spacer(),
                        ],
                      ],
                    ),
                    if (locsStr.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locsStr,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF4B5563),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
