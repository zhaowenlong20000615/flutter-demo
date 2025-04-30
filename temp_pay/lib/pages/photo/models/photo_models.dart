import 'package:photo_manager/photo_manager.dart';

class PhotoItem {
  final String date;
  final List<ImageItem> images;

  PhotoItem({
    required this.date,
    required this.images,
  });
}

class ImageItem {
  final AssetEntity asset;
  final bool isSelected;

  ImageItem({
    required this.asset,
    this.isSelected = false,
  });
} 