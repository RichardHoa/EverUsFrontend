import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';

class MatcherResult {
  final List<Map<String, dynamic>> ranked; // List of { 'key': String, 'score': double, 'pct': int }
  final List<double> userVectorP1;
  final List<double> userVectorP2;
  final Activity topActivity;
  final int matchPercentage;

  MatcherResult({
    required this.ranked,
    required this.userVectorP1,
    required this.userVectorP2,
    required this.topActivity,
    required this.matchPercentage,
  });
}

class PreferenceMatcher extends StatefulWidget {
  final Function(MatcherResult) onMatch;

  const PreferenceMatcher({super.key, required this.onMatch});

  @override
  State<PreferenceMatcher> createState() => _PreferenceMatcherState();
}

class _PreferenceMatcherState extends State<PreferenceMatcher> {
  bool _isCouple = false;

  // Partner 1
  double _romance = 8;
  double _adventure = 5;
  double _creative = 6;
  double _indoor = 7;
  double _energy = 5;

  // Partner 2
  double _romance2 = 7;
  double _adventure2 = 6;
  double _creative2 = 5;
  double _indoor2 = 6;
  double _energy2 = 6;

  int _budgetMin = 100000;
  int _budgetMax = 700000;
  int _stage = 1;

  final List<String> _stageLabels = ['Trò chuyện', '1–3 tháng', '3–6 tháng', 'Trên 6 tháng'];

  void _handleMatch() {
    List<double> p1 = [_romance, _adventure, _creative, _indoor, _energy];
    List<double> p2 = _isCouple 
        ? [_romance2, _adventure2, _creative2, _indoor2, _energy2]
        : List.from(p1); // use p1 as default if single

    // Calculate scores for each activity
    List<Map<String, dynamic>> scores = [];

    activities.forEach((key, activity) {
      double sumSq1 = 0;
      for (int i = 0; i < 5; i++) {
        sumSq1 += (p1[i] - activity.vec[i]) * (p1[i] - activity.vec[i]);
      }
      double dist = math.sqrt(sumSq1);

      if (_isCouple) {
        double sumSq2 = 0;
        for (int i = 0; i < 5; i++) {
          sumSq2 += (p2[i] - activity.vec[i]) * (p2[i] - activity.vec[i]);
        }
        double dist2 = math.sqrt(sumSq2);
        dist = (dist + dist2) / 2;
      }

      // Convert distance to score
      double score = 100 - dist * 10;
      scores.add({'key': key, 'score': score});
    });

    // Sort by score descending
    scores.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    double maxScore = scores[0]['score'];
    double minScore = scores[scores.length - 1]['score'];
    double range = maxScore - minScore;
    if (range == 0) range = 1.0;

    List<Map<String, dynamic>> ranked = scores.map((s) {
      int pct = (((s['score'] as double) - minScore) / range * 100).round();
      return {
        'key': s['key'] as String,
        'score': s['score'] as double,
        'pct': pct,
      };
    }).toList();

    String topKey = ranked.isNotEmpty ? ranked[0]['key'] : 'cooking';
    Activity topActivity = activities[topKey] ?? activities.values.first;
    int matchPercentage = ranked.isNotEmpty ? ranked[0]['pct'] : 0;

    widget.onMatch(
      MatcherResult(
        ranked: ranked,
        userVectorP1: p1,
        userVectorP2: _isCouple ? p2 : p1,
        topActivity: topActivity,
        matchPercentage: matchPercentage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 1024;
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24.0 : 12.0,
                vertical: isDesktop ? 32.0 : 16.0,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(isDesktop),
                      const SizedBox(height: 24),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildLeftColumn(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 5,
                              child: _buildCenterColumn(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _buildRightColumn(),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCenterColumn(),
                            const SizedBox(height: 16),
                            _buildRightColumn(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFC084FC), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 24,
        vertical: isDesktop ? 48 : 24,
      ),
      child: Column(
        children: [
          Text(
            'EverUs',
            style: GoogleFonts.playfairDisplay(
              fontSize: isDesktop ? 54 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'GỢI Ý HẸN HÒ',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 12 : 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxWidth: 512),
            child: Text(
              "Hãy cho tụi mình biết vibe của hai bạn — tụi mình sẽ tìm ý tưởng hẹn hò phù hợp nhất.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 16 : 13,
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstructionCard(
          romanNumeral: 'Ⅰ',
          title: 'Cách hoạt động',
          description: "Điều chỉnh sở thích của hai bạn qua 5 khía cạnh. Thuật toán sẽ tìm ý tưởng phù hợp nhất cho cả hai.",
          gradientColors: [Color(0xFFFCE7F3), Color(0xFFFDF2F8)],
          borderColor: Color(0xFFFBCFE8),
        ),
        SizedBox(height: 16),
        InstructionCard(
          romanNumeral: 'Ⅱ',
          title: 'Thuật toán',
          description: 'Phương pháp bình phương tối thiểu giúp tìm điểm khớp nhất trong không gian ý tưởng.',
          gradientColors: [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
          borderColor: Color(0xFFE9D5FF),
          extraChild: AlgorithmFormulaBlock(),
        ),
        SizedBox(height: 16),
        InstructionCard(
          romanNumeral: 'Ⅲ',
          title: 'Kết quả của bạn',
          description: 'Nhận danh sách ý tưởng được xếp hạng, phân tích khía cạnh và điểm số tương thích.',
          gradientColors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
          borderColor: Color(0xFFBFDBFE),
        ),
      ],
    );
  }

  Widget _buildCenterColumn() {
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bạn',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Điều chỉnh sở thích của bạn',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          VibeSlider(
            label: 'Lãng mạn',
            icon: '💕',
            value: _romance,
            onChanged: (val) => _romance = val,
            colors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
          VibeSlider(
            label: 'Phiêu lưu',
            icon: '🧗',
            value: _adventure,
            onChanged: (val) => _adventure = val,
            colors: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
          ),
          VibeSlider(
            label: 'Sáng tạo',
            icon: '🎨',
            value: _creative,
            onChanged: (val) => _creative = val,
            colors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
          ),
          VibeSlider(
            label: 'Trong nhà',
            icon: '🏠',
            value: _indoor,
            onChanged: (val) => _indoor = val,
            colors: const [Color(0xFF22C55E), Color(0xFF10B981)],
          ),
          VibeSlider(
            label: 'Năng lượng',
            icon: '⚡',
            value: _energy,
            onChanged: (val) => _energy = val,
            colors: const [Color(0xFFF97316), Color(0xFFFBBF24)],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Theme(
            data: ThemeData(
              unselectedWidgetColor: const Color(0xFFD1D5DB),
            ),
            child: Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: _isCouple,
                onChanged: (val) => setState(() => _isCouple = val ?? false),
                title: Text(
                  'Thêm sở thích của Người ấy',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                activeColor: const Color(0xFF8B5CF6),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ),
          if (_isCouple) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Text(
              'Người ấy',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            VibeSlider(
              label: 'Lãng mạn',
              icon: '💕',
              value: _romance2,
              onChanged: (val) => _romance2 = val,
              colors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
            VibeSlider(
              label: 'Phiêu lưu',
              icon: '🧗',
              value: _adventure2,
              onChanged: (val) => _adventure2 = val,
              colors: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
            ),
            VibeSlider(
              label: 'Sáng tạo',
              icon: '🎨',
              value: _creative2,
              onChanged: (val) => _creative2 = val,
              colors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
            ),
            VibeSlider(
              label: 'Trong nhà',
              icon: '🏠',
              value: _indoor2,
              onChanged: (val) => _indoor2 = val,
              colors: const [Color(0xFF22C55E), Color(0xFF10B981)],
            ),
            VibeSlider(
              label: 'Năng lượng',
              icon: '⚡',
              value: _energy2,
              onChanged: (val) => _energy2 = val,
              colors: const [Color(0xFFF97316), Color(0xFFFBBF24)],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          enableBlur: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '💸 Khoảng ngân sách',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tối thiểu (VND)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _budgetMin.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null) _budgetMin = parsed;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tối đa (VND)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _budgetMax.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null) _budgetMax = parsed;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          enableBlur: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '💑 Giai đoạn mối quan hệ',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _stageLabels.length,
                itemBuilder: (context, idx) {
                  final isSelected = _stage == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _stage = idx),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _stageLabels[idx],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CTAButton(onPressed: _handleMatch),
        const SizedBox(height: 16),
        Text(
          "Chế độ đôi: Tụi mình sẽ tìm ý tưởng hẹn hò phù hợp nhất với sở thích của cả hai bằng phương pháp tối thiểu hoá bình phương.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF4B5563),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class InstructionCard extends StatelessWidget {
  final String romanNumeral;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final Color borderColor;
  final Widget? extraChild;

  const InstructionCard({
    super.key,
    required this.romanNumeral,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.borderColor,
    this.extraChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$romanNumeral $title',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (extraChild != null) ...[
            extraChild!,
            const SizedBox(height: 8),
          ],
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AlgorithmFormulaBlock extends StatelessWidget {
  const AlgorithmFormulaBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'x = argmin ||Ax - v||²',
        style: GoogleFonts.firaCode(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFDB2777),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool enableBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: enableBlur ? 0.7 : 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );

    if (enableBlur) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: cardContent,
        ),
      );
    }

    return RepaintBoundary(
      child: cardContent,
    );
  }
}

class VibeSlider extends StatefulWidget {
  final String label;
  final String icon;
  final double value;
  final ValueChanged<double> onChanged;
  final List<Color> colors;

  const VibeSlider({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<VibeSlider> createState() => _VibeSliderState();
}

class _VibeSliderState extends State<VibeSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant VibeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startColor = widget.colors[0];
    final endColor = widget.colors[1];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: startColor,
                ),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentValue.round().toString(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) => _handleGesture(details.localPosition.dx, trackWidth),
                onTapDown: (details) => _handleGesture(details.localPosition.dx, trackWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFE5E7EB),
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _currentValue / 10,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.colors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(10, (index) {
                          final tick = index + 1;
                          final isActive = tick <= _currentValue;
                          final tickColor = isActive
                              ? (tick <= _currentValue / 2 ? startColor : endColor)
                              : const Color(0xFFD1D5DB);
                          return Expanded(
                            child: Center(
                              child: Container(
                                width: 2,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: tickColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  void _handleGesture(double localDx, double width) {
    if (width <= 0) return;
    double rawValue = (localDx / width) * 10;
    double newValue = rawValue.roundToDouble().clamp(1.0, 10.0);
    if (newValue != _currentValue) {
      setState(() => _currentValue = newValue);
      widget.onChanged(newValue);
    }
  }
}

class CTAButton extends StatefulWidget {
  final VoidCallback onPressed;

  const CTAButton({super.key, required this.onPressed});

  @override
  State<CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<CTAButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            '✨ Tìm ý tưởng hẹn hò hoàn hảo',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
