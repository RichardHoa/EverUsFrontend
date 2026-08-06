import 'package:image_picker/image_picker.dart';
import 'file_helper_web.dart' if (dart.library.io) 'file_helper_io.dart';

class AppFileHelper {
  static Future<String?> savePickedImage(XFile pickedFile, String? oldPath) {
    return savePickedImageImpl(pickedFile, oldPath);
  }

  static Future<bool> fileExists(String path) {
    return fileExistsImpl(path);
  }
}
