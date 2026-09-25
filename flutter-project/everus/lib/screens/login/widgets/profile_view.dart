import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatelessWidget {
  final String name;
  final String email;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onSignOut;

  /// Re-opens the questionnaire pre-filled with the user's answers.
  final VoidCallback? onEditAnswers;

  const ProfileView({
    super.key,
    required this.name,
    required this.email,
    this.errorMessage,
    required this.isLoading,
    required this.onSignOut,
    this.onEditAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: const Color(0xFFF3EBF3),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: GoogleFonts.comfortaa(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF653851),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.comfortaa(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5A384C),
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF7D6E7B),
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (errorMessage != null) ...[
          Text(
            errorMessage!,
            style: GoogleFonts.inter(color: Colors.red.shade700, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
        ],
        if (onEditAnswers != null) ...[
          OutlinedButton(
            onPressed: isLoading ? null : onEditAnswers,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF653851),
              side: const BorderSide(color: Color(0xFF653851)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Chỉnh sửa câu trả lời',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton(
          onPressed: isLoading ? null : onSignOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF653851),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Đăng xuất',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                ),
        ),
      ],
    );
  }
}
