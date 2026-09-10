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
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A384C).withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "🧭",
                  style: TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'EverUs đang lên lộ trình...',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A384C),
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
                  color: const Color(0xFF7C6E79),
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
                              color: const Color(0xFFE2D6E0),
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
                                  color: const Color(0xFF653851),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5A384C).withValues(alpha: 0.2),
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
                          color: const Color(0xFF653851),
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
