import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureActionCards extends StatelessWidget {
  final VoidCallback onDatePlannerTap;
  final VoidCallback onReflectionTap;

  const FeatureActionCards({
    super.key,
    required this.onDatePlannerTap,
    required this.onReflectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date Planner Card (Left)
          Expanded(
            child: GridActionCard(
              title: 'Date Planner',
              subtitle: 'Lên kế hoạch &\nthử thách hẹn hò',
              actionText: 'Khám phá',
              icon: Icons.calendar_today_rounded,
              accentColor: const Color(0xFF653851),
              badgeBg: const Color(0xFFF7EFF5),
              onTap: onDatePlannerTap,
            ),
          ),
          const SizedBox(width: 14),
          // Relationship Reflection Card (Right)
          Expanded(
            child: GridActionCard(
              title: 'Relationship\nReflection',
              subtitle: 'Thấu cảm & phản chiếu\nmối quan hệ',
              actionText: 'Khám phá',
              icon: Icons.auto_awesome_rounded,
              accentColor: const Color(0xFF5A384C),
              badgeBg: const Color(0xFFEDE4EB),
              onTap: onReflectionTap,
            ),
          ),
        ],
      ),
    );
  }
}

class GridActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final IconData icon;
  final Color accentColor;
  final Color badgeBg;
  final VoidCallback onTap;

  const GridActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.icon,
    required this.accentColor,
    required this.badgeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D5A384C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF5A384C),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: accentColor,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7C6E79),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        actionText,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: accentColor,
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
