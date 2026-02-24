import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MediaStorage {
  static const String _mealPhotoDirName = 'meal_photos';
  static String? _mealPhotoDirectoryPath;

  static Future<void> initialize() async {
    final directory = await _ensureMealPhotosDirectory();
    _mealPhotoDirectoryPath = directory.path;
  }

  static Future<String?> persistMealPhoto(String sourcePath) async {
    final String? normalizedSourcePath = normalizeMealPhotoPath(sourcePath);
    if (normalizedSourcePath == null) return null;

    final Directory targetDir = await _ensureMealPhotosDirectory();

    if (_isPathInsideDirectory(
      filePath: normalizedSourcePath,
      directoryPath: targetDir.path,
    )) {
      final file = File(normalizedSourcePath);
      if (await file.exists()) {
        return _identifierFromAbsolutePath(
          absolutePath: file.path,
          directoryPath: targetDir.path,
        );
      }
    }

    final String extension = _safeExtension(normalizedSourcePath);
    final String targetPath = _buildUniqueTargetPath(targetDir.path, extension);

    final sourceFile = File(normalizedSourcePath);
    if (await sourceFile.exists()) {
      final File copied = await sourceFile.copy(targetPath);
      if (await copied.exists()) {
        return _identifierFromAbsolutePath(
          absolutePath: copied.path,
          directoryPath: targetDir.path,
        );
      }
    }

    final Uint8List? bytes = await _tryReadBytesFromSourcePath(normalizedSourcePath) ?? await _tryReadBytesFromSourcePath(sourcePath);
    if (bytes == null || bytes.isEmpty) return null;
    final targetFile = File(targetPath);
    await targetFile.writeAsBytes(bytes, flush: true);
    if (!await targetFile.exists()) return null;
    return _identifierFromAbsolutePath(
      absolutePath: targetFile.path,
      directoryPath: targetDir.path,
    );
  }

  static Future<String?> persistMealPhotoFromUrl(String sourceUrl) async {
    if (sourceUrl.trim().isEmpty) return null;
    final Uri? uri = Uri.tryParse(sourceUrl.trim());
    if (uri == null || (!uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http'))) {
      return null;
    }

    final Directory targetDir = await _ensureMealPhotosDirectory();
    final String extension = _safeRemoteExtension(uri.path);
    final String targetPath = _buildUniqueTargetPath(targetDir.path, extension);

    HttpClient? client;
    try {
      client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final BytesBuilder bytesBuilder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        bytesBuilder.add(chunk);
      }
      final bytes = bytesBuilder.takeBytes();
      if (bytes.isEmpty) return null;

      final File targetFile = File(targetPath);
      await targetFile.writeAsBytes(bytes, flush: true);
      return _identifierFromAbsolutePath(
        absolutePath: targetFile.path,
        directoryPath: targetDir.path,
      );
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  static String _safeExtension(String path) {
    final String sanitizedPath = path.split('?').first.split('#').first;
    final int dotIndex = sanitizedPath.lastIndexOf('.');
    final int sepIndex = sanitizedPath.lastIndexOf(Platform.pathSeparator);
    if (dotIndex <= sepIndex) return '';
    final String ext = sanitizedPath.substring(dotIndex);
    if (ext.length > 8) return '';
    return ext;
  }

  static String _safeRemoteExtension(String remotePath) {
    final String ext = _safeExtension(remotePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.webp':
        return ext;
      default:
        return '.jpg';
    }
  }

  static Future<Directory> _ensureMealPhotosDirectory() async {
    final String? cachedPath = _mealPhotoDirectoryPath;
    final Directory targetDir;
    if (cachedPath != null && cachedPath.isNotEmpty) {
      targetDir = Directory(cachedPath);
    } else {
      final Directory docsDir = await getApplicationDocumentsDirectory();
      targetDir = Directory('${docsDir.path}/$_mealPhotoDirName');
    }
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    _mealPhotoDirectoryPath = targetDir.path;
    return targetDir;
  }

  static String? normalizeMealPhotoPath(String? rawPath) {
    if (rawPath == null) return null;
    final String trimmed = rawPath.trim();
    if (trimmed.isEmpty) return null;

    final Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && uri.scheme == 'file') {
      return uri.toFilePath();
    }

    return trimmed;
  }

  static Future<String?> resolveStoredMealPhotoPath(String? storedReference) async {
    final normalized = normalizeMealPhotoPath(storedReference);
    if (normalized == null) return null;

    if (_looksLikePhotoIdentifier(normalized)) {
      final Directory dir = await _ensureMealPhotosDirectory();
      return '${dir.path}/$normalized';
    }

    return normalized;
  }

  static String? resolveStoredMealPhotoPathSync(String? storedReference) {
    final normalized = normalizeMealPhotoPath(storedReference);
    if (normalized == null) return null;

    if (_looksLikePhotoIdentifier(normalized)) {
      final String? directoryPath = _mealPhotoDirectoryPath;
      if (directoryPath == null || directoryPath.isEmpty) return null;
      return '$directoryPath/$normalized';
    }

    return normalized;
  }

  static File? existingMealPhotoFile(String? storedReference) {
    final resolvedPath = resolveStoredMealPhotoPathSync(storedReference);
    if (resolvedPath == null) return null;
    final file = File(resolvedPath);
    if (!file.existsSync()) return null;
    return file;
  }

  static bool _isPathInsideDirectory({
    required String filePath,
    required String directoryPath,
  }) {
    final normalizedDirectory = directoryPath.endsWith(Platform.pathSeparator) ? directoryPath : '$directoryPath${Platform.pathSeparator}';
    return filePath == directoryPath || filePath.startsWith(normalizedDirectory);
  }

  static String _buildUniqueTargetPath(String directoryPath, String extension) {
    final String fileName = 'meal_${DateTime.now().microsecondsSinceEpoch}$extension';
    return '$directoryPath/$fileName';
  }

  static String _identifierFromAbsolutePath({
    required String absolutePath,
    required String directoryPath,
  }) {
    final normalizedDirectory = directoryPath.endsWith(Platform.pathSeparator) ? directoryPath : '$directoryPath${Platform.pathSeparator}';
    if (absolutePath.startsWith(normalizedDirectory)) {
      return absolutePath.substring(normalizedDirectory.length);
    }
    return absolutePath;
  }

  static bool _looksLikePhotoIdentifier(String value) {
    return !value.contains('/') &&
        !value.contains('\\') &&
        !value.contains('://') &&
        !value.startsWith('file:') &&
        !value.startsWith('content:');
  }

  static Future<Uint8List?> _tryReadBytesFromSourcePath(String sourcePath) async {
    try {
      final xFile = XFile(sourcePath);
      final bytes = await xFile.readAsBytes();
      if (bytes.isEmpty) return null;
      return bytes;
    } catch (_) {
      return null;
    }
  }
}
