import 'dart:convert';
import 'package:flutter/material.dart';
import 'app_avatar_web.dart' if (dart.library.io) 'app_avatar_io.dart';

class AppAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final Widget fallback;

  const AppAvatar({
    super.key,
    required this.imagePath,
    required this.radius,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty) {
      return fallback;
    }

    if (path.startsWith('data:image')) {
      try {
        final commaIndex = path.indexOf(',');
        if (commaIndex != -1) {
          final base64Data = path.substring(commaIndex + 1);
          final bytes = base64Decode(base64Data);
          return CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(bytes),
          );
        }
      } catch (e) {
        debugPrint('Error decoding base64 avatar: $e');
        return fallback;
      }
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(path),
      );
    }

    // Native file path or platform image
    return renderPlatformAvatar(path, radius, fallback);
  }
}
