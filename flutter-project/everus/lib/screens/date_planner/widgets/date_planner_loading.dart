import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simple spinner loader shown when retrieving an existing plan from the server.
class DatePlannerLoading extends StatelessWidget {
  /// Const constructor for [DatePlannerLoading].
  const DatePlannerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A384C).withValues(alpha: 0.08),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF653851)),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Đang tải kế hoạch...',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A384C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang lấy thông tin mới nhất cho buổi hẹn hò của bạn... 💕',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF7C6E79),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
