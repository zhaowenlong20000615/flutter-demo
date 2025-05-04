import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _formatSize(List<File> files) {
    final int totalBytes =
        files.fold(0, (sum, file) => sum + file.lengthSync());

    if (totalBytes < 1024) {
      return '${totalBytes}B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(2)}KB';
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    } else {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
  }

  // Find similar photos (based on name patterns and creation times)
  List<File> _findSimilarPhotos(List<File> images) {
    final Map<String, List<File>> similarGroups = {};

    // Group by name pattern (without extension and sequence numbers)
    for (final file in images) {
      final fileName = path.basenameWithoutExtension(file.path);
      // Remove sequence numbers from filename (like IMG_001, IMG_002)
      final basePattern = fileName.replaceAll(RegExp(r'_?\d+$'), '');

      if (!similarGroups.containsKey(basePattern)) {
        similarGroups[basePattern] = [];
      }
      similarGroups[basePattern]!.add(file);
    }

    // Only keep groups with multiple files
    final List<File> result = [];
    similarGroups.forEach((key, files) {
      if (files.length > 1) {
        result.addAll(files);
      }
    });

    return result;
  }

  // Find screenshots
  List<File> _findScreenshots(List<File> images) {
    return images.where((file) {
      final lowerPath = file.path.toLowerCase();
      return lowerPath.contains('screenshot') ||
          lowerPath.contains('screen_shot') ||
          lowerPath.contains('截图');
    }).toList();
  }

  // Find burst photos (multiple photos taken within seconds)
  List<File> _findBurstPhotos(List<File> images) {
    // Sort by creation time
    final sorted = List<File>.from(images);
    sorted.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    final Map<String, List<File>> burstGroups = {};
    for (int i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];

      // If photos were taken within 2 seconds, they might be burst photos
      final timeDiff = next
          .lastModifiedSync()
          .difference(current.lastModifiedSync())
          .inSeconds;
      if (timeDiff <= 2) {
        final baseKey = path.dirname(current.path) +
            '_' +
            current.lastModifiedSync().day.toString();
        if (!burstGroups.containsKey(baseKey)) {
          burstGroups[baseKey] = [current];
        }
        burstGroups[baseKey]!.add(next);
      }
    }

    // Only keep groups with multiple files
    final List<File> result = [];
    burstGroups.forEach((key, files) {
      if (files.length > 1) {
        result.addAll(files);
      }
    });

    return result;
  }

  // Simple detection of potentially blurry photos (based on file size ratio)
  // Note: This is a simplistic approach; real blur detection requires image processing
  List<File> _findPotentiallyBlurryPhotos(List<File> images) {
    if (images.isEmpty) return [];

    // Calculate average file size
    final avgSize =
        images.fold(0, (sum, file) => sum + file.lengthSync()) / images.length;

    // Photos significantly smaller than average might be blurry or lower quality
    return images.where((file) {
      final size = file.lengthSync();
      return size <
          avgSize *
              0.6; // 60% smaller than average might indicate lower quality
    }).toList();
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

          // Estimate live photos (in a real app this would need deeper analysis)
          final livePhotos = allPhotos.where((file) {
            final path = file.path.toLowerCase();
            return path.contains('live') || path.contains('motion');
          }).toList();

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
                icon: Icons.photo_camera_outlined,
                title: '相似实况照片',
                count: livePhotos.length,
                size: _formatSize(livePhotos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoCleanupScreen(
                        title: '相似实况照片',
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFF0F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$count 张照片',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              size,
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 80,
    );
  }
}
