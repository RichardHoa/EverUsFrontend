import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/activity.dart'; // For ActivityTheme
import '../../../models/date_plan.dart';
import '../../../utils/auth_helper.dart';
import '../../create_invite_screen.dart';
import '../../saved_plans_screen.dart';
import '../date_planner_controller.dart';

/// Renders the generated date plan itinerary, with timeline stages and maps links.
class DatePlannerResults extends StatefulWidget {
  /// The state controller driving the data.
  final DatePlannerController controller;

  /// Const constructor for [DatePlannerResults].
  const DatePlannerResults({super.key, required this.controller});

  @override
  State<DatePlannerResults> createState() => _DatePlannerResultsState();
}

class _DatePlannerResultsState extends State<DatePlannerResults> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Auto-scroll to top when loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return "$day/$month/$year";
  }

  void _sharePlanText(DatePlan plan) {
    final buffer = StringBuffer();
    buffer.writeln("✨ KẾ HOẠCH HẸN HÒ: ${plan.dateType} ${plan.emoji} ✨");
    buffer.writeln("📅 Ngày hẹn: ${_formatDate(widget.controller.selectedDate)}");
    buffer.writeln("⏱️ Tổng thời lượng: ${plan.totalDurationMinutes} phút (~${(plan.totalDurationMinutes / 60.0).toStringAsFixed(1)} tiếng)");
    buffer.writeln("📍 Khu vực: ${widget.controller.areaController.text}");
    buffer.writeln("🏍️ Phương tiện: ${widget.controller.transportation == 'walking' ? 'Đi bộ' : widget.controller.transportation == 'motorbike' ? 'Xe máy' : 'Taxi'}\n");
    buffer.writeln("🎯 Mục tiêu buổi hẹn: ${plan.purpose}\n");
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
    buffer.writeln("👉 Tạo kế hoạch hẹn hò của riêng bạn trên app EverUs!");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép lộ trình vào bộ nhớ tạm!'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.controller.generatedPlan;
    if (plan == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Theme Header Card
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
                      label: _formatDate(widget.controller.selectedDate),
                    ),
                    _buildResultMetaBadge(
                      icon: Icons.timer_outlined,
                      label: "${plan.totalDurationMinutes} phút (~${(plan.totalDurationMinutes / 60.0).toStringAsFixed(1)}h)",
                    ),
                    _buildResultMetaBadge(
                      icon: Icons.location_on_outlined,
                      label: (plan.area != null && plan.area!.isNotEmpty)
                          ? plan.area!
                          : (widget.controller.areaController.text.trim().isEmpty ? "Khu vực tự do" : widget.controller.areaController.text.trim()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Purpose Card
          _buildPurposeCard(plan),
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
              final isLast = index == plan.stages.length - 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimelineStageItem(stage, plan.theme, isLast),
                  if (!isLast && stage.transitDurationMinutes != null && stage.transitDurationMinutes! > 0)
                    _buildTransitTimelineItem(
                      stage.transitDistanceKm ?? 0.0,
                      stage.transitDurationMinutes ?? 0,
                      plan.theme,
                      widget.controller.transportation,
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          
          if (plan.googleMapsRouteUrl != null && plan.googleMapsRouteUrl!.isNotEmpty) ...[
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(plan.googleMapsRouteUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.map, size: 20),
              label: Text(
                'MỞ BẢN ĐỒ TOÀN LỘ TRÌNH',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildInvitationSection(plan),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactActionButton(
                icon: Icons.restart_alt,
                label: 'Tạo lại',
                onTap: widget.controller.clearPlan,
              ),
              _buildCompactActionButton(
                icon: Icons.content_copy,
                label: 'Sao chép',
                onTap: () => _sharePlanText(plan),
              ),
              if (AuthHelper.isLoggedIn)
                _buildCompactActionButton(
                  icon: Icons.history,
                  label: 'Lịch sử',
                  onTap: () async {
                    final selectedPlan = await Navigator.push<DatePlan>(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedPlansScreen()),
                    );
                    if (selectedPlan != null) {
                      widget.controller.setGeneratedPlan(selectedPlan);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _openCreateInviteScreen(DatePlan plan) async {
    final firstStage = plan.stages.isNotEmpty ? plan.stages.first : null;
    final locationName = firstStage?.options.isNotEmpty == true
        ? firstStage!.options.first.name
        : ((plan.area != null && plan.area!.isNotEmpty)
            ? plan.area!
            : widget.controller.areaController.text.trim());
    final startTimeStr = firstStage?.startTime ?? '18:00';

    final resultUrl = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInviteScreen(
          activityKey: plan.vibe,
          activityName: plan.dateType,
          initialDate: widget.controller.selectedDate,
          initialTime: startTimeStr,
          initialLocation: locationName.isNotEmpty ? locationName : "Khu vực trung tâm",
          duration: "${(plan.totalDurationMinutes / 60.0).toStringAsFixed(1)} tiếng",
          primaryColor: plan.theme.primary,
          secondaryColor: plan.theme.secondary,
          planId: plan.id,
          existingInviteUrl: widget.controller.existingInviteUrl,
        ),
      ),
    );

    if (resultUrl != null && plan.id != null) {
      widget.controller.checkExistingInvitation(plan.id!);
    }
  }

  Widget _buildInvitationSection(DatePlan plan) {
    if (widget.controller.inviteAccepted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lời mời đã được chấp nhận! 🎉',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đối phương đã đồng ý tham gia buổi hẹn hò này.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final bool hasInvite = widget.controller.existingInviteUrl != null && widget.controller.existingInviteUrl!.isNotEmpty;

    return ElevatedButton.icon(
      onPressed: () => _openCreateInviteScreen(plan),
      icon: Icon(hasInvite ? Icons.mark_email_read_outlined : Icons.favorite_rounded, size: 20),
      label: Text(
        hasInvite ? 'XEM / GỬI LẠI LỜI MỜI HẸN HÒ' : 'GỬI LỜI MỜI HẸN HÒ 💌',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: hasInvite ? const Color(0xFF10B981) : const Color(0xFFEC4899),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
    );
  }


  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
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

  Widget _buildPurposeCard(DatePlan plan) {
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
              const Text("🎯", style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                "Mục Tiêu Buổi Hẹn",
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
            plan.purpose,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
          Column(
            children: [
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
                              maxLines: 2,
                              softWrap: true,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("🎯 Mục đích", stage.purpose),
                          const SizedBox(height: 8),
                          _buildDetailRow("🍴 Thể loại", stage.category),
                          const SizedBox(height: 8),
                          _buildDetailRow("⏱️ Thời lượng", "${stage.durationMinutes} phút"),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Color(0xFFF3F4F6)),
                          ),

                          Text(
                            "✨ Hoạt động gợi ý",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.dark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...stage.tasks.map((task) => _InteractiveTaskWidget(task: task, theme: theme)),

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
                            _buildLocationCard(stage, stage.options.first, theme, isBackup: false),
                            
                            if (stage.options.length > 1) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    widget.controller.toggleStageBackupExpanded(stage.stageNum);
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.assistant_navigation, size: 16, color: theme.accent),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Lựa chọn dự phòng khác (${stage.options.length - 1})",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: theme.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        widget.controller.expandedStageBackups.contains(stage.stageNum)
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                        size: 18,
                                        color: theme.accent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.controller.expandedStageBackups.contains(stage.stageNum)) ...[
                                const SizedBox(height: 8),
                                ...stage.options.skip(1).map(
                                  (opt) => _buildLocationCard(stage, opt, theme, isBackup: true)
                                ),
                              ],
                            ],
                          ],

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

  Widget _buildLocationCard(DateStage stage, LocationOption opt, ActivityTheme theme, {bool isBackup = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBackup 
            ? Colors.grey.withValues(alpha: 0.3)
            : theme.primary.withValues(alpha: 0.3)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: (opt.thumbnailUrl != null && opt.thumbnailUrl!.isNotEmpty)
              ? Image.network(
                  opt.thumbnailUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B5CF6)),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: const Color(0xFFF3F4F6),
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                    ),
                  ),
                )
              : Container(
                  height: 150,
                  color: const Color(0xFFF3F4F6),
                  child: Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                  ),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBackup) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "LỰA CHỌN DỰ PHÒNG",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(opt.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  opt.address.isNotEmpty ? opt.address : "Khu vực trung tâm, Hồ Chí Minh",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.sell, color: theme.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "Khoảng giá: ${opt.priceLevel != null && opt.priceLevel!.isNotEmpty ? opt.priceLevel : 'Chưa cập nhật'}",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                    ),
                  ],
                ),
                if (opt.rating != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${opt.rating} (${opt.ratingCount ?? 0} đánh giá)",
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
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
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (isBackup) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.controller.selectBackupLocation(stage, opt);
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Đặt làm chính'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildTransitTimelineItem(double distance, int duration, ActivityTheme theme, String transport) {
    String transportEmoji = "🏍️";
    if (transport == "walking") {
      transportEmoji = "🚶";
    } else if (transport == "taxi") {
      transportEmoji = "🚖";
    }
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Center(
              child: Container(
                width: 2,
                color: theme.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.light.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(transportEmoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          "Di chuyển: ~ ${distance.toStringAsFixed(1)} km (~$duration phút)",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
}

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
