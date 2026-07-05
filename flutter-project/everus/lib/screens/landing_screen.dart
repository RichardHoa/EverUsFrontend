import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/heart_mascot.dart';
import '../widgets/everus_footer.dart';
import 'love_counter_screen.dart';
import 'login_screen.dart';
import 'date_planner_screen.dart';
import 'notifications_screen.dart';
import '../utils/love_counter_helper.dart';
import '../utils/auth_helper.dart';
import '../utils/notification_manager.dart';
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
  File? _userFile;
  File? _loverFile;

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
    }
  }

  Future<void> _loadLoveStatus() async {
    try {
      final isConfigured = await LoveCounterHelper.isConfigured();
      Map<String, dynamic> settings = {};
      int days = 0;
      bool userExists = false;
      bool loverExists = false;
      File? userFile;
      File? loverFile;
      if (isConfigured) {
        settings = await LoveCounterHelper.loadSettings();
        final anniversary = settings['anniversaryDate'] as DateTime?;
        if (anniversary != null) {
          days = DateTime.now().difference(anniversary).inDays;
        }
        final userPath = settings['userImagePath'] as String?;
        final loverPath = settings['loverImagePath'] as String?;
        userExists = userPath != null && await File(userPath).exists();
        loverExists = loverPath != null && await File(loverPath).exists();
        if (userExists) userFile = File(userPath!);
        if (loverExists) loverFile = File(loverPath!);
      }
      if (mounted) {
        setState(() {
          _isConfigured = isConfigured;
          _loveSettings = settings;
          _loveDays = days;
          _userImageExists = userExists;
          _loverImageExists = loverExists;
          _userFile = userFile;
          _loverFile = loverFile;
          _loading = false;
        });
      }
      if (!isConfigured && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoveCounterScreen(isForceSetup: true),
            ),
          ).then((_) {
            _loadLoveStatus();
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
    _loadLoveStatus();
  }

  Future<void> _navigateToDatePlanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EverUsHomePage(),
      ),
    );
    _loadLoveStatus();
  }

  Future<void> _navigateToCustomDatePlanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DatePlannerScreen(),
      ),
    );
    _loadLoveStatus();
  }

  Future<void> _navigateToProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          isProfileMode: AuthHelper.isLoggedIn,
        ),
      ),
    );
    _loadLoveStatus();
  }

  Future<void> _navigateToNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
    _loadLoveStatus();
  }

  void _handleNotiTap() {
    if (AuthHelper.isLoggedIn) {
      _navigateToNotifications();
    } else {
      LoginScreen.showGentleLoginModal(
        context,
        onLoginSuccess: () {
          _navigateToNotifications();
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
                      const SizedBox(height: 72), // space for top bar
                      
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
                      const SizedBox(height: 36),

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
                              const SizedBox(height: 12),
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
                      const SizedBox(height: 40),

                      // Quick-view Love Counter (If Anniversary Date configured)
                      if (_isConfigured) _buildMiniLoveCounter(),

                      // Action Cards List
                      _buildActionCard(
                        context: context,
                        title: 'Đếm Ngày Yêu',
                        subtitle: _isConfigured
                            ? 'Theo dõi & lưu giữ kỉ niệm yêu'
                            : 'Bắt đầu ghi lại mốc kỉ niệm',
                        icon: Icons.favorite_rounded,
                        gradientColors: [
                          const Color(0xFFEC4899),
                          const Color(0xFFF43F5E)
                        ],
                        onTap: _navigateToLoveCounter,
                        customIcon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1F8B5CF6),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFEC4899),
                            size: 24,
                          ),
                        ),
                      ),

                      _buildActionCard(
                        context: context,
                        title: 'Thiết Kế Hẹn Hò',
                        subtitle: 'Tự tạo lộ trình chi tiết cho buổi hẹn',
                        icon: Icons.map_rounded,
                        gradientColors: [
                          const Color(0xFFF59E0B),
                          const Color(0xFFEC4899)
                        ],
                        onTap: _navigateToCustomDatePlanner,
                      ),

                      _buildActionCard(
                        context: context,
                        title: 'Ý Tưởng Hẹn Hò',
                        subtitle: 'Lên kế hoạch phù hợp với cả hai',
                        icon: Icons.explore_rounded,
                        gradientColors: [
                          const Color(0xFF8B5CF6),
                          const Color(0xFF6366F1)
                        ],
                        onTap: _navigateToDatePlanner,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Top action bar (Notification button)
              Positioned(
                top: 8,
                right: 16,
                child: Container(
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
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF8B5CF6),
                      size: 28,
                    ),
                    onPressed: _handleNotiTap,
                  ),
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

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    Widget? customIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 12,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Row(
                children: [
                  customIcon ?? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String name, File? file, bool exists, {double size = 32.0}) {
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
      child: ClipOval(
        child: exists && file != null
            ? Image.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Container(
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
            _loverFile,
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
            _userFile,
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
