import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/media_service.dart';

class VideoCleanupScreen extends StatefulWidget {
  final String title;
  final List<AssetEntity> videos;

  VideoCleanupScreen({
    required this.title,
    required this.videos,
  });

  @override
  _VideoCleanupScreenState createState() => _VideoCleanupScreenState();
}

class _VideoCleanupScreenState extends State<VideoCleanupScreen> {
  Set<AssetEntity> _selectedVideos = {};
  bool _isSelectMode = false;

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);
    final hasVideos = widget.videos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          if (hasVideos && _isSelectMode)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedVideos.length == widget.videos.length) {
                    _selectedVideos.clear();
                  } else {
                    _selectedVideos = Set.from(widget.videos);
                  }
                });
              },
              child: Text(
                _selectedVideos.length == widget.videos.length ? '全不选' : '全选',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (hasVideos && !_isSelectMode)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _isSelectMode = true;
                });
              },
            ),
        ],
      ),
      body: !hasVideos
          ? _buildEmptyState()
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.videos.length,
              itemBuilder: (context, index) {
                final video = widget.videos[index];
                final isSelected = _selectedVideos.contains(video);

                return GestureDetector(
                  onTap: () {
                    if (_isSelectMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedVideos.remove(video);
                        } else {
                          _selectedVideos.add(video);
                        }
                      });
                    } else {
                      // Open video player (implementation not included)
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectMode) {
                      setState(() {
                        _isSelectMode = true;
                        _selectedVideos.add(video);
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Video thumbnail
                            _buildVideoThumbnail(video),
                            // Play icon overlay
                            Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white.withOpacity(0.8),
                                size: 30,
                              ),
                            ),
                            // Video duration indicator
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _formatDuration(
                                      Duration(milliseconds: video.duration)),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isSelectMode)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.black.withOpacity(0.5),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: _isSelectMode && _selectedVideos.isNotEmpty
          ? SafeArea(
              child: Container(
                height: 64,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已选择 ${_selectedVideos.length} 项',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('确认删除'),
                            content:
                                Text('是否确认删除选中的 ${_selectedVideos.length} 项？'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('取消'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // Delete selected videos
                                  for (var video in _selectedVideos) {
                                    await mediaService.deleteMediaFile(video);
                                  }
                                  setState(() {
                                    _selectedVideos.clear();
                                    _isSelectMode = false;
                                  });
                                },
                                child: Text('确认'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        '删除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildVideoThumbnail(AssetEntity video) {
    return FutureBuilder<Uint8List?>(
      future: video.thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.videocam,
                      color: Colors.grey[300],
                      size: 40,
                    ),
            ),
          );
        }
      },
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '没有${widget.title}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '暂无需要清理的项目',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
