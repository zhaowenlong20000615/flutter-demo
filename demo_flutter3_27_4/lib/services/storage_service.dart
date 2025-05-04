import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService with ChangeNotifier {
  double _totalSpace = 0;
  double _usedSpace = 0;
  double _availableSpace = 0;
  List<FileSystemEntity> _junkFiles = [];
  Map<String, double> _categoryStorage = {};

  double get totalSpace => _totalSpace;
  double get usedSpace => _usedSpace;
  double get availableSpace => _availableSpace;
  List<FileSystemEntity> get junkFiles => _junkFiles;
  Map<String, double> get categoryStorage => _categoryStorage;

  Future<void> analyzeStorage() async {
    if (await Permission.storage.request().isGranted) {
      try {
        final List<Directory> storageDirectories =
            await getExternalStorageDirectories() ?? [];
        double total = 0;
        double used = 0;
        double available = 0;

        for (var dir in storageDirectories) {
          final stat = await dir.parent.parent.parent.parent.stat();
          final dirSize = await _calculateDirectorySize(dir);
          total += dirSize;
          used += dirSize;
          available = total - used;
        }

        _totalSpace = total / (1024 * 1024 * 1024); // Convert to GB
        _usedSpace = used / (1024 * 1024 * 1024);
        _availableSpace = available / (1024 * 1024 * 1024);

        // 分析不同类型文件占用的空间
        await _analyzeCategoryStorage(storageDirectories);

        // 扫描垃圾文件
        await _scanJunkFiles(storageDirectories);

        notifyListeners();
      } catch (e) {
        debugPrint('Error analyzing storage: $e');
      }
    }
  }

  Future<double> _calculateDirectorySize(Directory directory) async {
    try {
      double totalSize = 0;
      final List<FileSystemEntity> entities =
          await directory.list(recursive: true).toList();

      for (var entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
      return 0;
    }
  }

  Future<void> _analyzeCategoryStorage(List<Directory> directories) async {
    Map<String, double> categories = {
      'images': 0,
      'videos': 0,
      'audio': 0,
      'documents': 0,
      'archives': 0,
      'others': 0,
    };

    for (var dir in directories) {
      try {
        final List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();

        for (var entity in entities) {
          if (entity is File) {
            final String extension = entity.path.split('.').last.toLowerCase();
            final double size = await entity.length() / (1024 * 1024); // MB

            switch (extension) {
              case 'jpg':
              case 'jpeg':
              case 'png':
              case 'gif':
                categories['images'] = (categories['images'] ?? 0) + size;
                break;
              case 'mp4':
              case 'avi':
              case 'mov':
                categories['videos'] = (categories['videos'] ?? 0) + size;
                break;
              case 'mp3':
              case 'wav':
              case 'aac':
                categories['audio'] = (categories['audio'] ?? 0) + size;
                break;
              case 'pdf':
              case 'doc':
              case 'docx':
              case 'txt':
                categories['documents'] = (categories['documents'] ?? 0) + size;
                break;
              case 'zip':
              case 'rar':
              case '7z':
                categories['archives'] = (categories['archives'] ?? 0) + size;
                break;
              default:
                categories['others'] = (categories['others'] ?? 0) + size;
            }
          }
        }
      } catch (e) {
        debugPrint('Error analyzing category storage: $e');
      }
    }

    _categoryStorage = categories;
  }

  Future<void> _scanJunkFiles(List<Directory> directories) async {
    List<FileSystemEntity> junkFiles = [];

    for (var dir in directories) {
      try {
        final List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();

        junkFiles.addAll(entities.where((entity) {
          if (entity is File) {
            final path = entity.path.toLowerCase();
            final filename = path.split('/').last;

            // 检查文件扩展名
            final bool isJunkExtension = path.endsWith('.tmp') ||
                path.endsWith('.log') ||
                path.endsWith('.cache');

            // 检查临时文件
            final bool isTempFile = filename.startsWith('temp') ||
                filename.startsWith('tmp') ||
                filename.contains('cache');

            // 检查缓存目录
            final bool isInCacheDir = path.contains('/cache/') ||
                path.contains('/temp/') ||
                path.contains('/tmp/');

            // 检查空文件
            final bool isEmpty = entity.statSync().size == 0;

            return isJunkExtension || isTempFile || isInCacheDir || isEmpty;
          }
          return false;
        }));
      } catch (e) {
        debugPrint('Error scanning junk files: $e');
      }
    }

    _junkFiles = junkFiles;
  }

  Future<void> cleanJunkFiles() async {
    for (final file in _junkFiles) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting file ${file.path}: $e');
      }
    }
    _junkFiles.clear();
    await analyzeStorage();
  }

  Future<void> cleanByCategory(String category) async {
    if (!_categoryStorage.containsKey(category)) return;

    final List<Directory> directories =
        await getExternalStorageDirectories() ?? [];
    for (var dir in directories) {
      try {
        final List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();
        for (var entity in entities) {
          if (entity is File) {
            final String extension = entity.path.split('.').last.toLowerCase();
            bool shouldDelete = false;

            switch (category) {
              case 'images':
                shouldDelete =
                    ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
                break;
              case 'videos':
                shouldDelete = ['mp4', 'avi', 'mov'].contains(extension);
                break;
              case 'audio':
                shouldDelete = ['mp3', 'wav', 'aac'].contains(extension);
                break;
              case 'documents':
                shouldDelete =
                    ['pdf', 'doc', 'docx', 'txt'].contains(extension);
                break;
              case 'archives':
                shouldDelete = ['zip', 'rar', '7z'].contains(extension);
                break;
            }

            if (shouldDelete) {
              try {
                await entity.delete();
              } catch (e) {
                debugPrint('Error deleting file ${entity.path}: $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error cleaning category: $e');
      }
    }

    await analyzeStorage();
  }
}
