import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/display_language_helper.dart';

/// Compact `VI | EN` pill that switches the app's Display language.
class DisplayLanguageToggle extends StatelessWidget {
  const DisplayLanguageToggle({super.key});

  static const Color _ink = Color(0xFF5A384C);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: DisplayLanguageHelper.localeNotifier,
      builder: (context, locale, _) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _option('VI', DisplayLanguageHelper.vietnamese, locale),
              _option('EN', DisplayLanguageHelper.english, locale),
            ],
          ),
        );
      },
    );
  }

  Widget _option(String label, Locale value, Locale current) {
    final selected = value == current;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: selected ? null : () => DisplayLanguageHelper.setLocale(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? _ink : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : _ink,
            ),
          ),
        ),
      ),
    );
  }
}
