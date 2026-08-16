import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunicationDraftCard extends StatelessWidget {
  final TextEditingController draftController;
  final bool isEditingDraft;
  final bool copied;
  final bool sharedWithPartner;
  final VoidCallback onToggleEdit;
  final VoidCallback onCopy;
  final VoidCallback onSharePartner;
  final VoidCallback onSaveAndFinish;

  const CommunicationDraftCard({
    super.key,
    required this.draftController,
    required this.isEditingDraft,
    required this.copied,
    required this.sharedWithPartner,
    required this.onToggleEdit,
    required this.onCopy,
    required this.onSharePartner,
    required this.onSaveAndFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFBCFE8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFEC4899),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'EverUs gợi ý thông điệp chân thành',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBE185D),
                  ),
                ),
              ),
              // Compact Tool Actions: Edit & Copy
              InkWell(
                onTap: onToggleEdit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEditingDraft ? Icons.check_rounded : Icons.edit_outlined,
                        size: 14,
                        color: const Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEditingDraft ? 'Xong' : 'Sửa',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        copied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 14,
                        color: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        copied ? 'Đã chép' : 'Copy',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Message Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFCE7F3),
                width: 1.2,
              ),
            ),
            child: isEditingDraft
                ? TextField(
                    controller: draftController,
                    maxLines: 5,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF1F2937),
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )
                : Text(
                    '"${draftController.text}"',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF374151),
                      height: 1.55,
                    ),
                  ),
          ),

          const SizedBox(height: 18),

          // Streamlined Primary Action Bar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSharePartner,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEC4899),
                    side: const BorderSide(color: Color(0xFFFBCFE8), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  icon: Icon(
                    sharedWithPartner ? Icons.check_circle_rounded : Icons.send_rounded,
                    size: 16,
                  ),
                  label: Text(
                    sharedWithPartner ? 'Đã chia sẻ' : 'Gửi cho người ấy',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSaveAndFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    'Hoàn thành',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
