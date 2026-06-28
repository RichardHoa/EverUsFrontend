import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';
import '../utils/date_planner_generator.dart';
import '../widgets/preference_matcher.dart'; // For GlassCard
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatePlannerScreen extends StatefulWidget {
  const DatePlannerScreen({super.key});

  @override
  State<DatePlannerScreen> createState() => _DatePlannerScreenState();
}

class _DatePlannerScreenState extends State<DatePlannerScreen> {
  // Input states
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  double _durationHours = 3.5;
  final TextEditingController _areaController = TextEditingController(text: "");
  int _budgetPerPerson = 250000;
  String _selectedVibe = 'romantic'; // 'romantic' | 'fun' | 'chill'
  final int _stageCount = 3;
  String _transportation = 'motorbike'; // 'walking' | 'motorbike' | 'taxi'

  // Flow states
  bool _isGenerating = false;
  DatePlan? _generatedPlan;
  DatePlan? _savedPlan;

  // Vibes metadata
  final Map<String, Map<String, String>> _vibesInfo = {
    'chill': {'label': 'Bình yên', 'emoji': '🍃', 'desc': 'Trà chiều, góc sách & tâm sự nhẹ nhàng'},
    'romantic': {'label': 'Lãng mạn', 'emoji': '💖', 'desc': 'Ánh nến, hoàng hôn & kết nối ngọt ngào'},
    'fun': {'label': 'Vui vẻ', 'emoji': '⚡', 'desc': 'Trò chơi, đường phố náo nhiệt & tiếng cười'},
  };

  @override
  void initState() {
    super.initState();
    _loadSavedPlan();
  }

  void _loadSavedPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = prefs.getString('saved_date_plan');
      if (planJson != null) {
        final data = jsonDecode(planJson);
        final plan = DatePlan.fromJson(data);
        if (mounted) {
          setState(() {
            _savedPlan = plan;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load saved plan: $e");
    }
  }

  void _savePlan(DatePlan plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(plan.toJson());
      await prefs.setString('saved_date_plan', jsonStr);
      if (mounted) {
        setState(() {
          _savedPlan = plan;
        });
      }
    } catch (e) {
      debugPrint("Failed to save plan: $e");
    }
  }

  void _clearPlan() {
    // Just return to form view
    setState(() {
      _generatedPlan = null;
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return "$day/$month/$year";
  }

  void _generatePlan() async {
    setState(() {
      _isGenerating = true;
    });

    final input = DatePlannerInput(
      startTime: _startTime,
      totalDurationHours: _durationHours,
      area: _areaController.text.trim().isEmpty ? "Quận 1" : _areaController.text.trim(),
      budgetPerPerson: _budgetPerPerson,
      vibe: _selectedVibe,
      stageCount: _stageCount,
      transportation: _transportation,
      preferences: const [],
    );

    try {
      final plan = await DatePlannerGenerator.generate(input);
      if (mounted) {
        _savePlan(plan);
        setState(() {
          _generatedPlan = plan;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _sharePlanText(DatePlan plan) {
    final buffer = StringBuffer();
    buffer.writeln("✨ KẾ HOẠCH HẸN HÒ: ${plan.dateType} ${plan.emoji} ✨");
    buffer.writeln("📅 Ngày hẹn: ${_formatDate(_selectedDate)}");
    buffer.writeln("⏱️ Tổng thời lượng: ${plan.totalDurationMinutes} phút ($_durationHours tiếng)");
    buffer.writeln("📍 Khu vực: ${_areaController.text}");
    buffer.writeln("🏍️ Phương tiện: ${_transportation == 'walking' ? 'Đi bộ' : _transportation == 'motorbike' ? 'Xe máy' : 'Taxi'}\n");
    buffer.writeln("📜 Lời thề hẹn hò: \"${plan.oath}\"\n");
    buffer.writeln("-----------------------------------------");

    for (var stage in plan.stages) {
      buffer.writeln("📍 Chặng ${stage.stageNum}: ${stage.title}");
      buffer.writeln("⏰ Thời gian: ${stage.startTime} - ${stage.endTime} (${stage.durationMinutes} phút)");
      buffer.writeln("🎯 Mục tiêu: ${stage.purpose}");
      buffer.writeln("🍴 Thể loại gợi ý: ${stage.category}");
      
      if (stage.options.isNotEmpty) {
        buffer.writeln("📍 Địa điểm gợi ý:");
        for (var opt in stage.options) {
          buffer.writeln("  • ${opt.name} - ${opt.address}");
        }
      }
      buffer.writeln("✨ Hoạt động gợi ý:");
      for (var task in stage.tasks) {
        buffer.writeln("  • $task");
      }
      buffer.writeln("💡 Mách nhỏ:");
      for (var tip in stage.tips) {
        buffer.writeln("  • $tip");
      }
      buffer.writeln("-----------------------------------------");
    }
    buffer.writeln("\n💬 \"${plan.endingQuote}\"");
    buffer.writeln("👉 Tạo kế hoạch hẹn hò của riêng bạn trên app EverUs!");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép lộ trình vào bộ nhớ tạm!'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  String _formatBudget(int val) {
    if (val >= 1000000) {
      return "${(val / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M VND";
    }
    return "${(val / 1000).toStringAsFixed(0)}K VND";
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_isGenerating) {
      body = _buildGeneratingView();
    } else if (_generatedPlan != null) {
      body = _buildResultsView(_generatedPlan!);
    } else {
      body = _buildInputFormView();
    }

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
              // Top Bar
              _buildAppBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isViewingResult = _generatedPlan != null && !_isGenerating;
    return Padding(
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
              onPressed: () {
                if (isViewingResult) {
                  _clearPlan();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isViewingResult ? 'Lộ Trình Hẹn Hò' : 'Thiết Kế Hẹn Hò',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          if (isViewingResult)
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
                icon: const Icon(Icons.share_outlined, color: Color(0xFFEC4899)),
                onPressed: () => _sharePlanText(_generatedPlan!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot Pulse
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFBCFE8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "🧭",
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'EverUs đang lên lộ trình...',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'Tụi mình đang cân đối thời gian, sắp xếp thứ tự các chặng và lồng ghép các gợi ý hoạt động thú vị cho hai bạn đó!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                backgroundColor: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFormView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          _buildFormHeaderCard(),
          const SizedBox(height: 16),

          // Section 1: Thời gian & Không gian
          _buildSectionCard(
            title: "⏱️ Thời Gian & Địa Điểm",
            children: [
              // Date picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Ngày hẹn hò",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_selectedDate),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Start time picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Thời gian bắt đầu",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _selectStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Text(
                            _startTime.format(context),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Tổng thời lượng hẹn hò",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_durationHours.toStringAsFixed(1)} tiếng",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _durationHours,
                    min: 2.0,
                    max: 6.0,
                    divisions: 8, // increments of 0.5h
                    activeColor: const Color(0xFFEC4899),
                    inactiveColor: const Color(0xFFFBCFE8),
                    onChanged: (val) {
                      setState(() {
                        _durationHours = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Area input
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Khu vực muốn hẹn hò",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      hintText: "Ví dụ: Quận 1, TP. HCM",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF8B5CF6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Lưu ý: Bạn vui lòng điền cụ thể Quận/Huyện và Tỉnh/Thành phố (với càng nhiều chi tiết càng tốt) để EverUs định vị và lên lộ trình chính xác nhất.",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF7C7289),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 2: Vibe & Budget
          _buildSectionCard(
            title: "🎭 Thiết Lập Trải Nghiệm",
            children: [
              // Vibe Selection
              Text(
                "Tâm trạng & Vibe của buổi hẹn",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              RadioGroup<String>(
                groupValue: _selectedVibe,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedVibe = val;
                    });
                  }
                },
                child: Column(
                  children: _vibesInfo.entries.map((entry) {
                    final isSelected = _selectedVibe == entry.key;
                    final info = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFDF4FF) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFEC4899) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedVibe = entry.key;
                          });
                        },
                        leading: Text(info['emoji']!, style: const TextStyle(fontSize: 24)),
                        title: Text(
                          info['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        subtitle: Text(
                          info['desc']!,
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                        ),
                        trailing: Radio<String>(
                          value: entry.key,
                          activeColor: const Color(0xFFEC4899),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Budget Per Person
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Ngân sách tối đa / người",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatBudget(_budgetPerPerson),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _budgetPerPerson.toDouble(),
                min: 100000,
                max: 1000000,
                divisions: 9, // steps of 100k
                activeColor: const Color(0xFF8B5CF6),
                inactiveColor: const Color(0xFFDDD6FE),
                onChanged: (val) {
                  setState(() {
                    _budgetPerPerson = val.round();
                  });
                },
              ),
              // Preset Budget chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [150000, 300000, 500000, 800000].map((budget) {
                  final isSelected = _budgetPerPerson == budget;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _budgetPerPerson = budget;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEDE9FE) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _formatBudget(budget),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF6D28D9) : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 3: Transport
          _buildSectionCard(
            title: "🚗 Phương Tiện Di Chuyển",
            children: [
              // Transportation
              Text(
                "Phương tiện di chuyển chính",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTransportOption('walking', '🚶 Đi bộ'),
                  const SizedBox(width: 8),
                  _buildTransportOption('motorbike', '🏍️ Xe máy'),
                  const SizedBox(width: 8),
                  _buildTransportOption('taxi', '🚕 Taxi'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // View Saved Plan Button
          if (_savedPlan != null) ...[
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _generatedPlan = _savedPlan;
                });
              },
              icon: const Icon(Icons.history),
              label: const Text('Xem lại kế hoạch gần nhất'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Generate Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _generatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded),
                  const SizedBox(width: 10),
                  Text(
                    'LẬP KẾ HOẠCH HẸN HÒ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTransportOption(String value, String label) {
    final isSelected = _transportation == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _transportation = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEDE9FE) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF6D28D9) : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lên Lịch Hẹn Hò',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trả lời một vài câu hỏi nhanh để nhận lộ trình hẹn hò tối ưu hóa cho hai bạn.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "🧭",
            style: TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResultsView(DatePlan plan) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [plan.theme.primary, plan.theme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: plan.theme.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DATE TYPE SUGGESTION",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(plan.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        plan.dateType,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildResultMetaBadge(
                      icon: Icons.calendar_month_outlined,
                      label: _formatDate(_selectedDate),
                    ),
                    _buildResultMetaBadge(
                      icon: Icons.timer_outlined,
                      label: "${plan.totalDurationMinutes} phút (~${_durationHours.toStringAsFixed(1)}h)",
                    ),
                    _buildResultMetaBadge(
                      icon: Icons.location_on_outlined,
                      label: _areaController.text.trim().isEmpty ? "Khu vực tự do" : _areaController.text.trim(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Oath Commitment
          _buildOathCard(plan),
          const SizedBox(height: 20),

          // Stages List Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Text(
              'LỘ TRÌNH CHI TIẾT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF7C7289),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Vertical Timeline of Stages
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plan.stages.length,
            itemBuilder: (context, index) {
              final stage = plan.stages[index];
              return _buildTimelineStageItem(stage, plan.theme, index == plan.stages.length - 1);
            },
          ),

          // Plan Ending Card
          _buildEndingQuoteCard(plan),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearPlan,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'THIẾT LẬP LẠI',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _sharePlanText(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.copy, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SAO CHÉP LỘ TRÌNH',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildResultMetaBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOathCard(DatePlan plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: plan.theme.primary.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("📜", style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                "Lời Thề Hẹn Hò",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: plan.theme.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${plan.oath}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStageItem(DateStage stage, ActivityTheme theme, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side timeline graphic
          Column(
            children: [
              // Circle number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.light,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primary, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${stage.stageNum}",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
              // Line down
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.primary.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Stage Detail Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card header: Title and Time Range
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.light.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              stage.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.dark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${stage.startTime} - ${stage.endTime}",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Card body
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Metadata: Role & Category
                          _buildDetailRow("🎯 Mục đích", stage.purpose),
                          const SizedBox(height: 8),
                          _buildDetailRow("🍴 Thể loại", stage.category),
                          const SizedBox(height: 8),
                          _buildDetailRow("⏱️ Thời lượng", "${stage.durationMinutes} phút"),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Color(0xFFF3F4F6)),
                          ),

                          // Interactive tasks list
                          Text(
                            "✨ Hoạt động gợi ý",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.dark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...stage.tasks.map((task) => _buildInteractiveTaskItem(task, theme)),

                          // Locations
                          if (stage.options.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(color: Color(0xFFF3F4F6)),
                            ),
                            Text(
                              "📍 Địa điểm gợi ý",
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.dark),
                            ),
                            const SizedBox(height: 6),
                            ...stage.options.map((opt) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opt.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(opt.address, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final url = Uri.parse(opt.mapsUrl);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
                                    icon: const Icon(Icons.map, size: 16),
                                    label: const Text('Mở bản đồ'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                  )
                                ],
                              ),
                            )),
                          ],

                          // Tips
                          if (stage.tips.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              "💡 Mách Nhỏ Cho Hai Bạn",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.accent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...stage.tips.map((tip) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("• ", style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF4B5563),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveTaskItem(String task, ActivityTheme theme) {
    return _InteractiveTaskWidget(task: task, theme: theme);
  }

  Widget _buildEndingQuoteCard(DatePlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: plan.theme.light.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: plan.theme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const Text("💬", style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            plan.endingQuote,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: plan.theme.dark,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Statefull widget for tasks checklist to support checking off tasks interactively
class _InteractiveTaskWidget extends StatefulWidget {
  final String task;
  final ActivityTheme theme;

  const _InteractiveTaskWidget({required this.task, required this.theme});

  @override
  State<_InteractiveTaskWidget> createState() => _InteractiveTaskWidgetState();
}

class _InteractiveTaskWidgetState extends State<_InteractiveTaskWidget> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _checked = !_checked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              _checked ? Icons.check_box_outlined : Icons.check_box_outline_blank,
              size: 20,
              color: _checked ? widget.theme.primary : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.task,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _checked ? Colors.grey.shade400 : const Color(0xFF374151),
                  decoration: _checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
