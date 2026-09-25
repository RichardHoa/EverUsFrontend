import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../date_planner_controller.dart';

/// Shown in place of the results screen when plan generation fails
/// (e.g. no places found near the user), so the failure reads as an
/// outcome of the flow rather than a snackbar over the untouched form.
class DatePlannerError extends StatelessWidget {
  /// The state controller driving retry/edit actions.
  final DatePlannerController controller;

  /// The user-facing error message to display.
  final String message;

  /// Const constructor for [DatePlannerError].
  const DatePlannerError({super.key, required this.controller, required this.message});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFF5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2D6E0), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.location_off_outlined, size: 44, color: Color(0xFF653851)),
          ),
          const SizedBox(height: 24),
          Text(
            'Không thể tạo kế hoạch',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A384C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF7C6E79),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
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
              onPressed: () async {
                try {
                  await controller.generatePlan();
                } catch (_) {
                  // Any new failure is surfaced through controller.generationError.
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF653851),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'THỬ LẠI',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: controller.clearPlan,
            child: Text(
              'Quay lại chỉnh sửa',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF653851)),
            ),
          ),
        ],
      ),
    );
  }
}
