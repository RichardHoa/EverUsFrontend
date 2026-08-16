import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reflection_models.dart';
import '../../utils/reflection_helper.dart';
import 'reflection_topic_screen.dart';
import 'reflection_summary_screen.dart';
import 'reflection_diary_screen.dart';
import 'widgets/personal_sanctuary_tab.dart';
import 'widgets/us_insights_tab.dart';

class ReflectionHomeScreen extends StatefulWidget {
  const ReflectionHomeScreen({super.key});

  @override
  State<ReflectionHomeScreen> createState() => _ReflectionHomeScreenState();
}

class _ReflectionHomeScreenState extends State<ReflectionHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ReflectionItem> _reflections = [];
  List<MemoryPattern> _patterns = [];
  List<SharedRelationshipInsight> _sharedInsights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final reflections = await ReflectionHelper.loadReflections();
    final patterns = await ReflectionHelper.loadPatterns();
    final shared = ReflectionHelper.getSharedInsights();

    if (mounted) {
      setState(() {
        _reflections = reflections;
        _patterns = patterns;
        _sharedInsights = shared;
        _loading = false;
      });
    }
  }

  void _startReflection() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const ReflectionTopicScreen(),
            settings: const RouteSettings(name: 'reflection_topic'),
          ),
        )
        .then((_) => _loadData());
  }

  void _viewReflectionDetail(ReflectionItem item) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ReflectionSummaryScreen(item: item),
          ),
        )
        .then((_) => _loadData());
  }

  void _openDiaryPage() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ReflectionDiaryScreen(
              reflections: _reflections,
              onViewDetail: _viewReflectionDetail,
            ),
          ),
        )
        .then((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF5F5), // ultra-light pink
              Colors.white,
              Color(0xFFFAF5FF), // ultra-light lavender
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
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
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF8B5CF6),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EverUs Reflection',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Góc thấu cảm & phản chiếu mối quan hệ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Switcher: Cá nhân (Private) vs Chúng mình (Us)
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF3E8FF),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Cá nhân'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_outline_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Chúng mình (Us)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          PersonalSanctuaryTab(
                            reflections: _reflections,
                            patterns: _patterns,
                            onStartReflection: _startReflection,
                            onViewDetail: _viewReflectionDetail,
                            onViewAllReflections: _openDiaryPage,
                          ),
                          UsInsightsTab(
                            sharedInsights: _sharedInsights,
                            onStartReflection: _startReflection,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
