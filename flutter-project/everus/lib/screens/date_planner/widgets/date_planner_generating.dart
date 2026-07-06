import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../date_planner_controller.dart';

/// Screen displayed when the AI is currently designing the itinerary.
///
/// Features a text description and a percentage progress loading bar.
class DatePlannerGenerating extends StatelessWidget {
  /// The state controller driving the loading progress.
  final DatePlannerController controller;

  /// Const constructor for [DatePlannerGenerating].
  const DatePlannerGenerating({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot Pulse circle indicator
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFBCFE8), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "🧭",
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'EverUs đang lên lộ trình...',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'Tụi mình đang cân đối thời gian, sắp xếp thứ tự các chặng và lồng ghép các gợi ý hoạt động thú vị cho hai bạn đó!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              child: ValueListenableBuilder<double>(
                valueListenable: controller.progressNotifier,
                builder: (context, progress, child) {
                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth * progress;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: width,
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEC4899),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
