import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/date_plan.dart';
import '../utils/auth_helper.dart';
import '../utils/file_helper/file_helper.dart';
import '../utils/love_counter_helper.dart';
import '../utils/notification_manager.dart';
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
  String _mascotEmotion = 'excited';
  String _mascotComment = 'Chào cậu nhé! Chạm vào tớ đi! 💖';
  final bool _showMascotComment = true;
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
      _mascotEmotion = interaction.emotion;
      _mascotComment = interaction.comment;
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // App title & brand
                        Center(
                          child: Text(
                            'EverUs',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF5A384C),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Không gian kết nối yêu thương',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF7C6E79),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Mascot Interactive Section (Isolated repaint)
                        RepaintBoundary(
                          child: LandingMascotSection(
                            emotion: _mascotEmotion,
                            comment: _mascotComment,
                            showComment: _showMascotComment,
                            onTap: _onMascotTap,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quick-view Love Counter (If Anniversary Date configured)
                        if (_isConfigured)
                          RepaintBoundary(
                            child: MiniLoveCounter(
                              loveDays: _loveDays,
                              userName: _loveSettings['userName'] ?? '',
                              loverName: _loveSettings['loverName'] ?? '',
                              isConfigured: _isConfigured,
                              userImageExists: _userImageExists,
                              loverImageExists: _loverImageExists,
                              userImagePath: _userImagePath,
                              loverImagePath: _loverImagePath,
                              onTap: _navigateToLoveCounter,
                            ),
                          ),

                        // Side-by-Side Action Cards (Date Planner & Relationship Reflection)
                        RepaintBoundary(
                          child: FeatureActionCards(
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
                        const SizedBox(height: 100), // Space for floating bottom bar
                      ],
                    ),
                  ),
                ),

                // Top action bar (Notification button - listens to refreshNotifier directly)
                Positioned(
                  top: 8,
                  right: 16,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: NotificationManager.refreshNotifier,
                    builder: (context, _, __) {
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
