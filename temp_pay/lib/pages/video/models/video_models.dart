import 'package:photo_manager/photo_manager.dart';

class VideoItem {
  final String title;
  final String subtitle;
  final String size;
  final int count;
  final List<VideoFile> files;

  VideoItem({
    required this.title,
    required this.subtitle,
    required this.size,
    required this.count,
    required this.files,
  });
}

class VideoFile {
  final AssetEntity asset;
  final String title;
  final String subtitle;
  final bool isSelected;

  VideoFile({
    required this.asset,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
  });

  String get thumbnail => asset.thumbnailData != null ? 'thumbnail' : '';

  String get path => asset.relativePath ?? '';

  Future<String> getSize() async {
    final size = await asset.size;
    return '${(size.width * size.height / (1024 * 1024)).toStringAsFixed(2)}M';
  }
}
