import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/heart_mascot.dart';

class MascotInteraction {
  final String emotion;
  final String comment;

  const MascotInteraction({required this.emotion, required this.comment});
}

const List<MascotInteraction> kDefaultMascotInteractions = [
  MascotInteraction(
    emotion: 'happy',
    comment: 'Hôm nay tụi mình đi đâu chơi nhỉ? 🤔',
  ),
  MascotInteraction(
    emotion: 'love',
    comment: 'Yêu cậu nhiều lắm á! ♥',
  ),
  MascotInteraction(
    emotion: 'excited',
    comment: 'Lên lịch hẹn hò thôi! Tớ đã sẵn sàng! 🚀',
  ),
  MascotInteraction(
    emotion: 'celebrating',
    comment: 'Cùng tạo nên thật nhiều kỉ niệm nhé! 🥳',
  ),
  MascotInteraction(
    emotion: 'thinking',
    comment: 'Hai cậu trông thật là đẹp đôi luôn á! 💑',
  ),
  MascotInteraction(
    emotion: 'happy',
    comment: 'Chạm vào tớ tiếp đi, tớ thích lắm! 🥰',
  ),
];

class LandingMascotSection extends StatelessWidget {
  final String emotion;
  final String comment;
  final bool showComment;
  final VoidCallback onTap;

  const LandingMascotSection({
    super.key,
    required this.emotion,
    required this.comment,
    required this.showComment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HeartMascot(
              emotion: emotion,
              comment: comment,
              showComment: showComment,
            ),
            const SizedBox(height: 10),
            Text(
              'Chạm vào tớ nhé! 💖',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF653851).withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
