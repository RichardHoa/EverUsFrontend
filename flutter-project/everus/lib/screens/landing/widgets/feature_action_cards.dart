import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Date Planner and Relationship Reflection cards, using the illustrated
/// artwork exported from the Figma `landing_page` frame. The two images are
/// cut from one export (shadows included), so placed side by side they
/// reproduce the design's spacing. [scale] maps frame units to the screen.
///
/// The artwork's English titles were erased from the images; the Vietnamese
/// titles are drawn on top in code, where the originals sat.
class FeatureActionCards extends StatelessWidget {
  final VoidCallback onDatePlannerTap;
  final VoidCallback onReflectionTap;
  final double scale;

  const FeatureActionCards({
    super.key,
    required this.onDatePlannerTap,
    required this.onReflectionTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 45.6 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ArtworkCard(
            asset: 'assets/images/card_date_planner.png',
            title: 'Lên Lịch Hẹn Hò',
            titleRect: const Rect.fromLTWH(99, 140, 355, 80),
            width: 635,
            scale: scale,
            onTap: onDatePlannerTap,
          ),
          _ArtworkCard(
            asset: 'assets/images/card_reflection.png',
            title: 'Nhìn Lại\nMối Quan Hệ',
            titleRect: const Rect.fromLTWH(68, 72, 340, 125),
            width: 495,
            scale: scale,
            onTap: onReflectionTap,
          ),
        ],
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  final String asset;
  final String title;

  /// Where the title sits, in image pixels (which equal frame units).
  final Rect titleRect;

  /// Image width in frame units.
  final double width;
  final double scale;
  final VoidCallback onTap;

  const _ArtworkCard({
    required this.asset,
    required this.title,
    required this.titleRect,
    required this.width,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title.replaceAll('\n', ' '),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Image.asset(asset, width: width * scale, fit: BoxFit.fitWidth),
            Positioned(
              left: titleRect.left * scale,
              top: titleRect.top * scale,
              width: titleRect.width * scale,
              height: titleRect.height * scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 48 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: const Color(0xFF6F3953),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
