import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reflection_models.dart';
import '../../utils/reflection_helper.dart';
import 'reflection_action_screen.dart';
import 'reflection_chat_history_screen.dart';
import 'widgets/summary_section_card.dart';

class ReflectionSummaryScreen extends StatelessWidget {
  final ReflectionItem item;

  const ReflectionSummaryScreen({
    super.key,
    required this.item,
  });

  void _proceedToAction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionActionScreen(item: item),
      ),
    );
  }

  void _viewChatHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReflectionChatHistoryScreen(item: item),
      ),
    );
  }

  Future<void> _saveToPrivateDiaryAndDone(BuildContext context) async {
    final updatedItem = ReflectionItem(
      id: item.id,
      title: item.title,
      situation: item.situation,
      emotions: item.emotions,
      underlyingNeed: item.underlyingNeed,
      relatedPattern: item.relatedPattern,
      whatHappened: item.whatHappened,
      whatInterpreted: item.whatInterpreted,
      aiPerspective: item.aiPerspective,
      draftedMessage: item.draftedMessage,
      createdAt: item.createdAt,
      actionTaken: 'private',
      isBookmarked: item.isBookmarked,
      chatHistory: item.chatHistory,
    );

    await ReflectionHelper.saveReflection(updatedItem);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Đã lưu Reflection vào nhật ký riêng tư của bạn!',
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == 'reflection_home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF5F5), // ultra-light pink
              Colors.white,
              Color(0xFFFAF5FF), // ultra-light lavender
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
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
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF8B5CF6),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bản tổng kết Reflection',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
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
                        icon: const Icon(
                          Icons.forum_outlined,
                          color: Color(0xFF8B5CF6),
                          size: 20,
                        ),
                        tooltip: 'Xem lại hội thoại',
                        onPressed: () => _viewChatHistory(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Card Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Badge & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF8B5CF6),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reflection của bạn',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Elegant Card Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFF3E8FF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Điều đã xảy ra
                            SummarySectionCard(
                              icon: Icons.event_note_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              title: 'Điều đã xảy ra',
                              content: item.whatHappened.isNotEmpty
                                  ? item.whatHappened
                                  : item.situation,
                            ),

                            _buildDivider(),

                            // 2. Bạn đã cảm thấy
                            SummarySectionCard(
                              icon: Icons.sentiment_dissatisfied_rounded,
                              iconColor: const Color(0xFFEC4899),
                              title: 'Bạn đã cảm thấy',
                              content: item.emotions,
                            ),

                            _buildDivider(),

                            // 3. Điều nằm phía dưới
                            SummarySectionCard(
                              icon: Icons.psychology_alt_rounded,
                              iconColor: const Color(0xFF8B5CF6),
                              title: 'Điều nằm phía dưới',
                              content: item.aiPerspective.isNotEmpty
                                  ? item.aiPerspective
                                  : item.underlyingNeed,
                            ),

                            _buildDivider(),

                            // 4. Pattern có thể liên quan
                            SummarySectionCard(
                              icon: Icons.insights_rounded,
                              iconColor: const Color(0xFF10B981),
                              title: 'Pattern có thể liên quan',
                              content: item.relatedPattern,
                            ),

                            _buildDivider(),

                            // 5. Có thể bạn đang cần
                            SummarySectionCard(
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: 'Có thể bạn đang cần',
                              content: item.underlyingNeed,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CTA: Primary Actions (Send Message vs Save Privately)
                      if (item.actionTaken == 'shared' ||
                          item.actionTaken == 'communicate')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFBBF7D0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đã hoàn thành giao tiếp',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Thông điệp chân thành đã được chuẩn bị/gửi cho người ấy.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Action 1: Gửi thông điệp (Primary Accent Card)
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _proceedToAction(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Gửi thông điệp cho người ấy',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Action 2: Lưu riêng tư (Secondary Soft Option)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _saveToPrivateDiaryAndDone(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4B5563),
                              side: const BorderSide(
                                  color: Color(0xFFE5E7EB), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.lock_outline_rounded,
                                size: 18, color: Color(0xFF8B5CF6)),
                            label: Text(
                              'Lưu riêng tư vào Nhật ký',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Single Minimal Utilities Footer Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () => _viewChatHistory(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            icon: const Icon(Icons.forum_outlined, size: 15),
                            label: Text(
                              'Xem lại hội thoại',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '•',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                            label: Text(
                              'Trò chuyện tiếp',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        height: 1,
        color: const Color(0xFFF3E8FF),
      ),
    );
  }
}
