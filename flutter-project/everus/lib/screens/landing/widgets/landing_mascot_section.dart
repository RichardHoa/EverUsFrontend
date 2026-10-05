import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MascotInteraction {
  final String emotion;
  final String comment;

  const MascotInteraction({required this.emotion, required this.comment});
}

const List<MascotInteraction> kDefaultMascotInteractions = [
  MascotInteraction(
    emotion: 'happy',
    comment: 'Hôm nay tụi mình đi đâu chơi nhỉ? 🤔',
  ),
  MascotInteraction(
    emotion: 'love',
    comment: 'Yêu cậu nhiều lắm á! ♥',
  ),
  MascotInteraction(
    emotion: 'excited',
    comment: 'Lên lịch hẹn hò thôi! Tớ đã sẵn sàng! 🚀',
  ),
  MascotInteraction(
    emotion: 'celebrating',
    comment: 'Cùng tạo nên thật nhiều kỉ niệm nhé! 🥳',
  ),
  MascotInteraction(
    emotion: 'thinking',
    comment: 'Hai cậu trông thật là đẹp đôi luôn á! 💑',
  ),
  MascotInteraction(
    emotion: 'happy',
    comment: 'Chạm vào tớ tiếp đi, tớ thích lắm! 🥰',
  ),
];

/// Yarn-ball mascot with its thought bubble, laid out from the Figma
/// `landing_page` frame. Measurements are in the frame's units (about 3x a
/// phone); [scale] maps them to the screen.
class LandingMascotSection extends StatefulWidget {
  final String comment;
  final VoidCallback onTap;
  final double scale;

  const LandingMascotSection({
    super.key,
    required this.comment,
    required this.onTap,
    required this.scale,
  });

  /// Height of the section in frame units: the yarn ball's frame plus room
  /// above the bubble for a second line of text.
  static const double frameHeight = 669.5;

  @override
  State<LandingMascotSection> createState() => _LandingMascotSectionState();
}

class _LandingMascotSectionState extends State<LandingMascotSection>
    with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  @override
  void dispose() {
    _idle.dispose();
    _tap.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tap.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.scale;
    return SizedBox(
      height: LandingMascotSection.frameHeight * k,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 208.2 * k,
            top: 140.1 * k,
            width: 944.7 * k,
            height: 529.3 * k,
            child: GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: Listenable.merge([_idle, _tap]),
                builder: (context, child) {
                  final t = _idle.value * 2 * math.pi;
                  final p = _tap.value;
                  final squish = math.sin(p * 2 * math.pi) * (1 - p) * 0.12;
                  final hop = math.sin(p * math.pi) * 24 * k;
                  final breathe = 1 + 0.02 * math.sin(t);
                  return Transform.translate(
                    offset: Offset(0, math.sin(t) * 10 * k - hop),
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.diagonal3Values(
                        breathe * (1 + squish),
                        breathe * (1 - squish),
                        1,
                      ),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/mascot_yarn.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 170.8 * k,
            bottom: 447.9 * k,
            child: GestureDetector(
              onTap: _handleTap,
              child: _ThoughtBubble(text: widget.comment, scale: k),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThoughtBubble extends StatelessWidget {
  final String text;
  final double scale;

  const _ThoughtBubble({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    final k = scale;
    return SizedBox(
      width: 478 * k,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            painter: _BubbleBodyPainter(scale: k),
            child: Padding(
              padding: EdgeInsets.fromLTRB(37 * k, 24 * k, 30 * k, 24 * k),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  text,
                  key: ValueKey(text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 29.34 * k,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF6F3953),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 92.3 * k,
            child: Stack(
              children: [
                Positioned(left: 314.8 * k, top: 26.4 * k, child: _puff(42.1 * k)),
                Positioned(left: 349.8 * k, top: 73.6 * k, child: _puff(18.7 * k)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _puff(double d) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: scale),
        ),
      );
}

/// The bubble's rounded body with the small round bump under it, as drawn in
/// the Figma bubble outline.
class _BubbleBodyPainter extends CustomPainter {
  final double scale;

  _BubbleBodyPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final k = scale;
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(20 * k)));
    final bump = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(349.5 * k, size.height - 2.7 * k),
        radius: 20.5 * k,
      ));
    final shape = Path.combine(PathOperation.union, body, bump);

    canvas.drawPath(shape, Paint()..color = Colors.white.withValues(alpha: 0.56));
    canvas.drawPath(
      shape,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = k,
    );
  }

  @override
  bool shouldRepaint(_BubbleBodyPainter old) => old.scale != scale;
}
