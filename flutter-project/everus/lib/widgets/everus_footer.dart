import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/auth_helper.dart';
import '../screens/login_screen.dart';

class EverUsFooter extends StatelessWidget {
  final String currentTab; // 'home' | 'account' | 'other'

  const EverUsFooter({
    super.key,
    required this.currentTab,
  });

  void _navigateToProfile(BuildContext context) {
    if (currentTab == 'account') return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          isProfileMode: AuthHelper.isLoggedIn,
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    if (currentTab == 'home') return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: AuthHelper.sessionNotifier,
      builder: (context, session, child) {
        final isLoggedIn = session != null;
        return Container(
          margin: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom + 8
                : 24,
          ),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFF3E8FF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Account/Profile Button
                InkWell(
                  onTap: () => _navigateToProfile(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoggedIn ? Icons.account_circle : Icons.account_circle_outlined,
                          color: currentTab == 'account' ? const Color(0xFF8B5CF6) : const Color(0xFF9CA3AF),
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tài khoản',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: currentTab == 'account' ? const Color(0xFF8B5CF6) : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Vertical divider
                Container(
                  width: 1.5,
                  height: 28,
                  color: const Color(0xFFF3E8FF),
                ),
                // Home Button
                InkWell(
                  onTap: () => _navigateToHome(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: currentTab == 'home' ? const Color(0xFFEC4899) : const Color(0xFF9CA3AF),
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Trang chủ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: currentTab == 'home' ? const Color(0xFFEC4899) : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
