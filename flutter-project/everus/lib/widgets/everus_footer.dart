import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../utils/auth_helper.dart';

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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bool isHome = currentTab == 'home';
    final bool isAccount = currentTab == 'account';

    return SafeArea(
      top: false,
      child: Container(
        height: 52,
        margin: EdgeInsets.only(
          bottom: bottomInset > 0 ? 8.0 : 20.0,
        ),
        alignment: Alignment.center,
        child: Container(
          height: 52,
          width: 230,
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A384C).withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home icon button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _navigateToHome(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Image.asset(
                      'assets/images/home_bullet.png',
                      width: 26,
                      height: 26,
                      color: isHome ? const Color(0xFF5A384C) : const Color(0xFFB0A2AC),
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => Icon(
                        isHome ? Icons.home_rounded : Icons.home_outlined,
                        color: isHome ? const Color(0xFF5A384C) : const Color(0xFFB0A2AC),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              // Profile / Account icon button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _navigateToProfile(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Image.asset(
                      'assets/images/personal_bullet.png',
                      width: 26,
                      height: 26,
                      color: isAccount ? const Color(0xFF5A384C) : const Color(0xFFB0A2AC),
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => Icon(
                        isAccount ? Icons.person : Icons.person_outline,
                        color: isAccount ? const Color(0xFF5A384C) : const Color(0xFFB0A2AC),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

