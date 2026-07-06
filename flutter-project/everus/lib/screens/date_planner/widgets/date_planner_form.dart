import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/date_plan.dart';
import '../../../widgets/preference_matcher.dart'; // For GlassCard
import '../../../utils/auth_helper.dart';
import '../../saved_plans_screen.dart';
import '../date_planner_controller.dart';

/// Form widget displaying the date planning inputs (date, time, vibe, budget, transport).
class DatePlannerForm extends StatelessWidget {
  /// The state controller managing parameters and lifecycle.
  final DatePlannerController controller;

  /// Const constructor for [DatePlannerForm].
  const DatePlannerForm({super.key, required this.controller});

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return "$day/$month/$year";
  }

  String _formatBudget(int val) {
    if (val >= 1000000) {
      return "${(val / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M VND";
    }
    return "${(val / 1000).toStringAsFixed(0)}K VND";
  }

  // Vibes metadata
  static const Map<String, Map<String, String>> _vibesInfo = {
    'casual': {'label': 'Đời thường', 'emoji': '🍃', 'desc': 'Trà chiều, đi dạo & những điều bình dị'},
    'romantic': {'label': 'Lãng mạn', 'emoji': '💖', 'desc': 'Ánh nến, hoàng hôn & kết nối ngọt ngào'},
    'adventure': {'label': 'Trải nghiệm', 'emoji': '⚡', 'desc': 'Trò chơi, khám phá & phiêu lưu cùng nhau'},
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeaderCard(),
          const SizedBox(height: 16),

          // Section 1: Thời gian & Địa điểm
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
                    onTap: () => _selectDate(context),
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
                            _formatDate(controller.selectedDate),
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
                    onTap: () => _selectStartTime(context),
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
                            controller.startTime.format(context),
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
                        "${controller.durationHours.toStringAsFixed(1)} tiếng",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: controller.durationHours,
                    min: 2.0,
                    max: 6.0,
                    divisions: 8,
                    activeColor: const Color(0xFFEC4899),
                    inactiveColor: const Color(0xFFFBCFE8),
                    onChanged: (val) {
                      controller.setDurationHours(val);
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
                    controller: controller.areaController,
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
                    "Lưu ý: EverUs hiện tại hỗ trợ tốt nhất các địa điểm thuộc khu vực TP. Hồ Chí Minh. Vui lòng nhập khu vực để tụi mình lên lộ trình chính xác nhất nhé!",
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
              Text(
                "Tâm trạng & Vibe của buổi hẹn",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 10),
              // Render vibes custom list instead of RadioGroup widget to avoid dependency compiler issues
              RadioGroup<String>(
                groupValue: controller.selectedVibe,
                onChanged: (val) {
                  if (val != null) {
                    controller.setSelectedVibe(val);
                  }
                },
                child: Column(
                  children: _vibesInfo.entries.map((entry) {
                    final isSelected = controller.selectedVibe == entry.key;
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
                          controller.setSelectedVibe(entry.key);
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

              // Budget Slider
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
                    _formatBudget(controller.budgetPerPerson),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              Slider(
                value: controller.budgetPerPerson.toDouble(),
                min: 100000,
                max: 1000000,
                divisions: 9,
                activeColor: const Color(0xFF8B5CF6),
                inactiveColor: const Color(0xFFDDD6FE),
                onChanged: (val) {
                  controller.setBudgetPerPerson(val.round());
                },
              ),
              // Preset Budget chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [150000, 300000, 500000, 800000].map((budget) {
                  final isSelected = controller.budgetPerPerson == budget;
                  return InkWell(
                    onTap: () {
                      controller.setBudgetPerPerson(budget);
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

          // History/Load previous options
          if (AuthHelper.isLoggedIn) ...[
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  final selectedPlan = await Navigator.push<DatePlan>(
                    context,
                    MaterialPageRoute(builder: (context) => const SavedPlansScreen()),
                  );
                  if (selectedPlan != null) {
                    controller.setGeneratedPlan(selectedPlan);
                  }
                },
                icon: const Icon(Icons.history, color: Color(0xFF8B5CF6), size: 18),
                label: Text(
                  'Xem kế hoạch trước đây',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else if (controller.savedPlan != null) ...[
            Center(
              child: TextButton.icon(
                onPressed: () {
                  controller.setGeneratedPlan(controller.savedPlan);
                },
                icon: const Icon(Icons.history, color: Color(0xFF8B5CF6), size: 18),
                label: Text(
                  'Xem lại kế hoạch gần nhất',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit Button
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
              onPressed: () => _handleSubmit(context),
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

  void _handleSubmit(BuildContext context) async {
    try {
      await controller.generatePlan();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildTransportOption(String value, String label) {
    final isSelected = controller.transportation == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.setTransportation(value);
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
      enableBlur: false,
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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
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
      controller.setSelectedDate(picked);
    }
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.startTime,
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
      controller.setStartTime(picked);
    }
  }
}
