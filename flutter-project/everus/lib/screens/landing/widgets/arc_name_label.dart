import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The result of fitting a name onto an arc: which graphemes to draw and at
/// what font size.
class ArcLabelFit {
  final List<String> graphemes;
  final double fontSize;

  const ArcLabelFit(this.graphemes, this.fontSize);
}

/// Fits [text] onto an arc of [radius] that may sweep at most [maxSweep]
/// radians. The font first shrinks down to [minScale] of [fontSize]; if the
/// name still doesn't fit it is cut off with "…".
///
/// [measure] returns the advance width of one grapheme at a font size, and
/// [spacing] is the extra tracking between graphemes, as a fraction of the
/// font size.
ArcLabelFit fitArcLabel({
  required String text,
  required double fontSize,
  required double radius,
  required double maxSweep,
  required double spacing,
  required double Function(String grapheme, double fontSize) measure,
  double minScale = 0.8,
}) {
  double sweepOf(List<String> gs, double fs) {
    if (gs.isEmpty) return 0;
    var width = 0.0;
    for (final g in gs) {
      width += measure(g, fs);
    }
    width += spacing * fs * (gs.length - 1);
    return width / radius;
  }

  var graphemes = text.trim().characters.toList();
  final natural = sweepOf(graphemes, fontSize);
  if (natural <= maxSweep) return ArcLabelFit(graphemes, fontSize);

  final shrunk = math.max(fontSize * minScale, fontSize * maxSweep / natural);
  if (sweepOf(graphemes, shrunk) <= maxSweep) {
    return ArcLabelFit(graphemes, shrunk);
  }

  while (graphemes.length > 1 && sweepOf([...graphemes, '…'], shrunk) > maxSweep) {
    graphemes = graphemes.sublist(0, graphemes.length - 1);
    while (graphemes.length > 1 && graphemes.last.trim().isEmpty) {
      graphemes = graphemes.sublist(0, graphemes.length - 1);
    }
  }
  return ArcLabelFit([...graphemes, '…'], shrunk);
}

TextPainter _glyphPainter(String g, TextStyle style, double fontSize) => TextPainter(
      text: TextSpan(text: g, style: style.copyWith(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();

/// Draws [name] along a circular arc around a point, glyphs standing upright
/// on the outside of the circle. The widget is a square of [size] whose centre
/// is the circle's centre.
class ArcNameLabel extends StatelessWidget {
  final String name;
  final TextStyle style;

  /// Distance from the centre to the text baseline.
  final double radius;

  /// Angle of the arc's midpoint, in radians clockwise from 12 o'clock.
  final double centerAngle;
  final double maxSweep;
  final double spacing;
  final double size;

  const ArcNameLabel({
    super.key,
    required this.name,
    required this.style,
    required this.radius,
    required this.centerAngle,
    required this.size,
    this.maxSweep = math.pi,
    this.spacing = 0.45,
  });

  /// The angle the drawn name covers, in radians, once fitted to the arc.
  double get sweep {
    final fit = fitArcLabel(
      text: name,
      fontSize: style.fontSize ?? 14,
      radius: radius,
      maxSweep: maxSweep,
      spacing: spacing,
      measure: (g, fs) => _glyphPainter(g, style, fs).width,
    );
    if (fit.graphemes.isEmpty) return 0;
    var width = spacing * fit.fontSize * (fit.graphemes.length - 1);
    for (final g in fit.graphemes) {
      width += _glyphPainter(g, style, fit.fontSize).width;
    }
    return width / radius;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ArcNamePainter(
          name: name,
          style: style,
          radius: radius,
          centerAngle: centerAngle,
          maxSweep: maxSweep,
          spacing: spacing,
        ),
      ),
    );
  }
}

class _ArcNamePainter extends CustomPainter {
  final String name;
  final TextStyle style;
  final double radius;
  final double centerAngle;
  final double maxSweep;
  final double spacing;

  _ArcNamePainter({
    required this.name,
    required this.style,
    required this.radius,
    required this.centerAngle,
    required this.maxSweep,
    required this.spacing,
  });

  TextPainter _glyph(String g, double fontSize) => _glyphPainter(g, style, fontSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (name.trim().isEmpty) return;

    final fit = fitArcLabel(
      text: name,
      fontSize: style.fontSize ?? 14,
      radius: radius,
      maxSweep: maxSweep,
      spacing: spacing,
      measure: (g, fs) => _glyph(g, fs).width,
    );
    final glyphs = [for (final g in fit.graphemes) _glyph(g, fit.fontSize)];
    final gap = spacing * fit.fontSize;

    var total = 0.0;
    for (final tp in glyphs) {
      total += tp.width;
    }
    total += gap * (glyphs.length - 1);

    final center = size.center(Offset.zero);
    var angle = centerAngle - total / radius / 2;
    for (final tp in glyphs) {
      final half = tp.width / 2 / radius;
      angle += half;
      final baseline = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      canvas.save();
      canvas.translate(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      canvas.rotate(angle);
      tp.paint(canvas, Offset(-tp.width / 2, -baseline));
      canvas.restore();
      angle += half + gap / radius;
    }
  }

  @override
  bool shouldRepaint(_ArcNamePainter old) =>
      old.name != name ||
      old.style != style ||
      old.radius != radius ||
      old.centerAngle != centerAngle ||
      old.maxSweep != maxSweep ||
      old.spacing != spacing;
}
