import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/media_service.dart';
import 'video_cleanup_screen.dart';
import 'package:path/path.dart' as path;

class VideoManagementScreen extends StatefulWidget {
  @override
  _VideoManagementScreenState createState() => _VideoManagementScreenState();
}

class _VideoManagementScreenState extends State<VideoManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mediaService = Provider.of<MediaService>(context, listen: false);
    await mediaService.loadMediaFiles();
  }

  // Display count and type information
  String _formatSize(List<AssetEntity> assets) {
    return '${assets.length} 个视频';
  }

  // Find similar videos (based on name patterns and creation times)
  List<AssetEntity> _findSimilarVideos(List<AssetEntity> videos) {
    final Map<String, List<AssetEntity>> similarGroups = {};

    // Group by title pattern
    for (final asset in videos) {
      final title = asset.title ?? '';
      // Remove sequence numbers from title (like VID_001, VID_002)
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

  // Find screen recordings
  List<AssetEntity> _findScreenRecordings(List<AssetEntity> videos) {
    return videos.where((asset) {
      final title = asset.title?.toLowerCase() ?? '';
      return title.contains('screen_recording') ||
          title.contains('screen_record') ||
          title.contains('录屏') ||
          title.contains('屏幕录制');
    }).toList();
  }

  // Find large videos (estimate based on duration)
  List<AssetEntity> _findLargeVideos(List<AssetEntity> videos) {
    // We'll use duration as a proxy for size - videos longer than 3 minutes
    const int largeThresholdSeconds = 3 * 60; // 3 minutes in seconds

    return videos
        .where((asset) =>
            asset.duration != null && asset.duration! >= largeThresholdSeconds)
        .toList();
  }

  // Find short videos (< 10 seconds)
  List<AssetEntity> _findShortVideos(List<AssetEntity> videos) {
    const int shortThresholdSeconds = 10; // 10 seconds

    return videos
        .where((asset) =>
            asset.duration != null && asset.duration! < shortThresholdSeconds)
        .toList();
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
          '视频',
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
          final allVideos = mediaService.videos;
          final similarVideos = _findSimilarVideos(allVideos);
          final screenRecordings = _findScreenRecordings(allVideos);
          final largeVideos = _findLargeVideos(allVideos);
          final shortVideos = _findShortVideos(allVideos);

          return ListView(
            children: [
              _buildCategoryItem(
                icon: Icons.videocam_outlined,
                title: '所有视频',
                count: allVideos.length,
                size: _formatSize(allVideos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCleanupScreen(
                        title: '所有视频',
                        videos: allVideos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.copy_outlined,
                title: '相似视频',
                count: similarVideos.length,
                size: _formatSize(similarVideos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCleanupScreen(
                        title: '相似视频',
                        videos: similarVideos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.screen_share_outlined,
                title: '屏幕录制',
                count: screenRecordings.length,
                size: _formatSize(screenRecordings),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCleanupScreen(
                        title: '屏幕录制',
                        videos: screenRecordings,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.sd_storage_outlined,
                title: '大型视频',
                count: largeVideos.length,
                size: _formatSize(largeVideos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCleanupScreen(
                        title: '大型视频',
                        videos: largeVideos,
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildCategoryItem(
                icon: Icons.timelapse_outlined,
                title: '短视频',
                count: shortVideos.length,
                size: _formatSize(shortVideos),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCleanupScreen(
                        title: '短视频',
                        videos: shortVideos,
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
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 22,
        ),
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
