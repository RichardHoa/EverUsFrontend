import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/app_avatar.dart';
import 'arc_name_label.dart';
import '../../../l10n/l10n.dart';

/// Love counter card from the Figma `landing_page` frame. Every measurement is
/// in the frame's units (about 3x a phone); [scale] maps them to the screen.
class MiniLoveCounter extends StatelessWidget {
  final int loveDays;
  final String userName;
  final String loverName;
  final bool userImageExists;
  final bool loverImageExists;
  final String? userImagePath;
  final String? loverImagePath;
  final VoidCallback onTap;
  final double scale;

  const MiniLoveCounter({
    super.key,
    required this.loveDays,
    required this.userName,
    required this.loverName,
    required this.userImageExists,
    required this.loverImageExists,
    required this.userImagePath,
    required this.loverImagePath,
    required this.onTap,
    required this.scale,
  });

  static const _ink = Color(0xFF6F3953);
  static const _cardWidth = 1040.65;
  static const _cardHeight = 596.3;
  static const _circleDiameter = 225.5;
  static const _nameRadius = 134.0;
  static const _nameBox = 2 * (_nameRadius + 40);
  static const _userCenterX = 267.8;
  static const _loverCenterX = 778.0;
  static const _counterGap = 20.0;
  static const _nameAngle = 35.0;
  static const _nameFontSize = 32.0;

  /// Names further than this from 12 o'clock, in degrees, sit below the
  /// counter row.
  static const _counterRowAngle = 40.0;

  @override
  Widget build(BuildContext context) {
    final k = scale;
    final radius = BorderRadius.circular(76.8 * k);
    final userLabel = _nameLabel(userName, -_nameAngle);
    final loverLabel = _nameLabel(loverName, _nameAngle);
    final left = _userCenterX + _nameReach(userLabel) + _counterGap;
    final right = _loverCenterX - _nameReach(loverLabel) - _counterGap;

    return Container(
      width: _cardWidth * k,
      height: _cardHeight * k,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: radius,
        border: Border.all(color: Colors.white, width: 2.95 * k),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB769A6).withValues(alpha: 0.4),
            offset: Offset(10.31 * k, 10.31 * k),
            blurRadius: 29.46 * k,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 45 * k,
                child: Text(
                  context.l10n.miniLoveCounterHeading,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 36.4 * k,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
              // Long counts shrink so the row stays between the two circle
              // centres, clear of the arc names.
              Positioned(
                left: left * k,
                width: (right - left) * k,
                top: 134 * k,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$loveDays',
                        style: GoogleFonts.inter(
                          fontSize: 120 * k,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 24 * k),
                      Text(
                        context.l10n.miniLoveCounterDays,
                        style: GoogleFonts.nunito(
                          fontSize: 42 * k,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 180.2 * k,
                top: 371.4 * k,
                width: 676 * k,
                child: Image.asset('assets/images/love_thread.png'),
              ),
              _circle(
                centerX: _userCenterX,
                fill: const Color(0xFFF9DCF2),
                stroke: const Color(0xFFF0B1DE),
                imagePath: userImageExists ? userImagePath : null,
              ),
              _circle(
                centerX: _loverCenterX,
                fill: const Color(0xFFE4E5BD),
                stroke: const Color(0xFFDAE096),
                imagePath: loverImageExists ? loverImagePath : null,
              ),
              _name(centerX: _userCenterX, label: userLabel),
              _name(centerX: _loverCenterX, label: loverLabel),
            ],
          ),
        ),
      ),
    );
  }

  static const _circleCenterY = 402.2;

  Widget _circle({
    required double centerX,
    required Color fill,
    required Color stroke,
    required String? imagePath,
  }) {
    final k = scale;
    final d = _circleDiameter * k;
    return Positioned(
      left: centerX * k - d / 2,
      top: _circleCenterY * k - d / 2,
      width: d,
      height: d,
      child: Container(
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: stroke, width: 4.98 * k),
        ),
        child: imagePath == null
            ? null
            : ClipOval(
                child: AppAvatar(
                  imagePath: imagePath,
                  radius: d / 2,
                  fallback: const SizedBox.shrink(),
                ),
              ),
      ),
    );
  }

  /// How far past its circle's centre a name reaches towards the middle of
  /// the card, counting only the part of the arc high enough to meet the
  /// counter row.
  static double _nameReach(ArcNameLabel label) {
    final innerEnd = label.sweep / 2 - _nameAngle * math.pi / 180;
    return (_nameRadius + _nameFontSize) *
        math.sin(innerEnd.clamp(0.0, _counterRowAngle * math.pi / 180));
  }

  ArcNameLabel _nameLabel(String name, double centerAngle) {
    final k = scale;
    return ArcNameLabel(
      name: name,
      size: _nameBox * k,
      radius: _nameRadius * k,
      centerAngle: centerAngle * math.pi / 180,
      style: GoogleFonts.nunito(
        fontSize: _nameFontSize * k,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }

  Widget _name({required double centerX, required ArcNameLabel label}) {
    final k = scale;
    final box = _nameBox * k;
    return Positioned(
      left: centerX * k - box / 2,
      top: _circleCenterY * k - box / 2,
      child: label,
    );
  }
}
