import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// A service class for sharing various types of content using the share_plus package
class ShareService {
  /// Shares a simple text message
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject,
    );
  }

  /// Shares a URL with an optional subject
  Future<void> shareUrl(String url, {String? subject, String? message}) async {
    final String textToShare = message != null ? '$message\n$url' : url;
    await Share.share(
      textToShare,
      subject: subject,
    );
  }

  /// Shares a single file with optional subject
  Future<void> shareFile(
    File file, {
    String? subject,
    String? text,
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: text,
      sharePositionOrigin:
          _getSharePositionOrigin(context, sharePositionOrigin),
    );

    _handleShareResult(result);
  }

  /// Shares multiple files with optional subject and text
  Future<void> shareFiles(
    List<File> files, {
    String? subject,
    String? text,
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    final xFiles = files.map((file) => XFile(file.path)).toList();

    final result = await Share.shareXFiles(
      xFiles,
      subject: subject,
      text: text,
      sharePositionOrigin:
          _getSharePositionOrigin(context, sharePositionOrigin),
    );

    _handleShareResult(result);
  }

  /// Shares an image from bytes with an optional subject
  Future<void> shareImageFromBytes(
    Uint8List bytes, {
    String filename = 'image.png',
    String? subject,
    String? text,
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    final extension = path.extension(filename).isNotEmpty ? '' : '.png';
    final uniqueFilename =
        '${path.basenameWithoutExtension(filename)}_$uuid$extension';
    final file = File('${tempDir.path}/$uniqueFilename');

    await file.writeAsBytes(bytes);

    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: text,
      sharePositionOrigin:
          _getSharePositionOrigin(context, sharePositionOrigin),
    );

    _handleShareResult(result);
  }

  /// Shares a file from a network URL by downloading it first
  Future<void> shareFileFromUrl(
    String url, {
    required String filename,
    String? subject,
    String? text,
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Download the file
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      final bytes = await _consolidateResponse(response);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');

      await file.writeAsBytes(bytes);

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
        text: text,
        sharePositionOrigin:
            _getSharePositionOrigin(context, sharePositionOrigin),
      );

      _handleShareResult(result);
    } catch (e) {
      print('Error sharing file from URL: $e');
      rethrow;
    }
  }

  /// Shares multiple images from bytes
  Future<void> shareMultipleImagesFromBytes(
    List<Uint8List> imageBytesList, {
    List<String>? filenames,
    String? subject,
    String? text,
    BuildContext? context,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      final xFiles = <XFile>[];

      for (var i = 0; i < imageBytesList.length; i++) {
        final bytes = imageBytesList[i];
        final filename = filenames != null && i < filenames.length
            ? filenames[i]
            : 'image_${i}_$uuid.png';

        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(bytes);
        xFiles.add(XFile(file.path));
      }

      final result = await Share.shareXFiles(
        xFiles,
        subject: subject,
        text: text,
        sharePositionOrigin:
            _getSharePositionOrigin(context, sharePositionOrigin),
      );

      _handleShareResult(result);
    } catch (e) {
      print('Error sharing multiple images: $e');
      rethrow;
    }
  }

  /// Helper method to handle share result
  void _handleShareResult(ShareResult result) {
    switch (result.status) {
      case ShareResultStatus.success:
        print('Share completed successfully');
        break;
      case ShareResultStatus.dismissed:
        print('Share was dismissed');
        break;
      case ShareResultStatus.unavailable:
        print('Sharing not available on this device');
        break;
    }
  }

  /// Helper method to get share position origin
  Rect? _getSharePositionOrigin(BuildContext? context, Rect? providedRect) {
    if (providedRect != null) return providedRect;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        return box.localToGlobal(Offset.zero) & box.size;
      }
    }
    return null;
  }

  /// Helper method to consolidate HttpClientResponse into bytes
  Future<Uint8List> _consolidateResponse(HttpClientResponse response) async {
    final List<List<int>> chunks = await response.toList();
    final int contentLength =
        chunks.fold<int>(0, (total, chunk) => total + chunk.length);
    final Uint8List result = Uint8List(contentLength);

    int offset = 0;
    for (List<int> chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    return result;
  }

  static Future<void> shareApp(BuildContext context) async {
    try {
      await Share.share(
        '查看这个令人惊叹的应用！',
        subject: '分享应用',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败: $e')),
      );
    }
  }
}
