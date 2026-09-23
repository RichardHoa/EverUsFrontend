import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/activity.dart';
import 'widgets/preference_matcher.dart';
import 'widgets/results_dashboard.dart';
import 'widgets/activity_flow.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/questionnaire_screen.dart';
import 'utils/auth_helper.dart';
import 'utils/questionnaire_helper.dart';
import 'widgets/everus_footer.dart';
import 'utils/notification_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  await AuthHelper.initializeSession();
  await QuestionnaireHelper.initialize();
  NotificationManager.instance.initialize();
  runApp(const EverUsApp());
}

class EverUsApp extends StatelessWidget {
  const EverUsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EverUs - Couple Vibe',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (screenWidth > 600) {
          return Container(
            color: const Color(0xFF1E1B2E),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 414),
                child: ClipRect(
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(414, MediaQuery.of(context).size.height),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        }
        return child ?? const SizedBox.shrink();
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFFEC4899),
        ),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _guestBypassed = false;

  void _bypassAsGuest() {
    setState(() {
      _guestBypassed = true;
    });
  }

  @override
  void initState() {
    super.initState();
    AuthHelper.sessionNotifier.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    AuthHelper.sessionNotifier.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (AuthHelper.sessionNotifier.value == null && _guestBypassed) {
      setState(() {
        _guestBypassed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: AuthHelper.sessionNotifier,
      builder: (context, session, child) {
        // 1. If not authenticated and has not chosen guest mode, show Login first
        if (session == null && !_guestBypassed) {
          return LoginScreen(
            isOnboardingMode: true,
            onContinueAsGuest: _bypassAsGuest,
          );
        }

        // 2. Once authenticated or in guest mode, present questionnaire if not filled yet
        return ValueListenableBuilder<bool>(
          valueListenable: QuestionnaireHelper.isCompletedNotifier,
          builder: (context, isCompleted, child) {
            if (!isCompleted) {
              return QuestionnaireScreen(
                onCompleted: () {
                  QuestionnaireHelper.setQuestionnaireCompleted();
                },
              );
            }

            // 3. Questionnaire is completed -> go to LandingScreen
            return const LandingScreen();
          },
        );
      },
    );
  }
}

class EverUsHomePage extends StatefulWidget {
  const EverUsHomePage({super.key});

  @override
  State<EverUsHomePage> createState() => _EverUsHomePageState();
}

class _EverUsHomePageState extends State<EverUsHomePage> {
  String _currentPage = 'matcher'; // 'matcher' | 'results' | 'activity'
  MatcherResult? _matcherResult;
  String? _selectedActivityKey;

  void _onMatch(MatcherResult result) {
    setState(() {
      _matcherResult = result;
      _currentPage = 'results';
    });
  }

  void _onStartActivity(String activityKey) {
    setState(() {
      _selectedActivityKey = activityKey;
      _currentPage = 'activity';
    });
  }

  void _onBackToMatcher() {
    setState(() {
      _currentPage = 'matcher';
      _matcherResult = null;
      _selectedActivityKey = null;
    });
  }

  void _onBackToResults() {
    setState(() {
      _currentPage = 'results';
      _selectedActivityKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget pageBody;

    switch (_currentPage) {
      case 'results':
        if (_matcherResult == null) {
          pageBody = const Center(child: Text('No match result found.'));
        } else {
          pageBody = ResultsDashboard(
            result: _matcherResult!,
            onBack: _onBackToMatcher,
            onStart: _onStartActivity,
          );
        }
        break;
      case 'activity':
        if (_selectedActivityKey == null) {
          pageBody = const Center(child: Text('No activity selected.'));
        } else {
          final act = activities[_selectedActivityKey!];
          if (act == null) {
            pageBody = const Center(child: Text('Selected activity not found.'));
          } else {
            pageBody = ActivityFlow(
              activity: act,
              onBack: _onBackToResults,
              onComplete: _onBackToMatcher,
            );
          }
        }
        break;
      case 'matcher':
      default:
        pageBody = PreferenceMatcher(onMatch: _onMatch);
        break;
    }

    return PopScope<Object?>(
      canPop: _currentPage == 'matcher',
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (_currentPage == 'activity') {
          _onBackToResults();
        } else if (_currentPage == 'results') {
          _onBackToMatcher();
        }
      },
      child: Scaffold(
        extendBody: true,
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
            top: false, // Scaffold will handle SafeArea top for AppBars
            child: Stack(
              children: [
                pageBody,
                // Back button to Love Counter
                if (_currentPage == 'matcher')
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
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
                          Icons.arrow_back,
                          color: Color(0xFF8B5CF6),
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const EverUsFooter(currentTab: 'other'),
      ),
    );
  }
}
