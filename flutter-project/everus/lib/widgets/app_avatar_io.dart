import 'dart:io';
import 'package:flutter/material.dart';

Widget renderPlatformAvatar(String path, double radius, Widget fallback) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(file),
      );
    }
  } catch (_) {}
  return fallback;
}
