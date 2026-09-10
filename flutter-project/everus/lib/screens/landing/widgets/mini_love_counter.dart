import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/app_avatar.dart';

class MiniLoveCounter extends StatelessWidget {
  final int loveDays;
  final String userName;
  final String loverName;
  final bool isConfigured;
  final bool userImageExists;
  final bool loverImageExists;
  final String? userImagePath;
  final String? loverImagePath;
  final VoidCallback onTap;

  const MiniLoveCounter({
    super.key,
    required this.loveDays,
    required this.userName,
    required this.loverName,
    required this.isConfigured,
    required this.userImageExists,
    required this.loverImageExists,
    required this.userImagePath,
    required this.loverImagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D5A384C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHÚNG MÌNH ĐÃ BÊN NHAU',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF653851),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$loveDays',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF5A384C),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ngày',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5A384C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userName ♥ $loverName',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7C6E79),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DoubleAvatar(
                    isConfigured: isConfigured,
                    userName: userName,
                    loverName: loverName,
                    userImageExists: userImageExists,
                    loverImageExists: loverImageExists,
                    userImagePath: userImagePath,
                    loverImagePath: loverImagePath,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoubleAvatar extends StatelessWidget {
  final bool isConfigured;
  final String userName;
  final String loverName;
  final bool userImageExists;
  final bool loverImageExists;
  final String? userImagePath;
  final String? loverImagePath;
  final double size;

  const _DoubleAvatar({
    required this.isConfigured,
    required this.userName,
    required this.loverName,
    required this.userImageExists,
    required this.loverImageExists,
    required this.userImagePath,
    required this.loverImagePath,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isConfigured) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFF5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A384C).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.favorite,
          color: Color(0xFF653851),
          size: 24,
        ),
      );
    }

    if (userImageExists && loverImageExists) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AvatarCircle(
            name: loverName.isNotEmpty ? loverName : 'Em',
            imagePath: loverImagePath,
            exists: loverImageExists,
            size: size,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.favorite,
              color: Color(0xFF653851),
              size: 22,
            ),
          ),
          _AvatarCircle(
            name: userName.isNotEmpty ? userName : 'Bạn',
            imagePath: userImagePath,
            exists: userImageExists,
            size: size,
          ),
        ],
      );
    }

    final uInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'B';
    final lInitial = loverName.isNotEmpty ? loverName[0].toUpperCase() : 'N';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFF7EFF5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              lInitial,
              style: GoogleFonts.inter(
                fontSize: size * 0.375,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF653851),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.favorite,
            color: Color(0xFF653851),
            size: 22,
          ),
        ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4EB),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              uInitial,
              style: GoogleFonts.inter(
                fontSize: size * 0.375,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A384C),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String name;
  final String? imagePath;
  final bool exists;
  final double size;

  const _AvatarCircle({
    required this.name,
    required this.imagePath,
    required this.exists,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppAvatar(
        imagePath: exists ? imagePath : null,
        radius: size / 2,
        fallback: Container(
          color: const Color(0xFFF7EFF5),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '♥',
              style: GoogleFonts.inter(
                fontSize: size * 0.375,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF653851),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
