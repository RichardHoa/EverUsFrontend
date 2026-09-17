import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/date_plan.dart';
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
                          const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF653851)),
                          const SizedBox(width: 8),
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
                          const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF653851)),
                          const SizedBox(width: 8),
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

              // Area input
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Khu vực muốn hẹn hò",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A384C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DistrictAutocompleteInput(controller: controller.areaController),
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
                            leading: Text(info['emoji']!, style: const TextStyle(fontSize: 24)),
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
            title: "🚗 Phương Tiện Di Chuyển",
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
                icon: const Icon(Icons.history, color: Color(0xFF653851), size: 18),
                label: Text(
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
              child: TextButton.icon(
                onPressed: () {
                  controller.setGeneratedPlan(controller.savedPlan);
                },
                icon: const Icon(Icons.history, color: Color(0xFF653851), size: 18),
                label: Text(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded),
                  const SizedBox(width: 10),
                  Text(
                    'LẬP KẾ HOẠCH HẸN HÒ',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
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
          const SizedBox(width: 12),
          const Text(
            "🧭",
            style: TextStyle(fontSize: 44),
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

/// Autocomplete and quick selection widget for HCMC districts.
class _DistrictAutocompleteInput extends StatefulWidget {
  final TextEditingController controller;

  const _DistrictAutocompleteInput({required this.controller});

  @override
  State<_DistrictAutocompleteInput> createState() => _DistrictAutocompleteInputState();
}

class _DistrictAutocompleteInputState extends State<_DistrictAutocompleteInput> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.text);
    widget.controller.addListener(_onExternalControllerChange);
  }

  void _onExternalControllerChange() {
    if (_textController.text != widget.controller.text) {
      _textController.text = widget.controller.text;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExternalControllerChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectDistrict(String district) {
    if (!DatePlannerController.enabledDistricts.contains(district)) {
      return;
    }
    _textController.text = district;
    widget.controller.text = district;
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<String>(
          textEditingController: _textController,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.trim();
            if (query.isEmpty) {
              return DatePlannerController.hcmcDistricts;
            }
            final normQuery = DatePlannerController.removeDiacritics(query.toLowerCase());
            return DatePlannerController.hcmcDistricts.where((district) {
              final normDistrict = DatePlannerController.removeDiacritics(district.toLowerCase());
              return normDistrict.contains(normQuery) || district.toLowerCase().contains(query.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _selectDistrict(selection);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: fieldController,
              builder: (context, value, child) {
                final hasText = value.text.isNotEmpty;
                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  onChanged: (val) {
                    widget.controller.text = val;
                  },
                  decoration: InputDecoration(
                    hintText: "Chọn địa điểm",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF653851)),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                            onPressed: () {
                              fieldController.clear();
                              widget.controller.clear();
                              setState(() {});
                            },
                          )
                        : const Icon(Icons.keyboard_arrow_down, color: Color(0xFF653851)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2D6E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2D6E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF653851), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                );
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6.0,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260, maxWidth: 330),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2D6E0)),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      final isEnabled = DatePlannerController.enabledDistricts.contains(option);
                      final isCurrent = widget.controller.text.trim() == option;
                      return InkWell(
                        onTap: isEnabled
                            ? () {
                                onSelected(option);
                              }
                            : null,
                        child: Container(
                          color: isCurrent && isEnabled ? const Color(0xFFF7EFF5) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                isEnabled ? Icons.location_city_rounded : Icons.lock_outline_rounded,
                                size: 18,
                                color: !isEnabled
                                    ? const Color(0xFFD1D5DB)
                                    : (isCurrent ? const Color(0xFF653851) : const Color(0xFF7C6E79)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: !isEnabled
                                        ? const Color(0xFF9CA3AF)
                                        : (isCurrent ? const Color(0xFF653851) : const Color(0xFF5A384C)),
                                  ),
                                ),
                              ),
                              if (isEnabled)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7EFF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Khả dụng",
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF653851),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Sắp hỗ trợ",
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // Informative note
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 13, color: Color(0xFF653851)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                "Hiện tại EverUs hỗ trợ Quận 1, Quận 7, Quận 10 và Quận Bình Thạnh. Các quận khác sẽ được cập nhật trong thời gian tới.",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
