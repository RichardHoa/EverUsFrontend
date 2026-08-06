import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> savePickedImageImpl(XFile pickedFile, String? oldPath) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final String originalPath = pickedFile.path;
    final String extension = originalPath.split('.').last;
    final String fileName = 'love_profile_${DateTime.now().microsecondsSinceEpoch}.$extension';
    final String newPath = '${appDir.path}/$fileName';

    if (oldPath != null && !oldPath.startsWith('data:')) {
      try {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (_) {}
    }

    final File savedImage = await File(originalPath).copy(newPath);
    return savedImage.path;
  } catch (e) {
    return null;
  }
}

Future<bool> fileExistsImpl(String path) async {
  if (path.startsWith('data:') || path.startsWith('http')) return true;
  try {
    return await File(path).exists();
  } catch (_) {
    return false;
  }
}
