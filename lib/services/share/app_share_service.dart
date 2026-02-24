import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShareRequest {
  const AppShareRequest({
    this.text,
    this.subject,
    this.title,
    this.uri,
    this.files,
    this.fileNameOverrides,
  });

  final String? text;
  final String? subject;
  final String? title;
  final Uri? uri;
  final List<XFile>? files;
  final List<String>? fileNameOverrides;
}

class AppShareService {
  static Future<ShareResult> share({
    required AppShareRequest request,
    BuildContext? context,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        text: request.text,
        subject: request.subject,
        title: request.title,
        uri: request.uri,
        files: request.files,
        fileNameOverrides: request.fileNameOverrides,
        sharePositionOrigin: _sharePositionOrigin(context),
      ),
    );
  }

  static Future<ShareResult> shareText({
    required String text,
    String? subject,
    String? title,
    BuildContext? context,
  }) {
    return share(
      request: AppShareRequest(
        text: text,
        subject: subject,
        title: title,
      ),
      context: context,
    );
  }

  static Rect? _sharePositionOrigin(BuildContext? context) {
    if (context == null) return null;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
