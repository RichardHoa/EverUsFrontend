import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';

class SpiderGraph extends StatefulWidget {
  final List<double> userVector;
  final List<double> activityVector;
  final ActivityTheme activityTheme;

  const SpiderGraph({
    super.key,
    required this.userVector,
    required this.activityVector,
    required this.activityTheme,
  });

  @override
  State<SpiderGraph> createState() => _SpiderGraphState();
}

class _SpiderGraphState extends State<SpiderGraph> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late List<double> _sourceUserVector;
  late List<double> _targetUserVector;

  late List<double> _sourceActivityVector;
  late List<double> _targetActivityVector;

  late ActivityTheme _sourceTheme;
  late ActivityTheme _targetTheme;

  int? _hoveredDimension;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _sourceUserVector = List.from(widget.userVector);
    _targetUserVector = List.from(widget.userVector);

    _sourceActivityVector = List.from(widget.activityVector);
    _targetActivityVector = List.from(widget.activityVector);

    _sourceTheme = widget.activityTheme;
    _targetTheme = widget.activityTheme;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpiderGraph oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsAnimation = false;

    if (!_areVectorsEqual(widget.userVector, oldWidget.userVector) ||
        !_areVectorsEqual(widget.activityVector, oldWidget.activityVector) ||
        widget.activityTheme != oldWidget.activityTheme) {
      
      final double t = _animation.value;
      _sourceUserVector = _interpolateVector(_sourceUserVector, _targetUserVector, t);
      _targetUserVector = List.from(widget.userVector);

      _sourceActivityVector = _interpolateVector(_sourceActivityVector, _targetActivityVector, t);
      _targetActivityVector = List.from(widget.activityVector);

      _sourceTheme = _interpolateTheme(_sourceTheme, _targetTheme, t);
      _targetTheme = widget.activityTheme;

      needsAnimation = true;
    }

    if (needsAnimation) {
      _controller.forward(from: 0.0);
    }
  }

  bool _areVectorsEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<double> _interpolateVector(List<double> start, List<double> end, double t) {
    final List<double> result = [];
    for (int i = 0; i < start.length; i++) {
      result.add(start[i] + (end[i] - start[i]) * t);
    }
    return result;
  }

  ActivityTheme _interpolateTheme(ActivityTheme start, ActivityTheme end, double t) {
    return ActivityTheme(
      primary: Color.lerp(start.primary, end.primary, t) ?? end.primary,
      secondary: Color.lerp(start.secondary, end.secondary, t) ?? end.secondary,
      accent: Color.lerp(start.accent, end.accent, t) ?? end.accent,
      light: Color.lerp(start.light, end.light, t) ?? end.light,
      dark: Color.lerp(start.dark, end.dark, t) ?? end.dark,
    );
  }

  void _handleTap(TapUpDetails details, Size size) {
    final double center = size.width / 2;
    final double dx = details.localPosition.dx - center;
    final double dy = details.localPosition.dy - center;

    final double distance = math.sqrt(dx * dx + dy * dy);
    if (distance < 10) {
      // Tapped too close to center
      return;
    }

    // Calculate angle from center (-pi/2 is top)
    double angle = math.atan2(dy, dx);
    // Normalize to 0 to 2*pi range starting from top (-pi/2)
    double normalizedAngle = angle + math.pi / 2;
    if (normalizedAngle < 0) {
      normalizedAngle += 2 * math.pi;
    }

    final double slice = (2 * math.pi) / 5;
    // Calculate dimension index (0 to 4)
    int index = (((normalizedAngle + slice / 2) % (2 * math.pi)) / slice).floor();
    index = index % 5;

    setState(() {
      _hoveredDimension = (_hoveredDimension == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;
        final List<double> currentUserVec = _interpolateVector(_sourceUserVector, _targetUserVector, t);
        final List<double> currentActVec = _interpolateVector(_sourceActivityVector, _targetActivityVector, t);
        final ActivityTheme currentTheme = _interpolateTheme(_sourceTheme, _targetTheme, t);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Phân Tích Độ Tương Hợp Ý Tưởng',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ý Tưởng vs Sở Thích Của Bạn',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),

              // SVG-like Canvas
              RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      return GestureDetector(
                        onTapUp: (details) => _handleTap(details, size),
                        child: CustomPaint(
                          size: size,
                          painter: _RadarChartPainter(
                            userVector: currentUserVec,
                            activityVector: currentActVec,
                            theme: currentTheme,
                            hoveredIdx: _hoveredDimension,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Legend
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      color: currentTheme.primary,
                      label: 'Độ khớp của ý tưởng',
                      desc: 'Mức độ ý tưởng',
                      isDashed: false,
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFEC4899),
                      label: 'Sở thích của bạn',
                      desc: 'Mức độ mong muốn',
                      isDashed: false,
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFFBBF24),
                      label: 'Tương thích lý tưởng',
                      desc: 'Điểm 10 hoàn hảo',
                      isDashed: true,
                    ),
                  ],
                ),
              ),

              // Explanatory note
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Chạm vào các biểu tượng để xem phần trăm tương thích',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),

              // Hover / Tap Details Card
              if (_hoveredDimension != null) ...[
                const SizedBox(height: 12),
                _buildAlignmentCard(context, _hoveredDimension!, currentUserVec, currentActVec),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String desc,
    required bool isDashed,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isDashed ? null : color.withValues(alpha: 0.6),
                  border: Border.all(
                    color: color,
                    width: 1.5,
                    style: isDashed ? BorderStyle.none : BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: isDashed
                    ? CustomPaint(
                        painter: _DashedRectPainter(color: color),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentCard(BuildContext context, int index, List<double> currentUserVec, List<double> currentActVec) {
    final dim = dimensions[index];
    final actVal = currentActVec[index];
    final userVal = currentUserVec[index];
    final alignmentPct = ((1.0 - (actVal - userVal).abs() / 10.0) * 100).round();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dim.icon} ${dim.label}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn('Ý tưởng', '${actVal.toStringAsFixed(0)}/10'),
              _buildMetricColumn('Sở thích', '${userVal.toStringAsFixed(0)}/10'),
              _buildMetricColumn(
                'Độ khớp',
                '$alignmentPct%',
                valueColor: const Color(0xFF059669),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // Draw simple dashed line box
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarChartPainter extends CustomPainter {
  final List<double> userVector;
  final List<double> activityVector;
  final ActivityTheme theme;
  final int? hoveredIdx;

  _RadarChartPainter({
    required this.userVector,
    required this.activityVector,
    required this.theme,
    this.hoveredIdx,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double maxRadius = (size.width / 2) * 0.7;
    const int numDimensions = 5;
    const double angleSlice = (math.pi * 2) / numDimensions;

    Offset getCoordinates(int dim, double val) {
      final double normalized = val / 10.0;
      final double radius = normalized * maxRadius;
      final double angle = angleSlice * dim - math.pi / 2; // -pi/2 points straight up
      return Offset(
        center + radius * math.cos(angle),
        center + radius * math.sin(angle),
      );
    }

    // 1. Draw web grid circles (representing value levels)
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final List<double> gridScales = [2.0, 4.0, 6.0, 8.0, 10.0];
    for (var scale in gridScales) {
      // Draw grid pentagon instead of circle, matching the web design style
      final Path gridPath = Path();
      for (int i = 0; i < numDimensions; i++) {
        final pt = getCoordinates(i, scale);
        if (i == 0) {
          gridPath.moveTo(pt.dx, pt.dy);
        } else {
          gridPath.lineTo(pt.dx, pt.dy);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    // 2. Draw axis lines from center to outer pentagon corners
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < numDimensions; i++) {
      final outerPt = getCoordinates(i, 10.0);
      canvas.drawLine(Offset(center, center), outerPt, axisPaint);
    }

    // 3. Draw Ideal Match polygon (dashed gold/amber outline)
    final idealPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path idealPath = Path();
    for (int i = 0; i < numDimensions; i++) {
      final pt = getCoordinates(i, 10.0);
      if (i == 0) {
        idealPath.moveTo(pt.dx, pt.dy);
      } else {
        idealPath.lineTo(pt.dx, pt.dy);
      }
    }
    idealPath.close();
    // In Flutter, simple dashed path can be simulated or drawn as lines
    canvas.drawPath(idealPath, idealPaint);

    // 4. Draw Activity polygon (theme gradient filled)
    final Path activityPath = Path();
    for (int i = 0; i < numDimensions; i++) {
      final pt = getCoordinates(i, activityVector[i]);
      if (i == 0) {
        activityPath.moveTo(pt.dx, pt.dy);
      } else {
        activityPath.lineTo(pt.dx, pt.dy);
      }
    }
    activityPath.close();

    final activityFillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primary.withValues(alpha: hoveredIdx != null ? 0.3 : 0.5),
          theme.accent.withValues(alpha: hoveredIdx != null ? 0.4 : 0.7),
        ],
      ).createShader(Rect.fromCircle(center: Offset(center, center), radius: maxRadius))
      ..style = PaintingStyle.fill;

    final activityBorderPaint = Paint()
      ..color = theme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(activityPath, activityFillPaint);
    canvas.drawPath(activityPath, activityBorderPaint);

    // 5. Draw User polygon (pink filled)
    final Path userPath = Path();
    for (int i = 0; i < numDimensions; i++) {
      final pt = getCoordinates(i, userVector[i]);
      if (i == 0) {
        userPath.moveTo(pt.dx, pt.dy);
      } else {
        userPath.lineTo(pt.dx, pt.dy);
      }
    }
    userPath.close();

    final userFillPaint = Paint()
      ..color = const Color(0xFFEC4899).withValues(alpha: hoveredIdx != null ? 0.25 : 0.45)
      ..style = PaintingStyle.fill;

    final userBorderPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(userPath, userFillPaint);
    canvas.drawPath(userPath, userBorderPaint);

    // 6. Draw dots and dimension label icons
    final double labelDistance = maxRadius + 22.0;

    for (int i = 0; i < numDimensions; i++) {
      final actPt = getCoordinates(i, activityVector[i]);
      final userPt = getCoordinates(i, userVector[i]);

      final bool isHovered = hoveredIdx == i;

      // Draw Activity dot
      final actDotPaint = Paint()
        ..color = isHovered ? theme.primary : theme.primary.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(actPt, isHovered ? 6.0 : 4.5, actDotPaint);

      // Draw User dot
      final userDotPaint = Paint()
        ..color = const Color(0xFFEC4899)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(userPt, isHovered ? 5.0 : 3.5, userDotPaint);

      // Render icons
      final angle = angleSlice * i - math.pi / 2;
      final labelOffset = Offset(
        center + labelDistance * math.cos(angle),
        center + labelDistance * math.sin(angle),
      );

      final String emoji = dimensions[i].icon;
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: GoogleFonts.inter(
            fontSize: isHovered ? 20 : 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.hoveredIdx != hoveredIdx ||
        oldDelegate.userVector != userVector ||
        oldDelegate.activityVector != activityVector ||
        oldDelegate.theme != theme;
  }
}
