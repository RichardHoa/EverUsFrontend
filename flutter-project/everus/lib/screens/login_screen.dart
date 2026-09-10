import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/auth_helper.dart';
import 'login/widgets/auth_input_field.dart';
import 'login/widgets/gentle_login_modal.dart';
import 'login/widgets/google_sign_in_button.dart';
import 'login/widgets/profile_view.dart';

class LoginScreen extends StatefulWidget {
  final bool isProfileMode;

  const LoginScreen({
    super.key,
    this.isProfileMode = false,
  });

  static Future<void> showGentleLoginModal(
    BuildContext context, {
    required VoidCallback onLoginSuccess,
  }) {
    return GentleLoginModal.show(context, onLoginSuccess: onLoginSuccess);
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await AuthHelper.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký tài khoản thành công! Chào mừng bạn đến với EverUs!'),
            ),
          );
        }
      } else {
        await AuthHelper.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('AuthException: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      await AuthHelper.signOut();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Đăng xuất thất bại: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthHelper.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('AuthException: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_everus.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Scrollable Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // Mascot & Brand Header
                      Hero(
                        tag: 'everus_brand',
                        child: Center(
                          child: Image.asset(
                            'assets/images/header_mascot_logo.png',
                            width: 275,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Glassmorphic Card Container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5A384C).withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: (widget.isProfileMode && AuthHelper.isLoggedIn)
                            ? ProfileView(
                                name: AuthHelper.currentUserName ?? 'Người ấy',
                                email: AuthHelper.currentUserEmail ?? '',
                                errorMessage: _errorMessage,
                                isLoading: _isLoading,
                                onSignOut: _handleSignOut,
                              )
                            : _buildAuthForm(),
                      ),
                      const SizedBox(height: 96), // Space for floating bottom bar
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Center(
          child: Container(
            height: 52,
            width: 215,
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(30),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home icon button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/images/home_bullet.png',
                        width: 26,
                        height: 26,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.home_rounded,
                          color: Color(0xFF9E8E9B),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                // Profile icon button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // Already on auth / profile screen
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/images/personal_bullet.png',
                        width: 26,
                        height: 26,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Color(0xFF653851),
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
      ),
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            _isSignUp ? 'Đăng ký' : 'Đăng nhập',
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A384C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Error banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFC62828),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Name field (Sign Up mode only)
          if (_isSignUp) ...[
            AuthInputField(
              controller: _nameController,
              hint: 'tên của bạn',
              icon: Icons.person_rounded,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập tên của bạn';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 11),
          ],

          // Email Field
          AuthInputField(
            controller: _emailController,
            hint: 'địa chỉ email',
            prefixChild: Text(
              '@',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5A384C),
                height: 1.0,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Vui lòng nhập email của bạn';
              }
              if (!_isValidEmail(val)) {
                return 'Vui lòng nhập email hợp lệ';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 11),

          // Password Field
          AuthInputField(
            controller: _passwordController,
            hint: 'mật khẩu',
            prefixChild: const Icon(
              Icons.lock,
              size: 18,
              color: Color(0xFF5A384C),
            ),
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 19,
                color: const Color(0xFF9E8E9B),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (_isSignUp && val.length < 6) {
                return 'Mật khẩu phải dài ít nhất 6 ký tự';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 16),

          // Primary Submit Button ("Đăng Nhập" / "Đăng Ký")
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF653851),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isSignUp ? 'Đăng Ký' : 'Đăng Nhập',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 13),

          // "hoặc" Divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE2D6E0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'hoặc',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9E8E9B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE2D6E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),

          // Google Sign-In Button
          GoogleSignInButton(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
          ),
          const SizedBox(height: 12),

          // Switch Login / Sign-up Mode
          GestureDetector(
            onTap: () {
              setState(() {
                _isSignUp = !_isSignUp;
                _errorMessage = null;
              });
            },
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF5A384C),
                  ),
                  children: [
                    TextSpan(
                      text: _isSignUp ? 'Đã có tài khoản? ' : 'Chưa có tài khoản? ',
                    ),
                    TextSpan(
                      text: _isSignUp ? 'Đăng nhập' : 'Đăng ký',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
