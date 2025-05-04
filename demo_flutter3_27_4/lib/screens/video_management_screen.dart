import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // Find similar videos (based on name patterns and creation times)
  List<File> _findSimilarVideos(List<File> videos) {
    final Map<String, List<File>> similarGroups = {};

    // Group by name pattern (without extension and sequence numbers)
    for (final file in videos) {
      final fileName = path.basenameWithoutExtension(file.path);
      // Remove sequence numbers from filename (like VID_001, VID_002)
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

  // Find screen recordings
  List<File> _findScreenRecordings(List<File> videos) {
    return videos.where((file) {
      final lowerPath = file.path.toLowerCase();
      return lowerPath.contains('screen_recording') ||
          lowerPath.contains('screen_record') ||
          lowerPath.contains('录屏') ||
          lowerPath.contains('屏幕录制');
    }).toList();
  }

  // Find large videos (> 100MB)
  List<File> _findLargeVideos(List<File> videos) {
    const int largeThreshold = 100 * 1024 * 1024; // 100MB
    return videos.where((file) => file.lengthSync() > largeThreshold).toList();
  }

  // Find short videos (< 10 seconds, approximated by file size)
  List<File> _findShortVideos(List<File> videos) {
    if (videos.isEmpty) return [];

    // Calculate average size per second (very rough approximation)
    // Assuming about 1MB per 2 seconds for typical mobile video at medium quality
    const int bytesPerSecond = 500 * 1024; // ~500KB per second
    const int shortThreshold = 10 * bytesPerSecond; // 10 seconds threshold

    return videos.where((file) {
      final size = file.lengthSync();
      return size < shortThreshold;
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
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
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$count 个文件，共 $size',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      height: 1,
      thickness: 1,
      indent: 76,
      endIndent: 0,
    );
  }
}
