import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/reflection_models.dart';
import 'shared_insight_card.dart';

class UsInsightsTab extends StatelessWidget {
  final List<SharedRelationshipInsight> sharedInsights;
  final VoidCallback onStartReflection;

  const UsInsightsTab({
    super.key,
    required this.sharedInsights,
    required this.onStartReflection,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab Intro Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDF2F8), Color(0xFFFAF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFCE7F3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFEC4899),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Không gian chung an toàn',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBE185D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'EverUs không bao giờ hiển thị nhật ký cá nhân. Nơi này chỉ tổng hợp những pattern chung để hai bạn cùng thấu hiểu và gắn kết hơn.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Shared Insights
          ...sharedInsights.map(
            (insight) => SharedInsightCard(
              insight: insight,
              onReflectTogether: onStartReflection,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
