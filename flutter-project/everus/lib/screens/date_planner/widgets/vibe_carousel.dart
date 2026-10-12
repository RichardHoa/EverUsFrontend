import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/l10n.dart';

/// Sideways carousel of illustrated Vibe cards.
///
/// The selected card gets a thicker plum border and a slight lift, and is
/// scrolled into view. Sizes are Figma frame units multiplied by [scale].
class VibeCarousel extends StatefulWidget {
  /// The selected vibe key ('casual', 'romantic' or 'adventure').
  final String selectedVibe;

  /// Called with the tapped vibe key.
  final ValueChanged<String> onVibeSelected;

  /// Figma frame units → logical pixels.
  final double scale;

  const VibeCarousel({
    super.key,
    required this.selectedVibe,
    required this.onVibeSelected,
    required this.scale,
  });

  @override
  State<VibeCarousel> createState() => _VibeCarouselState();
}

class _Vibe {
  final String key;
  final String image;
  final Color labelColor;
  final Color descriptionColor;

  const _Vibe(this.key, this.image, this.labelColor, this.descriptionColor);
}

class _VibeCarouselState extends State<VibeCarousel> {
  static const _ink = Color(0xFF6F3953);
  static const _cardWidth = 446.6;
  static const _cardHeight = 489.7;
  static const _lift = 18.0;

  static const _vibes = [
    _Vibe('casual', 'assets/images/vibe_casual.png', _ink, _ink),
    _Vibe('romantic', 'assets/images/vibe_romantic.png',
        Colors.white, Color(0xFFFCECF4)),
    _Vibe('adventure', 'assets/images/vibe_adventure.png',
        _ink, _ink),
  ];

  static const _gap = 20.0;
  static const _sidePadding = 40.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected(animate: false));
  }

  @override
  void didUpdateWidget(VibeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedVibe != widget.selectedVibe) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected(animate: true));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Centres the selected card horizontally (only this row scrolls, not the form around it).
  void _revealSelected({required bool animate}) {
    if (!mounted || !_scrollController.hasClients) return;
    final k = widget.scale;
    final index = _vibes.indexWhere((v) => v.key == widget.selectedVibe);
    if (index < 0) return;
    final position = _scrollController.position;
    final cardCentre = (_sidePadding + index * (_cardWidth + _gap) + _cardWidth / 2) * k;
    final target = (cardCentre - position.viewportDimension / 2)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (animate) {
      _scrollController.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.scale;
    return SizedBox(
      height: (_cardHeight + _lift + 24) * k,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(_sidePadding * k, _lift * k, _sidePadding * k, 24 * k),
        clipBehavior: Clip.none,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final vibe in _vibes) ...[
              if (vibe != _vibes.first) SizedBox(width: _gap * k),
              _card(vibe),
            ],
          ],
        ),
      ),
    );
  }

  String _label(_Vibe vibe) {
    final l = context.l10n;
    switch (vibe.key) {
      case 'romantic':
        return l.vibeRomantic;
      case 'adventure':
        return l.vibeAdventure;
      default:
        return l.vibeCasual;
    }
  }

  String _description(_Vibe vibe) {
    final l = context.l10n;
    switch (vibe.key) {
      case 'romantic':
        return l.vibeRomanticDescription;
      case 'adventure':
        return l.vibeAdventureDescription;
      default:
        return l.vibeCasualDescription;
    }
  }

  Widget _card(_Vibe vibe) {
    final k = widget.scale;
    final selected = vibe.key == widget.selectedVibe;
    final radius = BorderRadius.circular(53.7 * k);

    return GestureDetector(
      onTap: () => widget.onVibeSelected(vibe.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: _cardWidth * k,
        height: _cardHeight * k,
        transform: Matrix4.translationValues(0, selected ? -_lift * k : 0, 0),
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.3 : 0.25),
              offset: Offset(0, (selected ? 10 : 4) * k),
              blurRadius: (selected ? 14 : 2) * k,
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: selected ? _ink : Colors.white,
            width: (selected ? 7 : 3) * k,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(vibe.image, fit: BoxFit.cover)),
              Positioned(
                left: 57.8 * k,
                top: 44.6 * k,
                child: Text(
                  _label(vibe),
                  style: GoogleFonts.nunito(
                    fontSize: 42.76 * k,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: vibe.labelColor,
                  ),
                ),
              ),
              Positioned(
                left: 59.2 * k,
                top: 383 * k,
                child: Text(
                  _description(vibe),
                  style: GoogleFonts.nunito(
                    fontSize: 24.92 * k,
                    fontWeight: FontWeight.w300,
                    height: 1.33,
                    color: vibe.descriptionColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
