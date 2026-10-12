import 'dart:async';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../main.dart';
import '../models/date_plan.dart';
import '../utils/auth_helper.dart';
import '../utils/file_helper/file_helper.dart';
import '../utils/love_counter_helper.dart';
import '../utils/notification_manager.dart';
import '../widgets/display_language_toggle.dart';
import '../widgets/everus_footer.dart';
import 'date_planner_screen.dart';
import 'landing/widgets/date_planner_options_dialog.dart';
import 'landing/widgets/feature_action_cards.dart';
import 'landing/widgets/landing_mascot_section.dart';
import 'landing/widgets/mini_love_counter.dart';
import 'login_screen.dart';
import 'love_counter_screen.dart';
import 'notifications_screen.dart';
import 'reflection/reflection_home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _loading = true;
  bool _isConfigured = false;
  Map<String, dynamic> _loveSettings = {};
  int _loveDays = 0;
  bool _userImageExists = false;
  bool _loverImageExists = false;
  String? _userImagePath;
  String? _loverImagePath;

  // Mascot Interactive State
  /// Null until the first tap, while the greeting is shown.
  MascotInteraction? _mascotInteraction;
  String _mascotImage = kDefaultMascotImage;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLoveStatus();
    if (AuthHelper.isLoggedIn) {
      NotificationManager.instance.initialize();
      NotificationManager.instance.fetchNotifications();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadLoveStatus() async {
    try {
      if (AuthHelper.isLoggedIn) {
        final isConfig = await LoveCounterHelper.isConfigured();
        if (!isConfig) {
          await LoveCounterHelper.fetchAndRestoreFromBackend();
        } else {
          LoveCounterHelper.syncWithBackend();
        }
      }
      final isConfigured = await LoveCounterHelper.isConfigured();
      Map<String, dynamic> settings = {};
      int days = 0;
      bool userExists = false;
      bool loverExists = false;
      String? userPath;
      String? loverPath;

      if (isConfigured) {
        settings = await LoveCounterHelper.loadSettings();
        final anniversary = settings['anniversaryDate'] as DateTime?;
        if (anniversary != null) {
          days = LoveCounterHelper.calculateLoveDays(anniversary);
        }
        userPath = settings['userImagePath'] as String?;
        loverPath = settings['loverImagePath'] as String?;
        userExists = userPath != null && await AppFileHelper.fileExists(userPath);
        loverExists = loverPath != null && await AppFileHelper.fileExists(loverPath);
      }

      if (mounted) {
        setState(() {
          _isConfigured = isConfigured;
          _loveSettings = settings;
          _loveDays = days;
          _userImageExists = userExists;
          _loverImageExists = loverExists;
          _userImagePath = userPath;
          _loverImagePath = loverPath;
          _loading = false;
        });
      }

      if (!isConfigured && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const LoveCounterScreen(isForceSetup: true),
                ),
              )
              .then((_) {
            if (mounted) _loadLoveStatus();
          });
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onMascotTap() {
    setState(() {
      final interaction = kDefaultMascotInteractions[_tapCount];
      _mascotInteraction = interaction;
      _mascotImage = interaction.image;
      _tapCount = (_tapCount + 1) % kDefaultMascotInteractions.length;
    });
  }

  Future<void> _navigateToLoveCounter() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoveCounterScreen()),
    );
    if (mounted) _loadLoveStatus();
  }

  Future<void> _navigateToDatePlanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EverUsHomePage()),
    );
    if (mounted) _loadLoveStatus();
  }

  Future<void> _navigateToCustomDatePlanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DatePlannerScreen()),
    );
    if (mounted) _loadLoveStatus();
  }

  Future<void> _navigateToReflection() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReflectionHomeScreen(),
        settings: const RouteSettings(name: 'reflection_home'),
      ),
    );
    if (mounted) _loadLoveStatus();
  }

  Future<void> _navigateToNotifications() async {
    final selectedPlan = await Navigator.of(context).push<DatePlan>(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
    if (!mounted) return;
    if (selectedPlan != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DatePlannerScreen(initialPlan: selectedPlan),
        ),
      );
    }
    if (mounted) _loadLoveStatus();
  }

  void _handleNotiTap() {
    if (AuthHelper.isLoggedIn) {
      _navigateToNotifications();
    } else {
      LoginScreen.showGentleLoginModal(
        context,
        onLoginSuccess: () {
          if (mounted) _navigateToNotifications();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF653851)),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // EverUs Background Image (Isolated with RepaintBoundary)
          Positioned.fill(
            child: RepaintBoundary(
              child: Image(
                image: const ResizeImage(
                  AssetImage('assets/images/bg_everus.png'),
                  width: 800,
                ),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Layout follows the Figma landing_page frame, drawn
                      // 1243 units wide (about 3x a phone).
                      final k = constraints.maxWidth / 1243;
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 76 * k),

                            // Mascot Interactive Section (Isolated repaint)
                            RepaintBoundary(
                              child: LandingMascotSection(
                                image: _mascotImage,
                                comment: _mascotInteraction?.comment(context.l10n) ?? context.l10n.mascotGreeting,
                                onTap: _onMascotTap,
                                scale: k,
                              ),
                            ),
                            SizedBox(height: 69 * k),

                            // Quick-view Love Counter (If Anniversary Date configured)
                            if (_isConfigured)
                              Padding(
                                padding: EdgeInsets.only(left: 101.17 * k, bottom: 130 * k),
                                child: RepaintBoundary(
                                  child: MiniLoveCounter(
                                    loveDays: _loveDays,
                                    userName: _loveSettings['userName'] ?? '',
                                    loverName: _loveSettings['loverName'] ?? '',
                                    userImageExists: _userImageExists,
                                    loverImageExists: _loverImageExists,
                                    userImagePath: _userImagePath,
                                    loverImagePath: _loverImagePath,
                                    onTap: _navigateToLoveCounter,
                                    scale: k,
                                  ),
                                ),
                              ),

                            // Side-by-Side Action Cards (Date Planner & Relationship Reflection)
                            RepaintBoundary(
                              child: FeatureActionCards(
                                scale: k,
                                onDatePlannerTap: () {
                                  DatePlannerOptionsDialog.show(
                                    context,
                                    onPlanCustom: _navigateToCustomDatePlanner,
                                    onChallenge: _navigateToDatePlanner,
                                  );
                                },
                                onReflectionTap: _navigateToReflection,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Positioned(
                  top: 18,
                  right: 76,
                  child: DisplayLanguageToggle(),
                ),

                // Top action bar (Notification button - listens to refreshNotifier directly)
                Positioned(
                  top: 8,
                  right: 16,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: NotificationManager.refreshNotifier,
                    builder: (context, _, _) {
                      final bool hasUnreadNoti = AuthHelper.isLoggedIn &&
                          NotificationManager.instance.notifications.any((n) => n['is_read'] == false);
                      return Stack(
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
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                hasUnreadNoti
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_none_outlined,
                                color: const Color(0xFF5A384C),
                                size: 26,
                              ),
                              onPressed: _handleNotiTap,
                            ),
                          ),
                          if (hasUnreadNoti)
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const EverUsFooter(currentTab: 'home'),
    );
  }
}
