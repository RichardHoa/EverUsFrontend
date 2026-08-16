import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopicInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isWriting;
  final ValueChanged<String> onChanged;
  final VoidCallback onStart;

  const CustomTopicInput({
    super.key,
    required this.controller,
    required this.isWriting,
    required this.onChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWriting ? const Color(0xFF8B5CF6) : const Color(0xFFF3E8FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 4,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF1F2937),
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText:
                  'Viết vài dòng về cảm giác của bạn, những gì xảy ra hôm nay...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isWriting ? onStart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                'Bắt đầu',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
