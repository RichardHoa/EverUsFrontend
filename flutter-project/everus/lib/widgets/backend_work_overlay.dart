import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-bleed overlay shown while the backend is doing heavy work (generating
/// a plan, etc.), so the user has something to look at instead of a blank
/// screen. Plays a looping, transparent yarn animation with a caption over
/// whatever background the caller already has in place.
///
/// The animation is an animated WebP with a real alpha channel (baked in
/// offline from the source video via `scripts/render_loading_animation.sh`),
/// not a video: `video_player` renders through a platform `<video>` element
/// on Flutter web, which sits outside Flutter's paint pipeline and can never
/// be made transparent from Dart code.
class BackendWorkOverlay extends StatelessWidget {
  static const String animationAsset = 'assets/videos/animation.webp';

  /// Caption shown under the animation, e.g. "EverUs đang lên lộ trình...".
  final String message;

  /// Const constructor for [BackendWorkOverlay].
  const BackendWorkOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // The floating pill-shaped footer overlaps the body on screens that use
    // Scaffold.extendBody, so the caption needs enough bottom clearance to
    // sit above it instead of behind it.
    final bottomClearance = 90 + MediaQuery.of(context).padding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        const SizedBox.expand(
          child: Image(
            image: AssetImage(animationAsset),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: bottomClearance,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5A384C),
              shadows: const [
                Shadow(color: Colors.white, blurRadius: 12),
                Shadow(color: Colors.white, blurRadius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
