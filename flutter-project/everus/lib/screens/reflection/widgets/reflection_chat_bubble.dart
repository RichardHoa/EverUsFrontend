import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/reflection_models.dart';

class ReflectionChatBubble extends StatelessWidget {
  final ReflectionChatMessage message;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback? onNavigateToSummary;

  const ReflectionChatBubble({
    super.key,
    required this.message,
    required this.onOptionSelected,
    this.onNavigateToSummary,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.user:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 48),
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(6),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ),
        );

      case MessageType.memoryRecall:
        return Container(
          margin: const EdgeInsets.only(bottom: 20, right: 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD8B4FE),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history_edu_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EverUs nhớ...',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
              if (message.quickOptions.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildQuickOptions(
                  selectedColor: const Color(0xFF8B5CF6),
                  borderColor: const Color(0xFFD8B4FE),
                  textColor: const Color(0xFF6B21A8),
                ),
              ],
            ],
          ),
        );

      case MessageType.perspectiveReframing:
        return Container(
          margin: const EdgeInsets.only(bottom: 20, right: 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFED7AA),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Color(0xFFEA580C),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nhìn từ một góc khác',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC2410C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
              if (message.quickOptions.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildQuickOptions(
                  selectedColor: const Color(0xFFEA580C),
                  borderColor: const Color(0xFFFDBA74),
                  textColor: const Color(0xFF9A3412),
                ),
              ],
            ],
          ),
        );

      case MessageType.summaryReady:
        return Container(
          margin: const EdgeInsets.only(bottom: 20, right: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF3E8FF),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNavigateToSummary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    'I think I understand now — Xem tổng kết',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case MessageType.ai:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12, right: 48),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: const Color(0xFFF3E8FF),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                  height: 1.5,
                ),
              ),
            ),
            if (message.quickOptions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16, right: 32),
                child: _buildQuickOptions(
                  selectedColor: const Color(0xFF8B5CF6),
                  borderColor: const Color(0xFFDDD6FE),
                  textColor: const Color(0xFF6B21A8),
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildQuickOptions({
    required Color selectedColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.quickOptions.map((opt) {
        final isSelected = message.selectedOption == opt;
        return InkWell(
          onTap: () => onOptionSelected(opt),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? selectedColor : borderColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedColor.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              opt,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
