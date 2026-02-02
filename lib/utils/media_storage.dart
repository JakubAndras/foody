import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MediaStorage {
  static Future<String?> persistMealPhoto(String sourcePath) async {
    if (sourcePath.isEmpty) return null;
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) return null;

    final Directory docsDir = await getApplicationDocumentsDirectory();
    final Directory targetDir = Directory('${docsDir.path}/meal_photos');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    if (sourcePath.startsWith(targetDir.path)) {
      return sourcePath;
    }

    final String extension = _safeExtension(sourcePath);
    final String fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}$extension';
    final String targetPath = '${targetDir.path}/$fileName';
    final File copied = await sourceFile.copy(targetPath);
    return copied.path;
  }

  static String _safeExtension(String path) {
    final int dotIndex = path.lastIndexOf('.');
    final int sepIndex = path.lastIndexOf(Platform.pathSeparator);
    if (dotIndex <= sepIndex) return '';
    final String ext = path.substring(dotIndex);
    if (ext.length > 8) return '';
    return ext;
  }
}
