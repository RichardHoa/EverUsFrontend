import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/heart_mascot.dart';
import 'love_counter_screen.dart';
import '../main.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF5F5), // ultra-light pink
              Colors.white,
              Color(0xFFFAF5FF), // ultra-light purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // App Brand Title
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
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Your Ultimate Couple Space',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mascot Greeting
                  const HeartMascot(
                    emotion: 'excited',
                    comment: "Welcome! Let's make every moment count!",
                    showComment: true,
                  ),
                  const SizedBox(height: 24),

                  // Introduction Header
                  Text(
                    'Discover Our Features',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feature 1: Date Planner (Main Feature)
                  _buildFeatureCard(
                    isMain: true,
                    icon: Icons.explore_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    badgeText: 'MAIN FEATURE',
                    badgeColor: const Color(0xFFF3E8FF),
                    badgeTextColor: const Color(0xFF8B5CF6),
                    title: 'Smart Date Planner',
                    description:
                        'Find activities tailored to your couple vibes. Adjust romance, adventure, budget, and relationship stage preferences, and let our least-squares algorithm find the perfect date.',
                  ),
                  const SizedBox(height: 16),

                  // Feature 2: Love Counter (Side Feature)
                  _buildFeatureCard(
                    isMain: false,
                    icon: Icons.favorite_border,
                    iconColor: const Color(0xFFEC4899),
                    badgeText: 'SIDE FEATURE',
                    badgeColor: const Color(0xFFFCE7F3),
                    badgeTextColor: const Color(0xFFEC4899),
                    title: 'Local Love Counter',
                    description:
                        'Record your milestone anniversary and see exactly how many days, hours, and minutes you have been together. Fully persistent and stored 100% locally on your device.',
                  ),
                  const SizedBox(height: 32),

                  // Main CTA: Explore Date Planner
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EverUsHomePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Explore Date Planner',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary CTA: Track Our Love Days
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoveCounterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Text(
                            'Track Our Love Days',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required bool isMain,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMain ? const Color(0xFFF3E8FF) : const Color(0xFFFCE7F3),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
