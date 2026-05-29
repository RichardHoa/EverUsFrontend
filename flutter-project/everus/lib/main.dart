import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/activity.dart';
import 'widgets/preference_matcher.dart';
import 'widgets/results_dashboard.dart';
import 'widgets/activity_flow.dart';

void main() {
  runApp(const EverUsApp());
}

class EverUsApp extends StatelessWidget {
  const EverUsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EverUs - Couple Vibe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEC4899),
          primary: const Color(0xFFEC4899),
          secondary: const Color(0xFFF43F5E),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const EverUsHomePage(),
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
          top: false, // Scaffold will handle SafeArea top for AppBars
          child: pageBody,
        ),
      ),
    );
  }
}
