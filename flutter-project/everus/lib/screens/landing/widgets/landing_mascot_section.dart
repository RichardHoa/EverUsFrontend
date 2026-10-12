import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/l10n.dart';

const String kDefaultMascotImage = 'assets/images/mascot_yarn.png';
const String _pinkHappy = 'assets/images/mascot_pink_happy.png';
const String _pinkCheeky = 'assets/images/mascot_pink_cheeky.png';
const String _greenGlasses = 'assets/images/mascot_green_glasses.png';
const String _pair = 'assets/images/mascot_pair.png';

/// One tap reaction: the bubble's comment and the mascot face shown with it.
/// Every image shares the yarn ball's canvas so faces swap in place.
class MascotInteraction {
  final String image;
  final String Function(AppLocalizations) comment;

  const MascotInteraction({required this.image, required this.comment});
}

String _mascotComment1(AppLocalizations l) => l.mascotComment1;
String _mascotComment2(AppLocalizations l) => l.mascotComment2;
String _mascotComment3(AppLocalizations l) => l.mascotComment3;
String _mascotComment4(AppLocalizations l) => l.mascotComment4;
String _mascotComment5(AppLocalizations l) => l.mascotComment5;
String _mascotComment6(AppLocalizations l) => l.mascotComment6;

const List<MascotInteraction> kDefaultMascotInteractions = [
  MascotInteraction(
    image: _greenGlasses,
    comment: _mascotComment1,
  ),
  MascotInteraction(
    image: _pinkHappy,
    comment: _mascotComment2,
  ),
  MascotInteraction(
    image: _pinkCheeky,
    comment: _mascotComment3,
  ),
  MascotInteraction(
    image: kDefaultMascotImage,
    comment: _mascotComment4,
  ),
  MascotInteraction(
    image: _pair,
    comment: _mascotComment5,
  ),
  MascotInteraction(
    image: _pinkCheeky,
    comment: _mascotComment6,
  ),
];

/// Yarn-ball mascot with its thought bubble, laid out from the Figma
/// `landing_page` frame. Measurements are in the frame's units (about 3x a
/// phone); [scale] maps them to the screen.
class LandingMascotSection extends StatefulWidget {
  final String image;
  final String comment;
  final VoidCallback onTap;
  final double scale;

  const LandingMascotSection({
    super.key,
    required this.image,
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

  /// The face to keep showing until the tap hop reaches its top.
  String? _previousImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final m in kDefaultMascotInteractions) {
      precacheImage(AssetImage(m.image), context);
    }
  }

  @override
  void didUpdateWidget(LandingMascotSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _previousImage = oldWidget.image;
  }

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
                  final image = _previousImage != null && _tap.isAnimating && p < 0.5
                      ? _previousImage!
                      : widget.image;
                  return Transform.translate(
                    offset: Offset(0, math.sin(t) * 10 * k - hop),
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.diagonal3Values(
                        breathe * (1 + squish),
                        breathe * (1 - squish),
                        1,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          image,
                          key: ValueKey(image),
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  );
                },
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
