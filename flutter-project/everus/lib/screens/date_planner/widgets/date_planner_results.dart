import 'package:flutter/foundation.dart';
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

  /// Opens a maps link; defaults to the platform URL launcher (overridable in tests).
  final Future<void> Function(Uri url)? openUrl;

  /// Const constructor for [DatePlannerResults].
  const DatePlannerResults({super.key, required this.controller, this.openUrl});

  @override
  State<DatePlannerResults> createState() => _DatePlannerResultsState();
}

class _DatePlannerResultsState extends State<DatePlannerResults> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.controller.loadPreferences();

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

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (widget.openUrl != null) {
      await widget.openUrl!(uri);
    } else if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _areaLabel(DatePlan plan) =>
      (plan.area != null && plan.area!.isNotEmpty) ? plan.area! : 'Gần bạn';

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

  void _sharePlanText(DatePlan plan) {
    final buffer = StringBuffer();
    buffer.writeln("✨ KẾ HOẠCH HẸN HÒ: ${plan.dateType} ${plan.emoji} ✨");
    buffer.writeln("📅 Ngày hẹn: ${_formatDate(widget.controller.selectedDate)}");
    buffer.writeln("⏱️ Tổng thời lượng: ${plan.totalDurationMinutes} phút (~${(plan.totalDurationMinutes / 60.0).toStringAsFixed(1)} tiếng)");
    final budgetVal = plan.budgetPerPerson ?? widget.controller.budgetPerPerson;
    if (budgetVal > 0) {
      buffer.writeln("💰 Ngân sách: ${_formatBudget(budgetVal)} / người");
    }
    buffer.writeln("📍 Khu vực: ${_areaLabel(plan)}");
    buffer.writeln("🏍️ Phương tiện: ${widget.controller.transportation == 'walking' ? 'Đi bộ' : widget.controller.transportation == 'motorbike' ? 'Xe máy' : 'Taxi'}\n");
    buffer.writeln("🎯 Mục tiêu buổi hẹn: ${plan.purpose}\n");
    buffer.writeln("-----------------------------------------");

    for (var stage in plan.stages) {
      buffer.writeln("📍 Chặng ${stage.stageNum}: ${stage.title}");
      buffer.writeln("⏰ Thời gian: ${stage.startTime} - ${stage.endTime} (${stage.durationMinutes} phút)");
      buffer.writeln("🎯 Mục tiêu: ${stage.purpose}");
      buffer.writeln("🍴 Thể loại: ${stage.category}");
      
      if (stage.options.isNotEmpty) {
        final pickedOpt = stage.options.first;
        final priceText = pickedOpt.formattedPriceRange.isNotEmpty ? " (${pickedOpt.formattedPriceRange})" : "";
        buffer.writeln("📍 Địa điểm: ${pickedOpt.name}$priceText");
        if (pickedOpt.address.isNotEmpty) {
          buffer.writeln("   Địa chỉ: ${pickedOpt.address}");
        }
        if (pickedOpt.mapsUrl.isNotEmpty) {
          buffer.writeln("   🗺️ Google Maps: ${pickedOpt.mapsUrl}");
        }
      }
      buffer.writeln("✨ Hoạt động gợi ý:");
      for (var task in stage.tasks) {
        buffer.writeln("  • $task");
      }
      if (stage.tips.isNotEmpty) {
        buffer.writeln("💡 Mách nhỏ:");
        for (var tip in stage.tips) {
          buffer.writeln("  • $tip");
        }
      }
      buffer.writeln("-----------------------------------------");
    }
    buffer.writeln("👉 Tạo kế hoạch hẹn hò của riêng bạn trên app EverUs!");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép lộ trình vào bộ nhớ tạm!'),
        backgroundColor: Color(0xFF653851),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 96.0),
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
                    _buildResultMetaBadge(label: _formatDate(widget.controller.selectedDate)),
                    _buildResultMetaBadge(
                      label: "${plan.totalDurationMinutes} phút (~${(plan.totalDurationMinutes / 60.0).toStringAsFixed(1)}h)",
                    ),
                    _buildResultMetaBadge(label: _areaLabel(plan)),
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
                color: const Color(0xFF5A384C),
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
            ElevatedButton(
              onPressed: () => _openUrl(plan.googleMapsRouteUrl!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF653851),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Text(
                'MỞ BẢN ĐỒ TOÀN LỘ TRÌNH',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
                label: 'Tạo lại',
                onTap: () async {
                  try {
                    await widget.controller.generatePlan();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không thể tạo lại kế hoạch: $e')),
                      );
                    }
                  }
                },
              ),
              _buildCompactActionButton(
                label: 'Sao chép',
                onTap: () => _sharePlanText(plan),
              ),
              if (AuthHelper.isLoggedIn)
                _buildCompactActionButton(
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
          const SizedBox(height: 100), // Space for floating bottom bar
        ],
      ),
    );
  }

  void _openCreateInviteScreen(DatePlan plan) async {
    final firstStage = plan.stages.isNotEmpty ? plan.stages.first : null;
    final locationName = firstStage?.options.isNotEmpty == true
        ? firstStage!.options.first.name
        : _areaLabel(plan);
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lời mời đã được chấp nhận!',
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

    return ElevatedButton(
      onPressed: () => _openCreateInviteScreen(plan),
      style: ElevatedButton.styleFrom(
        backgroundColor: hasInvite ? const Color(0xFF10B981) : const Color(0xFF653851),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      child: Text(
        hasInvite ? 'XEM / GỬI LẠI LỜI MỜI HẸN HÒ' : 'GỬI LỜI MỜI HẸN HÒ',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A384C).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5A384C),
          ),
        ),
      ),
    );
  }

  Widget _buildResultMetaBadge({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
          Text(
            "Mục Tiêu Buổi Hẹn",
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: plan.theme.dark,
            ),
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
    // A Stack (instead of IntrinsicHeight) lets the connector line just
    // stretch to the Row's natural height. IntrinsicHeight forces the Row
    // to a single precomputed intrinsic height, but the card content below
    // contains a Wrap (the action buttons), whose intrinsic-height
    // computation is only an approximation in Flutter and can end up a few
    // pixels shorter than the actual laid-out height once backup options
    // are expanded — causing a bottom RenderFlex overflow.
    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 15,
            top: 32,
            bottom: 0,
            child: Container(
              width: 2,
              color: theme.primary.withValues(alpha: 0.4),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A384C).withValues(alpha: 0.04),
                      blurRadius: 14,
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
                          _buildDetailRow("Mục đích", stage.purpose),
                          const SizedBox(height: 8),
                          _buildDetailRow("Thể loại", stage.category),
                          const SizedBox(height: 8),
                          _buildDetailRow("Thời lượng", "${stage.durationMinutes} phút"),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Color(0xFFF3F4F6)),
                          ),

                          Text(
                            "Hoạt động gợi ý",
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
                              "Địa điểm gợi ý",
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.dark),
                            ),
                            const SizedBox(height: 6),
                            _buildLocationCard(stage, stage.options.first, theme, isBackup: false),
                            
                            if (stage.options.length > 1) ...[
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    widget.controller.toggleStageBackupExpanded(stage.stageNum);
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.accent,
                                  side: BorderSide(color: theme.accent.withValues(alpha: 0.5)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: Icon(
                                  widget.controller.expandedStageBackups.contains(stage.stageNum)
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 18,
                                ),
                                label: Text(
                                  widget.controller.expandedStageBackups.contains(stage.stageNum)
                                      ? "Thu gọn lựa chọn dự phòng"
                                      : "Xem thêm lựa chọn dự phòng (${stage.options.length - 1})",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
                              "Mách Nhỏ Cho Hai Bạn",
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
      ],
    );
  }

  List<Widget> _buildPreferenceButtons(LocationOption opt, ActivityTheme theme) {
    final preference = widget.controller.preferenceFor(opt);
    final liked = preference == 'like';
    final disliked = preference == 'dislike';
    return [
      IconButton(
        key: ValueKey('like-${opt.id}'),
        tooltip: liked ? 'Bỏ thích' : 'Thích địa điểm này',
        visualDensity: VisualDensity.compact,
        onPressed: () => widget.controller.setPreference(opt, 'like'),
        icon: Icon(liked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 20, color: liked ? theme.primary : Colors.grey[600]),
      ),
      IconButton(
        key: ValueKey('dislike-${opt.id}'),
        tooltip: disliked ? 'Bỏ không thích' : 'Không thích địa điểm này',
        visualDensity: VisualDensity.compact,
        onPressed: () => widget.controller.setPreference(opt, 'dislike'),
        icon: Icon(disliked ? Icons.thumb_down : Icons.thumb_down_outlined, size: 20, color: disliked ? const Color(0xFF374151) : Colors.grey[600]),
      ),
    ];
  }

  Widget _buildLocationCard(DateStage stage, LocationOption opt, ActivityTheme theme, {bool isBackup = false}) {
    final card = _buildLocationCardBody(stage, opt, theme, isBackup: isBackup);
    if (!isBackup || opt.mapsUrl.isEmpty) return card;
    // Backup cards open the place in maps when tapped anywhere outside their buttons.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openUrl(opt.mapsUrl),
        child: card,
      ),
    );
  }

  Widget _buildLocationCardBody(DateStage stage, LocationOption opt, ActivityTheme theme, {bool isBackup = false}) {
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
            child: _buildThumbnailWidget(opt, theme),
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
                Text(
                  "Khoảng giá: ${opt.formattedPriceRange}",
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  overflow: TextOverflow.ellipsis,
                ),
                if (opt.rating != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Đánh giá ${opt.rating}/5 (${opt.ratingCount ?? 0} lượt)",
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (opt.id != null) ..._buildPreferenceButtons(opt, theme),
                    if (!isBackup && opt.mapsUrl.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => _openUrl(opt.mapsUrl),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primary,
                          side: BorderSide(color: theme.primary.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: Text(
                          'Xem trên bản đồ',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (isBackup)
                      ElevatedButton(
                        onPressed: () {
                          widget.controller.selectBackupLocation(stage, opt);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Đặt làm chính',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailWidget(LocationOption opt, ActivityTheme theme) {
    String? cleanUrl;
    if (opt.thumbnailUrl != null) {
      final trimmed = opt.thumbnailUrl!.trim();
      if (trimmed.isNotEmpty) {
        cleanUrl = trimmed.startsWith('http://')
            ? 'https://${trimmed.substring(7)}'
            : trimmed;
      }
    }

    if (cleanUrl == null) {
      return _buildFallbackThumbnail(theme);
    }

    // On Web, CanvasKit blocks cross-origin images that don't have CORS headers (e.g. Google Maps thumbnails).
    // We proxy via EverUsBackend /api/date-planner/image-proxy, and provide seamless fallback to public CDN proxy (wsrv.nl).
    final String targetUrl = kIsWeb
        ? '${AuthHelper.baseUrl}/api/date-planner/image-proxy?url=${Uri.encodeComponent(cleanUrl)}'
        : cleanUrl;

    return Image.network(
      targetUrl,
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
      errorBuilder: (context, error, stackTrace) {
        final fallbackCdnUrl = 'https://images.weserv.nl/?url=${Uri.encodeComponent(cleanUrl!)}';
        if (targetUrl != fallbackCdnUrl && targetUrl != cleanUrl) {
          return Image.network(
            cleanUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, err2, st2) => Image.network(
              fallbackCdnUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, err3, st3) => _buildFallbackThumbnail(theme),
            ),
          );
        } else if (targetUrl != fallbackCdnUrl) {
          return Image.network(
            fallbackCdnUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, err3, st3) => _buildFallbackThumbnail(theme),
          );
        }
        return _buildFallbackThumbnail(theme);
      },
    );
  }

  Widget _buildFallbackThumbnail(ActivityTheme theme) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.light.withValues(alpha: 0.8),
            theme.primary.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "EverUs Date Spot",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.dark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitTimelineItem(double distance, int duration, ActivityTheme theme, String transport) {
    String transportLabel = "Xe máy";
    if (transport == "walking") {
      transportLabel = "Đi bộ";
    } else if (transport == "taxi") {
      transportLabel = "Taxi";
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
                    child: Text(
                      "$transportLabel: ~ ${distance.toStringAsFixed(1)} km (~$duration phút)",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.dark,
                      ),
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
