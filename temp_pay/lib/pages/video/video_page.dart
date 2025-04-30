import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:temp_pay/pages/video/models/video_models.dart';
import 'package:temp_pay/pages/video/similar_video_page.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<VideoFile> _allVideos = [];
  List<VideoFile> _similarVideos = [];
  List<VideoFile> _largeVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    // Request permission
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (!state.hasAccess) {
      return;
    }

    // Get all video assets
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      filterOption: FilterOptionGroup(
        videoOption: const FilterOption(
          durationConstraint: DurationConstraint(min: Duration.zero),
        ),
      ),
    );

    if (albums.isEmpty) return;

    final List<AssetEntity> assets = await albums.first.getAssetListRange(
      start: 0,
      end: await albums.first.assetCountAsync,
    );

    setState(() {
      _allVideos =
          assets.map((asset) {
            final date = asset.createDateTime;
            return VideoFile(
              asset: asset,
              title: '视频 ${date.year}-${date.month}-${date.day}',
              subtitle: '${date.hour}:${date.minute}',
            );
          }).toList();

      // For demo purposes, we'll consider videos with similar titles as similar videos
      _similarVideos =
          _allVideos
              .where(
                (video) =>
                    video.title.contains('视频') && video.title.contains('2024'),
              )
              .toList();

      _isLoading = false;
    });

    // Load large videos asynchronously
    final largeVideos = <VideoFile>[];
    for (final video in _allVideos) {
      final size = await video.asset.size;
      if (size.width * size.height > 10 * 1024 * 1024) {
        largeVideos.add(video);
      }
    }

    setState(() {
      _largeVideos = largeVideos;
    });
  }

  void _navigateToSimilarVideos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimilarVideoPage(videos: _similarVideos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '视频',
          style: TextStyle(
            color: Color(0xFF2E3033),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  _buildVideoItem(
                    context: context,
                    icon: Icons.compare_rounded,
                    title: '全部视频',
                    subtitle: '${_allVideos.length} 视频',
                    size: '0.00M', // We can calculate total size if needed
                    onTap: () {},
                    iconColor: const Color(0xFF5C6EFF),
                    bgColor: const Color(0xFFEEF0FF),
                  ),
                  const SizedBox(height: 16),
                  _buildVideoItem(
                    context: context,
                    icon: Icons.compare_rounded,
                    title: '相似视频',
                    subtitle: '${_similarVideos.length} 相似视频',
                    size: '18.3M', // We can calculate total size if needed
                    onTap: () => _navigateToSimilarVideos(context),
                    iconColor: const Color(0xFF5C6EFF),
                    bgColor: const Color(0xFFEEF0FF),
                  ),
                  const SizedBox(height: 16),
                  _buildVideoItem(
                    context: context,
                    icon: Icons.video_library_rounded,
                    title: '大视频',
                    subtitle: '${_largeVideos.length} 大视频',
                    size: '0.00M', // We can calculate total size if needed
                    onTap: () {},
                    iconColor: const Color(0xFF6C5CFF),
                    bgColor: const Color(0xFFF0EEFF),
                  ),
                ],
              ),
    );
  }

  Widget _buildVideoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String size,
    required VoidCallback onTap,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3033),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8F959E),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [iconColor.withOpacity(0.9), iconColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        size,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
