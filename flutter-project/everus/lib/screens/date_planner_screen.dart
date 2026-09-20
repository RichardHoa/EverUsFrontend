import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/date_plan.dart';
import '../utils/auth_helper.dart';
import '../utils/notification_manager.dart';
import '../widgets/everus_footer.dart';
import 'date_planner/date_planner_controller.dart';
import 'date_planner/widgets/date_planner_form.dart';
import 'date_planner/widgets/date_planner_results.dart';
import 'date_planner/widgets/date_planner_generating.dart';
import 'date_planner/widgets/date_planner_loading.dart';
import 'notifications_screen.dart';

/// The entry screen wrapper for the Date Planner feature.
///
/// Coordinates the controller setup, global notifications refresh, and routing,
/// choosing between form, generating, loading, and results layouts.
class DatePlannerScreen extends StatefulWidget {
  /// Optional initial plan if loaded from notification deep links.
  final DatePlan? initialPlan;

  /// Const constructor for [DatePlannerScreen].
  const DatePlannerScreen({super.key, this.initialPlan});

  @override
  State<DatePlannerScreen> createState() => _DatePlannerScreenState();
}

class _DatePlannerScreenState extends State<DatePlannerScreen> {
  late final DatePlannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DatePlannerController();
    
    // Load local cached plans and notifications
    _controller.loadSavedPlan();
    
    if (widget.initialPlan != null) {
      _controller.setGeneratedPlan(widget.initialPlan);
    }
    
    if (AuthHelper.isLoggedIn) {
      NotificationManager.instance.fetchNotifications();
      _onNotificationRefresh();
    }
    
    NotificationManager.refreshNotifier.addListener(_onNotificationRefresh);
  }

  @override
  void dispose() {
    NotificationManager.refreshNotifier.removeListener(_onNotificationRefresh);
    _controller.dispose();
    super.dispose();
  }

  void _onNotificationRefresh() async {
    // Refresh invite accepted state — use savedPlan as fallback
    final planId = _controller.generatedPlan?.id ?? _controller.savedPlan?.id;
    if (planId != null) {
      _controller.checkExistingInvitation(planId);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // EverUs Background Image (Isolated with RepaintBoundary)
          const Positioned.fill(
            child: RepaintBoundary(
              child: Image(
                image: AssetImage('assets/images/bg_everus.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, child) {
                      Widget body;
                      if (_controller.isGenerating) {
                        body = DatePlannerGenerating(controller: _controller);
                      } else if (_controller.isLoadingPlan) {
                        body = const DatePlannerLoading();
                      } else if (_controller.generatedPlan != null) {
                        body = DatePlannerResults(controller: _controller);
                      } else {
                        body = DatePlannerForm(controller: _controller);
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: body,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const EverUsFooter(currentTab: 'other'),
    );
  }

  Widget _buildAppBar() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final bool isViewingResult = _controller.generatedPlan != null && !_controller.isGenerating;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x145A384C),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF5A384C)),
                  onPressed: () {
                    if (isViewingResult) {
                      _controller.clearPlan();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
              const SizedBox(width: 14),
              Text(
                isViewingResult ? 'Lộ Trình Hẹn Hò' : 'Thiết Kế Hẹn Hò',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5A384C),
                ),
              ),
              const Spacer(),
              if (AuthHelper.isLoggedIn) ...[
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5A384C).withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          NotificationManager.instance.notifications.any((n) => n['is_read'] == false)
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_none_outlined,
                          color: const Color(0xFF5A384C),
                        ),
                        onPressed: () async {
                          final selectedPlan = await Navigator.push<DatePlan>(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          );
                          if (selectedPlan != null) {
                            _controller.setGeneratedPlan(selectedPlan);
                          } else {
                            _onNotificationRefresh();
                          }
                        },
                      ),
                    ),
                    if (NotificationManager.instance.notifications.any((n) => n['is_read'] == false))
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC62828),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
