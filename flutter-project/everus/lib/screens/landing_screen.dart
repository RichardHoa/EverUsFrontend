import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/heart_mascot.dart';
import 'love_counter_screen.dart';
import 'login_screen.dart';
import '../utils/love_counter_helper.dart';
import '../utils/auth_helper.dart';
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
  }

  Future<void> _loadLoveStatus() async {
    try {
      final isConfigured = await LoveCounterHelper.isConfigured();
      Map<String, dynamic> settings = {};
      int days = 0;
      if (isConfigured) {
        settings = await LoveCounterHelper.loadSettings();
        final anniversary = settings['anniversaryDate'] as DateTime?;
        if (anniversary != null) {
          days = DateTime.now().difference(anniversary).inDays;
        }
      }
      if (mounted) {
        setState(() {
          _isConfigured = isConfigured;
          _loveSettings = settings;
          _loveDays = days;
          _loading = false;
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
                        title: 'Ý Tưởng Hẹn Hò',
                        subtitle: 'Lên kế hoạch phù hợp với cả hai',
                        icon: Icons.explore_rounded,
                        gradientColors: [
                          const Color(0xFF8B5CF6),
                          const Color(0xFF6366F1)
                        ],
                        onTap: _navigateToDatePlanner,
                      ),

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
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Top action bar (Account button)
              Positioned(
                top: 8,
                right: 16,
                child: ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: AuthHelper.sessionNotifier,
                  builder: (context, session, child) {
                    final isLoggedIn = session != null;
                    return Container(
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
                          isLoggedIn
                              ? Icons.account_circle
                              : Icons.account_circle_outlined,
                          color: const Color(0xFF8B5CF6),
                          size: 28,
                        ),
                        onPressed: _navigateToProfile,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
                  Container(
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
                      size: 28,
                    ),
                  ),
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
                  Container(
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
}
