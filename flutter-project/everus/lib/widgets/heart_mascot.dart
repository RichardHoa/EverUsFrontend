import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef EmotionState = String; // 'idle' | 'happy' | 'excited' | 'thinking' | 'love' | 'celebrating'

class HeartMascot extends StatefulWidget {
  final EmotionState emotion;
  final String? comment;
  final bool showComment;

  const HeartMascot({
    super.key,
    this.emotion = 'idle',
    this.comment,
    this.showComment = false,
  });

  @override
  State<HeartMascot> createState() => _HeartMascotState();
}

class _HeartMascotState extends State<HeartMascot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _displayComment;
  bool _isVisibleComment = false;
  Timer? _commentTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _updateComment();
  }

  @override
  void didUpdateWidget(covariant HeartMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment != oldWidget.comment || widget.showComment != oldWidget.showComment) {
      _updateComment();
    }
  }

  void _updateComment() {
    _commentTimer?.cancel();
    if (widget.showComment && widget.comment != null) {
      setState(() {
        _displayComment = widget.comment;
        _isVisibleComment = true;
      });
      // Hide after 3 seconds
      _commentTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVisibleComment = false;
          });
        }
      });
    } else {
      setState(() {
        _isVisibleComment = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentTimer?.cancel();
    super.dispose();
  }

  _FaceExpression _getFaceExpression() {
    switch (widget.emotion) {
      case 'excited':
        return const _FaceExpression(leftEye: 'O', rightEye: 'O', mouth: '︶', scale: 1.1);
      case 'happy':
        return const _FaceExpression(leftEye: '◠', rightEye: '◠', mouth: '︶', scale: 1.05);
      case 'love':
        return const _FaceExpression(leftEye: '♥', rightEye: '♥', mouth: '⌣', scale: 1.2);
      case 'thinking':
        return const _FaceExpression(leftEye: '?', rightEye: '.', mouth: '◡', scale: 0.95);
      case 'celebrating':
        return const _FaceExpression(leftEye: '★', rightEye: '★', mouth: '︶', scale: 1.1);
      default:
        return const _FaceExpression(leftEye: '○', rightEye: '○', mouth: '─', scale: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expr = _getFaceExpression();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speech Bubble
        AnimatedOpacity(
          opacity: _isVisibleComment ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: _displayComment != null
              ? Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _displayComment!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Mascot Canvas
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Sway angle based on animation controller
              final double swayAngle = widget.emotion == 'excited'
                ? math.sin(_controller.value * math.pi * 4) * 0.1
                : math.sin(_controller.value * math.pi * 2) * 0.06;

            final double verticalOffset = widget.emotion == 'excited'
                ? math.sin(_controller.value * math.pi * 4) * 5
                : widget.emotion == 'celebrating'
                    ? math.sin(_controller.value * math.pi * 4) * 8
                    : 0.0;

            final double legKickValue = _controller.value;

            return Transform.translate(
              offset: Offset(0, verticalOffset),
              child: Transform.rotate(
                angle: swayAngle,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Body, Arms and Legs Painter
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MascotPainter(
                            legAnim: legKickValue,
                            emotion: widget.emotion,
                          ),
                        ),
                      ),

                      // Face text centered inside the heart
                      Center(
                        child: Transform.scale(
                          scale: expr.scale,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      expr.leftEye,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: expr.leftEye == '♥' ? 18 : 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      expr.rightEye,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: expr.rightEye == '♥' ? 18 : 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  expr.mouth,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    height: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
      ],
    );
  }
}

class _FaceExpression {
  final String leftEye;
  final String rightEye;
  final String mouth;
  final double scale;

  const _FaceExpression({
    required this.leftEye,
    required this.rightEye,
    required this.mouth,
    required this.scale,
  });
}

class _MascotPainter extends CustomPainter {
  final double legAnim;
  final String emotion;

  _MascotPainter({required this.legAnim, required this.emotion});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw legs
    final legPaint = Paint()
      ..color = Colors.red.shade300
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double leftLegAngle = math.sin(legAnim * math.pi * 2) * 0.3;
    final double rightLegAngle = math.cos(legAnim * math.pi * 2) * 0.3;

    // Left leg origin (approx 44, 80)
    final double leftLegX = width * 0.42;
    final double leftLegY = height * 0.72;
    final double leftLegLength = height * 0.18;
    canvas.drawLine(
      Offset(leftLegX, leftLegY),
      Offset(
        leftLegX + leftLegLength * math.sin(leftLegAngle - 0.05),
        leftLegY + leftLegLength * math.cos(leftLegAngle - 0.05),
      ),
      legPaint,
    );

    // Right leg origin (approx 56, 80)
    final double rightLegX = width * 0.58;
    final double rightLegY = height * 0.72;
    final double rightLegLength = height * 0.18;
    canvas.drawLine(
      Offset(rightLegX, rightLegY),
      Offset(
        rightLegX + rightLegLength * math.sin(rightLegAngle + 0.05),
        rightLegY + rightLegLength * math.cos(rightLegAngle + 0.05),
      ),
      legPaint,
    );

    // Draw arms
    final armPaint = Paint()
      ..color = Colors.red.shade300
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left arm: sways based on emotion
    final double leftArmAngle = emotion == 'excited' || emotion == 'celebrating'
        ? -0.5 - math.sin(legAnim * math.pi * 4) * 0.3
        : -0.2;
    final double leftArmX = width * 0.22;
    final double leftArmY = height * 0.44;
    canvas.drawLine(
      Offset(leftArmX, leftArmY),
      Offset(leftArmX - 22 * math.cos(leftArmAngle), leftArmY + 22 * math.sin(leftArmAngle)),
      armPaint,
    );

    // Right arm
    final double rightArmAngle = emotion == 'excited' || emotion == 'celebrating'
        ? -0.5 - math.cos(legAnim * math.pi * 4) * 0.3
        : -0.2;
    final double rightArmX = width * 0.78;
    final double rightArmY = height * 0.44;
    canvas.drawLine(
      Offset(rightArmX, rightArmY),
      Offset(rightArmX + 22 * math.cos(rightArmAngle), rightArmY + 22 * math.sin(rightArmAngle)),
      armPaint,
    );

    // Draw heart body with a scale to fit (React SVG: size 100, ours is width/height)
    final heartPaint = Paint()
      ..color = Colors.red.shade400
      ..style = PaintingStyle.fill;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final Path heartPath = Path();

    // Map 0..100 coordinates to canvas size
    double mapX(double x) => x * (width / 100);
    double mapY(double y) => y * (height / 100) - 10; // offset up slightly for legs

    heartPath.moveTo(mapX(50), mapY(95));
    heartPath.cubicTo(mapX(20), mapY(75), mapX(5), mapY(60), mapX(5), mapY(45));
    heartPath.cubicTo(mapX(5), mapY(30), mapX(15), mapY(20), mapX(25), mapY(20));
    heartPath.cubicTo(mapX(35), mapY(20), mapX(45), mapY(28), mapX(50), mapY(35));
    heartPath.cubicTo(mapX(55), mapY(28), mapX(65), mapY(20), mapX(75), mapY(20));
    heartPath.cubicTo(mapX(85), mapY(20), mapX(95), mapY(30), mapX(95), mapY(45));
    heartPath.cubicTo(mapX(95), mapY(60), mapX(80), mapY(75), mapX(50), mapY(95));
    heartPath.close();

    // Draw shadow path slightly offset
    canvas.drawPath(heartPath.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) {
    return oldDelegate.legAnim != legAnim || oldDelegate.emotion != emotion;
  }
}
