import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_editor/image_editor.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class FileEditorService with ChangeNotifier {
  final _uuid = const Uuid();
  bool _isLoading = false;
  String? _lastSavedPath;
  double _compressionProgress = 0.0;
  VideoQuality _videoQuality = VideoQuality.MediumQuality;
  Subscription? _subscription;

  bool get isLoading => _isLoading;
  String? get lastSavedPath => _lastSavedPath;
  double get compressionProgress => _compressionProgress;
  VideoQuality get videoQuality => _videoQuality;

  Future<File?> cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: '裁剪图片',
          ),
        ],
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  Future<String?> compressImage(File imageFile, {int quality = 70}) async {
    _setLoading(true);
    _compressionProgress = 0.0;
    notifyListeners();

    try {
      final String fileName = path.basename(imageFile.path);
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(tempDir.path, 'compressed_$fileName');

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: quality,
        keepExif: false,
      );

      if (result != null) {
        _lastSavedPath = result.path;
        _compressionProgress = 1.0;
        notifyListeners();
        return result.path;
      }
    } catch (e) {
      debugPrint('压缩图片错误: $e');
    } finally {
      _setLoading(false);
    }

    return null;
  }

  Future<String?> rotateImage(File imageFile, int degrees) async {
    _setLoading(true);
    notifyListeners();

    try {
      // 读取图片数据
      List<int> imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage =
          img.decodeImage(Uint8List.fromList(imageBytes));

      if (originalImage == null) {
        return null;
      }

      // 旋转图片
      img.Image rotatedImage;
      if (degrees == 90) {
        rotatedImage = img.copyRotate(originalImage, angle: 90);
      } else if (degrees == 180) {
        rotatedImage = img.copyRotate(originalImage, angle: 180);
      } else if (degrees == 270 || degrees == -90) {
        rotatedImage = img.copyRotate(originalImage, angle: 270);
      } else {
        rotatedImage = originalImage;
      }

      // 保存旋转后的图片
      final String fileName = path.basename(imageFile.path);
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(tempDir.path, 'rotated_$fileName');

      File targetFile = File(targetPath);

      // 根据原始文件格式确定编码类型
      List<int> encodedImage;
      if (fileName.toLowerCase().endsWith('.png')) {
        encodedImage = img.encodePng(rotatedImage);
      } else {
        encodedImage = img.encodeJpg(rotatedImage, quality: 90);
      }

      await targetFile.writeAsBytes(encodedImage);

      _lastSavedPath = targetPath;
      return targetPath;
    } catch (e) {
      debugPrint('旋转图片错误: $e');
    } finally {
      _setLoading(false);
    }

    return null;
  }

  Future<String?> compressVideo(File videoFile, {VideoQuality? quality}) async {
    _setLoading(true);
    _compressionProgress = 0.0;
    notifyListeners();

    try {
      // Subscribe to compression progress updates
      _subscription = VideoCompress.compressProgress$.subscribe((progress) {
        _compressionProgress = progress / 100;
        notifyListeners();
      });

      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: quality ?? _videoQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo?.file != null) {
        _lastSavedPath = mediaInfo!.file!.path;
        _compressionProgress = 1.0;
        notifyListeners();
        return mediaInfo.file!.path;
      }
    } catch (e) {
      debugPrint('压缩视频错误: $e');
    } finally {
      _subscription?.unsubscribe();
      _subscription = null;
      _setLoading(false);
    }

    return null;
  }

  Future<File?> trimVideo(File videoFile,
      {required double start, required double end}) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        startTime: start.toInt(),
        deleteOrigin: false,
        includeAudio: true,
      );

      return mediaInfo?.file;
    } catch (e) {
      debugPrint('Error trimming video: $e');
      return null;
    }
  }

  void resetProgress() {
    _compressionProgress = 0.0;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setVideoQuality(VideoQuality quality) {
    _videoQuality = quality;
    notifyListeners();
  }

  // 保存编辑后的图片到相册
  Future<String?> saveProcessedImageToGallery(String imagePath) async {
    try {
      final File processedFile = File(imagePath);

      // 获取保存目录
      final Directory galleryDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(imagePath);
      final String targetPath = path.join(galleryDir.path, 'edited_$fileName');

      // 复制到相册目录
      await processedFile.copy(targetPath);

      return targetPath;
    } catch (e) {
      debugPrint('保存处理后图片错误: $e');
      return null;
    }
  }

  // 保存编辑后的视频到相册
  Future<String?> saveProcessedVideoToGallery(String videoPath) async {
    try {
      final File processedFile = File(videoPath);

      // 获取保存目录
      final Directory galleryDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(videoPath);
      final String targetPath = path.join(galleryDir.path, 'edited_$fileName');

      // 复制到相册目录
      await processedFile.copy(targetPath);

      return targetPath;
    } catch (e) {
      debugPrint('保存处理后视频错误: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _subscription = null;
    super.dispose();
  }
}
