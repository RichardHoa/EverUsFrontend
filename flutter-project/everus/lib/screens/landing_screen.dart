import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/heart_mascot.dart';
import '../widgets/everus_footer.dart';
import '../widgets/app_avatar.dart';
import '../utils/file_helper/file_helper.dart';
import 'love_counter_screen.dart';
import 'login_screen.dart';
import 'date_planner_screen.dart';
import 'notifications_screen.dart';
import '../utils/love_counter_helper.dart';
import '../utils/auth_helper.dart';
import '../utils/notification_manager.dart';
import '../models/date_plan.dart';
import 'reflection/reflection_home_screen.dart';
import '../main.dart';

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
  bool _showMascotComment = true;
  int _tapCount = 0;

  final List<Map<String, String>> _mascotInteractions = [
    {
      'emotion': 'happy',
      'comment': 'Hôm nay tụi mình đi đâu chơi nhỉ? 🤔',
    },
    {
      'emotion': 'love',
      'comment': 'Yêu cậu nhiều lắm á! ♥',
    },
    {
      'emotion': 'excited',
      'comment': 'Lên lịch hẹn hò thôi! Tớ đã sẵn sàng! 🚀',
    },
    {
      'emotion': 'celebrating',
      'comment': 'Cùng tạo nên thật nhiều kỉ niệm nhé! 🥳',
    },
    {
      'emotion': 'thinking',
      'comment': 'Hai cậu trông thật là đẹp đôi luôn á! 💑',
    },
    {
      'emotion': 'happy',
      'comment': 'Chạm vào tớ tiếp đi, tớ thích lắm! 🥰',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLoveStatus();
    if (AuthHelper.isLoggedIn) {
      NotificationManager.instance.initialize();
      NotificationManager.instance.fetchNotifications();
    }
    NotificationManager.refreshNotifier.addListener(_onNotificationRefresh);
  }

  @override
  void dispose() {
    NotificationManager.refreshNotifier.removeListener(_onNotificationRefresh);
    super.dispose();
  }

  void _onNotificationRefresh() {
    if (mounted) {
      setState(() {});
    }
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoveCounterScreen(isForceSetup: true),
            ),
          ).then((_) {
            if (mounted) _loadLoveStatus();
          });
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onMascotTap() {
    setState(() {
      final interaction = _mascotInteractions[_tapCount];
      _mascotEmotion = interaction['emotion']!;
      _mascotComment = interaction['comment']!;
      _showMascotComment = true;
      _tapCount = (_tapCount + 1) % _mascotInteractions.length;
    });
  }

  Future<void> _navigateToLoveCounter() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoveCounterScreen(),
      ),
    );
    if (mounted) _loadLoveStatus();
  }

  Future<void> _navigateToDatePlanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EverUsHomePage(),
      ),
    );
    if (mounted) _loadLoveStatus();
  }

  Future<void> _navigateToCustomDatePlanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DatePlannerScreen(),
      ),
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
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFECEF), // light pink
              Colors.white,
              Color(0xFFF5EEFF), // light lavender/purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 28), // space for top bar
                      
                      // App title & brand
                      Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'EverUs',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Không gian kết nối yêu thương',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7C7289),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Mascot Container
                      Center(
                        child: GestureDetector(
                          onTap: _onMascotTap,
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HeartMascot(
                                emotion: _mascotEmotion,
                                comment: _mascotComment,
                                showComment: _showMascotComment,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Chạm vào tớ nhé! 💖',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEC4899).withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick-view Love Counter (If Anniversary Date configured)
                      if (_isConfigured) _buildMiniLoveCounter(),

                      // Side-by-Side Action Cards (Date Planner & Relationship Reflection)
                      _buildSideBySideCards(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Top action bar (Notification button)
              Positioned(
                top: 8,
                right: 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          AuthHelper.isLoggedIn && NotificationManager.instance.notifications.any((n) => n['is_read'] == false)
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_none_outlined,
                          color: const Color(0xFF8B5CF6),
                          size: 28,
                        ),
                        onPressed: _handleNotiTap,
                      ),
                    ),
                    if (AuthHelper.isLoggedIn && NotificationManager.instance.notifications.any((n) => n['is_read'] == false))
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: const EverUsFooter(currentTab: 'home'),
    );
  }

  Widget _buildMiniLoveCounter() {
    final userName = _loveSettings['userName'] ?? '';
    final loverName = _loveSettings['loverName'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.65),
        border: Border.all(
          color: const Color(0xFFFCE7F3),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateToLoveCounter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHÚNG MÌNH ĐÃ BÊN NHAU',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFEC4899),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              ).createShader(bounds),
                              child: Text(
                                '$_loveDays',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ngày',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$userName ♥ $loverName',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDoubleAvatar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePlannerOptions(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Date Planner',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Icon Badge
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Date Planner',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1F2937),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chọn trải nghiệm bạn muốn cùng thực hiện',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Button 1: Lên kế hoạch hẹn hò (the planning page)
                    _buildCenteredDialogButton(
                      context: ctx,
                      title: 'Lên kế hoạch hẹn hò',
                      subtitle: 'Tự tạo lộ trình chi tiết cho buổi hẹn',
                      icon: Icons.edit_calendar_rounded,
                      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
                      onTap: () {
                        Navigator.pop(ctx);
                        _navigateToCustomDatePlanner();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Button 2: Thử thách hẹn hò (the challenge page)
                    _buildCenteredDialogButton(
                      context: ctx,
                      title: 'Thử thách hẹn hò',
                      subtitle: 'Khám phá ý tưởng & thử thách thú vị',
                      icon: Icons.sports_esports_rounded,
                      gradientColors: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
                      onTap: () {
                        Navigator.pop(ctx);
                        _navigateToDatePlanner();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Close / Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Đóng',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenteredDialogButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideBySideCards(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date Planner Card (Left)
          Expanded(
            child: _buildGridCard(
              context: context,
              title: 'Date Planner',
              subtitle: 'Lên kế hoạch &\nthử thách hẹn hò',
              actionText: 'Khám phá',
              icon: Icons.calendar_today_rounded,
              backgroundColor: const Color(0xFFFFF3EC),
              accentColor: const Color(0xFFF97316),
              onTap: () => _showDatePlannerOptions(context),
            ),
          ),
          const SizedBox(width: 14),
          // Relationship Reflection Card (Right)
          Expanded(
            child: _buildGridCard(
              context: context,
              title: 'Relationship\nReflection',
              subtitle: 'Thấu cảm & phản chiếu\nmối quan hệ',
              actionText: 'Khám phá',
              icon: Icons.auto_awesome_rounded,
              backgroundColor: const Color(0xFFF3E8FF),
              accentColor: const Color(0xFF8B5CF6),
              onTap: _navigateToReflection,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    required Color backgroundColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: accentColor,
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        actionText,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF1F2937),
                        size: 16,
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

  Widget _buildAvatarCircle(String name, String? imagePath, bool exists, {double size = 32.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppAvatar(
        imagePath: exists ? imagePath : null,
        radius: size / 2,
        fallback: Container(
          color: const Color(0xFFF3E8FF),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '♥',
              style: GoogleFonts.inter(
                fontSize: size * 0.375,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoubleAvatar({double size = 48.0}) {
    if (!_isConfigured) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.favorite,
          color: Color(0xFFEC4899),
          size: 24,
        ),
      );
    }

    if (_userImageExists && _loverImageExists) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatarCircle(
            _loveSettings['loverName'] ?? 'Em',
            _loverImagePath,
            _loverImageExists,
            size: size,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.favorite,
              color: Color(0xFFEC4899),
              size: 24,
            ),
          ),
          _buildAvatarCircle(
            _loveSettings['userName'] ?? 'Bạn',
            _userImagePath,
            _userImageExists,
            size: size,
          ),
        ],
      );
    } else {
      final uName = _loveSettings['userName'] ?? '';
      final lName = _loveSettings['loverName'] ?? '';
      final uInitial = uName.isNotEmpty ? uName[0].toUpperCase() : 'B';
      final lInitial = lName.isNotEmpty ? lName[0].toUpperCase() : 'N';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                lInitial,
                style: GoogleFonts.inter(
                  fontSize: size * 0.375,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEC4899),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.favorite,
              color: Color(0xFFEC4899),
              size: 24,
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                uInitial,
                style: GoogleFonts.inter(
                  fontSize: size * 0.375,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
