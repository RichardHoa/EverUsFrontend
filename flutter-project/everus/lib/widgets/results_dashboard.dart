import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';
import 'preference_matcher.dart';
import 'spider_graph.dart';

class ResultsDashboard extends StatefulWidget {
  final MatcherResult result;
  final VoidRefCallback onBack;
  final Function(String) onStart;

  const ResultsDashboard({
    super.key,
    required this.result,
    required this.onBack,
    required this.onStart,
  });

  @override
  State<ResultsDashboard> createState() => _ResultsDashboardState();
}

typedef VoidRefCallback = void Function();

class _ResultsDashboardState extends State<ResultsDashboard> {
  late String _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.result.topActivity.key;
  }

  String _formatVND(int amount) {
    // Basic formatting: e.g. 350000 -> 350.000
    final String str = amount.toString();
    final buffer = StringBuffer();
    int len = str.length;
    for (int i = 0; i < len; i++) {
      buffer.write(str[i]);
      int pos = len - i - 1;
      if (pos > 0 && pos % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  int _getMatchPercentageFor(String key) {
    for (var r in widget.result.ranked) {
      if (r['key'] == key) {
        return r['pct'] as int;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final Activity selectedActivity = activities[_selectedKey] ?? widget.result.topActivity;
    final int matchPercentage = _getMatchPercentageFor(_selectedKey);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Kết quả tương thích',
          style: GoogleFonts.playfairDisplay(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Main result card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selectedActivity.theme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedActivity.theme.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Column(
                    children: [
                      // Card Header
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [selectedActivity.theme.primary, selectedActivity.theme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedActivity.subtitle.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    selectedActivity.emoji,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedActivity.name,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Độ tương hợp',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$matchPercentage%',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Card Body
                      Container(
                        color: selectedActivity.theme.light.withValues(alpha: 0.3),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              selectedActivity.suitFor,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Ngân sách',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_formatVND(selectedActivity.cost)} VND',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Mức độ',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${selectedActivity.levels.length} hoạt động',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => widget.onStart(_selectedKey),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedActivity.theme.primary,
                                shadowColor: selectedActivity.theme.primary.withValues(alpha: 0.4),
                                elevation: 8,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Bắt đầu ngay! ",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Preferences Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sở thích của hai bạn',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(5, (idx) {
                      return _buildDimensionBar(
                        idx: idx,
                        activityVal: selectedActivity.vec[idx],
                        userVal: widget.result.userVectorP1[idx],
                        selectedTheme: selectedActivity.theme,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Spider Graph & Legend
              SpiderGraph(
                userVector: widget.result.userVectorP1,
                activityVector: selectedActivity.vec,
                activityTheme: selectedActivity.theme,
              ),

              const SizedBox(height: 24),

              // 4. All Matches Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tất cả ý tưởng (${activities.length} tổng số)',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.result.ranked.map((item) {
                        final key = item['key'] as String;
                        final act = activities[key]!;
                        final isSelected = key == _selectedKey;
                        final pct = item['pct'] as int;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedKey = key;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? act.theme.light.withValues(alpha: 0.4) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? act.theme.primary : Colors.grey.shade200,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    act.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          act.name,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                        Text(
                                          act.duration,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$pct%',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: act.theme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionBar({
    required int idx,
    required double activityVal,
    required double userVal,
    required ActivityTheme selectedTheme,
  }) {
    final dim = dimensions[idx];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(dim.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              dim.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  // Base background
                  Container(
                    height: 10,
                    color: Colors.grey.shade200,
                  ),
                  // User preference bar (underneath, pink semi-transparent)
                  FractionallySizedBox(
                    widthFactor: userVal / 10.0,
                    child: Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF85A1), Color(0xFFF43F5E)],
                        ),
                      ),
                    ),
                  ),
                  // Selected Activity bar (in front, selected theme gradient)
                  FractionallySizedBox(
                    widthFactor: activityVal / 10.0,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [selectedTheme.secondary, selectedTheme.primary],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            activityVal.toStringAsFixed(0),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
