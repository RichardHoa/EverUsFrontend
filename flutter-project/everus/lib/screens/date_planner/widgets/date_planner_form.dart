import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/date_plan.dart';
import '../../../utils/auth_helper.dart';
import '../../../utils/distance_preference.dart';
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
    'casual': {'label': 'Đời thường', 'desc': 'Trà chiều, đi dạo & những điều bình dị'},
    'romantic': {'label': 'Lãng mạn', 'desc': 'Ánh nến, hoàng hôn & kết nối ngọt ngào'},
    'adventure': {'label': 'Trải nghiệm', 'desc': 'Trò chơi, khám phá & phiêu lưu cùng nhau'},
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
            title: "Thời Gian & Địa Điểm",
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
                        color: const Color(0xFF5A384C),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2D6E0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDate(controller.selectedDate),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5A384C),
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
                        color: const Color(0xFF5A384C),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectStartTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2D6E0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.startTime.format(context),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5A384C),
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
                            color: const Color(0xFF5A384C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${controller.durationHours.toStringAsFixed(1)} tiếng",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF653851),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: controller.durationHours,
                    min: 2.0,
                    max: 6.0,
                    divisions: 8,
                    activeColor: const Color(0xFF653851),
                    inactiveColor: const Color(0xFFE2D6E0),
                    onChanged: (val) {
                      controller.setDurationHours(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Where the user is, and how far they are willing to go
              _buildLocationInput(),
              const SizedBox(height: 16),
              Text(
                "Khoảng cách",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A384C),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final choice in DistanceChoice.values) ...[
                    if (choice != DistanceChoice.values.first) const SizedBox(width: 8),
                    _buildDistanceOption(choice),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section 2: Vibe & Budget
          _buildSectionCard(
            title: "Thiết Lập Trải Nghiệm",
            children: [
              Text(
                "Tâm trạng & Vibe của buổi hẹn",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A384C),
                ),
              ),
              const SizedBox(height: 10),
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
                      child: Material(
                        color: isSelected ? const Color(0xFFF7EFF5) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? const Color(0xFF653851) : const Color(0xFFE2D6E0),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            onTap: () {
                              controller.setSelectedVibe(entry.key);
                            },
                            title: Text(
                              info['label']!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5A384C),
                              ),
                            ),
                            subtitle: Text(
                              info['desc']!,
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7C6E79)),
                            ),
                            trailing: Radio<String>(
                              value: entry.key,
                              activeColor: const Color(0xFF653851),
                            ),
                          ),
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
                        color: const Color(0xFF5A384C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatBudget(controller.budgetPerPerson),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF653851),
                    ),
                  ),
                ],
              ),
              Slider(
                value: controller.budgetPerPerson.toDouble(),
                min: 100000,
                max: 1000000,
                divisions: 9,
                activeColor: const Color(0xFF653851),
                inactiveColor: const Color(0xFFE2D6E0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF653851) : Colors.white.withValues(alpha: 0.8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF653851) : const Color(0xFFE2D6E0),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _formatBudget(budget),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF5A384C),
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
            title: "Phương Tiện Di Chuyển",
            children: [
              Text(
                "Phương tiện di chuyển chính",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A384C),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTransportOption('walking', 'Đi bộ'),
                  const SizedBox(width: 8),
                  _buildTransportOption('motorbike', 'Xe máy'),
                  const SizedBox(width: 8),
                  _buildTransportOption('taxi', 'Taxi'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // History/Load previous options
          if (AuthHelper.isLoggedIn) ...[
            Center(
              child: TextButton(
                onPressed: () async {
                  final selectedPlan = await Navigator.push<DatePlan>(
                    context,
                    MaterialPageRoute(builder: (context) => const SavedPlansScreen()),
                  );
                  if (selectedPlan != null) {
                    controller.setGeneratedPlan(selectedPlan);
                  }
                },
                child: Text(
                  'Xem kế hoạch trước đây',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF653851),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else if (controller.savedPlan != null) ...[
            Center(
              child: TextButton(
                onPressed: () {
                  controller.setGeneratedPlan(controller.savedPlan);
                },
                child: Text(
                  'Xem lại kế hoạch gần nhất',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF653851),
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
                  color: const Color(0xFF5A384C).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _handleSubmit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF653851),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'LẬP KẾ HOẠCH HẸN HÒ',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for floating bottom bar
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
            color: isSelected ? const Color(0xFF653851) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF653851) : const Color(0xFFE2D6E0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF5A384C),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    final location = controller.userLocation;
    final String status;
    if (controller.isLocating) {
      status = 'Đang xác định vị trí...';
    } else if (location != null) {
      status = location.label ?? 'Đã lấy vị trí hiện tại của bạn';
    } else if (controller.locationPermissionDenied) {
      status = 'Không truy cập được vị trí. Nhập địa chỉ bạn muốn xuất phát nhé!';
    } else {
      status = 'EverUs cần vị trí để tìm địa điểm gần bạn.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Vị trí của bạn",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A384C),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: controller.isLocating ? null : controller.useCurrentLocation,
              icon: const Icon(Icons.my_location, size: 16, color: Color(0xFF653851)),
              label: Text(
                'Dùng vị trí hiện tại',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF653851)),
              ),
            ),
          ],
        ),
        Text(
          status,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7C6E79), height: 1.4),
        ),
        if (controller.locationPermissionDenied) ...[
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('manual-address-field'),
            controller: controller.addressController,
            textInputAction: TextInputAction.search,
            onSubmitted: controller.setManualAddress,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF5A384C)),
            decoration: InputDecoration(
              hintText: 'VD: 45 Lê Lợi, Quận 1',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffix: TextButton(
                onPressed: controller.isLocating
                    ? null
                    : () => controller.setManualAddress(controller.addressController.text),
                child: Text('Tìm', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF653851))),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2D6E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2D6E0)),
              ),
            ),
          ),
        ],
        if (controller.locationError != null) ...[
          const SizedBox(height: 6),
          Text(
            controller.locationError!,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade700),
          ),
        ],
      ],
    );
  }

  Widget _buildDistanceOption(DistanceChoice choice) {
    final isSelected = controller.distanceChoice == choice;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setDistanceChoice(choice),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF653851) : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF653851) : const Color(0xFFE2D6E0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                choice.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF5A384C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                choice.hint,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF7C6E79),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF653851),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A384C).withValues(alpha: 0.15),
            blurRadius: 16,
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
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A384C).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A384C),
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
              primary: Color(0xFF653851),
              onPrimary: Colors.white,
              onSurface: Color(0xFF5A384C),
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
              primary: Color(0xFF653851),
              onPrimary: Colors.white,
              onSurface: Color(0xFF5A384C),
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
