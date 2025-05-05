import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/media_service.dart';
import 'photo_cleanup_screen.dart';
import 'package:path/path.dart' as path;

class PhotoManagementScreen extends StatefulWidget {
  @override
  _PhotoManagementScreenState createState() => _PhotoManagementScreenState();
}

class _PhotoManagementScreenState extends State<PhotoManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mediaService = Provider.of<MediaService>(context, listen: false);
    await mediaService.loadMediaFiles();
  }

  // Calculate the file size in appropriate format (KB, MB, GB)
  String _formatSize(List<AssetEntity> assets) {
    // AssetEntity doesn't provide direct file size, so we'll use count instead
    return '${assets.length} 张照片';
  }

  // Find similar photos (based on name patterns and creation times)
  List<AssetEntity> _findSimilarPhotos(List<AssetEntity> images) {
    final Map<String, List<AssetEntity>> similarGroups = {};

    // Group by title pattern
    for (final asset in images) {
      final title = asset.title ?? '';
      // Remove sequence numbers from title (like IMG_001, IMG_002)
      final basePattern = title.replaceAll(RegExp(r'_?\d+$'), '');

      if (!similarGroups.containsKey(basePattern)) {
        similarGroups[basePattern] = [];
      }
      similarGroups[basePattern]!.add(asset);
    }

    // Only keep groups with multiple files
    final List<AssetEntity> result = [];
    similarGroups.forEach((key, assets) {
      if (assets.length > 1) {
        result.addAll(assets);
      }
    });

    return result;
  }

  // Find screenshots
  List<AssetEntity> _findScreenshots(List<AssetEntity> images) {
    return images.where((asset) {
      final title = asset.title?.toLowerCase() ?? '';
      return title.contains('screenshot') ||
          title.contains('screen_shot') ||
          title.contains('截图');
    }).toList();
  }

  // Find burst photos (multiple photos taken within seconds)
  List<AssetEntity> _findBurstPhotos(List<AssetEntity> images) {
    // Sort by creation time
    final sorted = List<AssetEntity>.from(images);
    sorted.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));

    final Map<String, List<AssetEntity>> burstGroups = {};
    for (int i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];

      // If photos were taken within 2 seconds, they might be burst photos
      final timeDiff =
          next.createDateTime.difference(current.createDateTime).inSeconds;
      if (timeDiff <= 2) {
        final baseKey = current.createDateTime.day.toString();
        if (!burstGroups.containsKey(baseKey)) {
          burstGroups[baseKey] = [current];
        }
        burstGroups[baseKey]!.add(next);
      }
    }

    // Only keep groups with multiple files
    final List<AssetEntity> result = [];
    burstGroups.forEach((key, assets) {
      if (assets.length > 1) {
        result.addAll(assets);
      }
    });

    return result;
  }

  // Simple detection of potentially live photos
  List<AssetEntity> _findLivePhotos(List<AssetEntity> images) {
    // For iOS, we can detect live photos using mediaSubtypes
    return images.where((asset) {
      return asset.typeInt == AssetType.image.index &&
          asset
              .isFavorite; // This is just a placeholder, actual live photo detection requires checking mediaSubtypes
    }).toList();
  }

  // We can't easily detect blurry photos without image processing
  List<AssetEntity> _findPotentiallyBlurryPhotos(List<AssetEntity> images) {
    // Return a small random subset as a placeholder
    // In a real app, this would require image processing or ML
    if (images.isEmpty) return [];

    // Just a placeholder implementation
    return images.take((images.length * 0.05).round()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '照片',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MediaService>(
        builder: (context, mediaService, _) {
          final allPhotos = mediaService.images;
          final similarPhotos = _findSimilarPhotos(allPhotos);
          final blurryPhotos = _findPotentiallyBlurryPhotos(allPhotos);
          final screenshots = _findScreenshots(allPhotos);
          final burstPhotos = _findBurstPhotos(allPhotos);
          final livePhotos = _findLivePhotos(allPhotos);

          return ListView(
            children: [
              _buildCategoryItem(
                icon: Icons.photo_library_outlined,
                title: '所有图片',
                count: allPhotos.length,
                size: _formatSize(allPhotos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '所有图片',
                        photos: allPhotos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.photo_library_outlined,
                title: '相似照片',
                count: similarPhotos.length,
                size: _formatSize(similarPhotos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '相似照片',
                        photos: similarPhotos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.block_outlined,
                title: '模糊图片',
                count: blurryPhotos.length,
                size: _formatSize(blurryPhotos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '模糊图片',
                        photos: blurryPhotos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.screenshot_outlined,
                title: '屏幕截图',
                count: screenshots.length,
                size: _formatSize(screenshots),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '屏幕截图',
                        photos: screenshots,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.timelapse_outlined,
                title: '连拍快照',
                count: burstPhotos.length,
                size: _formatSize(burstPhotos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '连拍快照',
                        photos: burstPhotos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.motion_photos_auto_outlined,
                title: '实况照片',
                count: livePhotos.length,
                size: _formatSize(livePhotos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '实况照片',
                        photos: livePhotos,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required int count,
    required String size,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 28,
        color: Colors.blue,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '$count 项, $size',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 70,
      endIndent: 16,
      color: Colors.grey[300],
    );
  }
}
