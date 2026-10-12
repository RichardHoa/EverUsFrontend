import 'package:flutter/material.dart';
import '../../../widgets/backend_work_overlay.dart';
import '../date_planner_controller.dart';
import '../../../l10n/l10n.dart';

/// Screen displayed while the backend designs the itinerary.
///
/// Thin wrapper around [BackendWorkOverlay] with the itinerary-specific caption.
class DatePlannerGenerating extends StatelessWidget {
  /// The state controller driving the generation.
  final DatePlannerController controller;

  /// Const constructor for [DatePlannerGenerating].
  const DatePlannerGenerating({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BackendWorkOverlay(message: context.l10n.plannerGenerating);
  }
}
