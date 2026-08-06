import 'dart:convert';
import 'package:image_picker/image_picker.dart';

Future<String?> savePickedImageImpl(XFile pickedFile, String? oldPath) async {
  final bytes = await pickedFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  final mimeType = pickedFile.mimeType ?? 'image/jpeg';
  return 'data:$mimeType;base64,$base64Image';
}

Future<bool> fileExistsImpl(String path) async {
  return path.startsWith('data:') || path.startsWith('http') || path.isNotEmpty;
}
