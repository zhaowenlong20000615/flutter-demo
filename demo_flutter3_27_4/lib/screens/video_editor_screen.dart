import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/media_editor_service.dart';

class VideoEditorScreen extends StatefulWidget {
  final File? initialVideo;

  const VideoEditorScreen({
    Key? key,
    this.initialVideo,
  }) : super(key: key);

  @override
  _VideoEditorScreenState createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  File? _selectedVideo;
  File? _processedVideo;
  bool _isProcessing = false;
  RequestType _selectedQuality = RequestType.video;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  final ImagePicker _videoPicker = ImagePicker();
  final Map<RequestType, String> _qualityLabels = {
    RequestType.video: '默认',
    RequestType.image: '低',
    RequestType.audio: '中',
    RequestType.all: '高',
  };

  @override
  void initState() {
    super.initState();
    _selectedVideo = widget.initialVideo;
    _initializeVideoController();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoController() async {
    if (_selectedVideo != null) {
      _videoController = VideoPlayerController.file(_selectedVideo!);
      await _videoController!.initialize();
      setState(() {});
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _videoPicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
        _processedVideo = null;
      });

      if (_videoController != null) {
        await _videoController!.dispose();
      }
      await _initializeVideoController();
    }
  }

  Future<void> _compressVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isProcessing = true;
    });

    final mediaEditorService =
        Provider.of<MediaEditorService>(context, listen: false);
    final String? compressedPath = await mediaEditorService.compressVideo(
      _selectedVideo!,
      quality: _selectedQuality,
    );

    if (compressedPath != null) {
      setState(() {
        _processedVideo = File(compressedPath);
      });

      // 更新视频播放器以显示压缩后的视频
      if (_videoController != null) {
        await _videoController!.dispose();
      }
      _videoController = VideoPlayerController.file(_processedVideo!);
      await _videoController!.initialize();
      setState(() {});
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _saveVideo() async {
    if (_processedVideo == null) return;

    setState(() {
      _isProcessing = true;
    });

    final mediaEditorService =
        Provider.of<MediaEditorService>(context, listen: false);
    final String? savedPath =
        await mediaEditorService.saveProcessedVideoToGallery(
      _processedVideo!.path,
    );

    setState(() {
      _isProcessing = false;
    });

    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('视频已保存')),
      );
      Navigator.pop(context, File(savedPath));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败')),
      );
    }
  }

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          if (!_isPlaying)
            IconButton(
              icon: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
              onPressed: () {
                setState(() {
                  _isPlaying = true;
                });
                _videoController!.play();
                _videoController!.addListener(() {
                  if (_videoController!.value.position >=
                      _videoController!.value.duration) {
                    setState(() {
                      _isPlaying = false;
                    });
                    _videoController!.seekTo(Duration.zero);
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompressionControls() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '压缩质量',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _qualityLabels.entries.map((entry) {
              return _buildQualityOption(entry.key, entry.value);
            }).toList(),
          ),
          SizedBox(height: 24),
          if (_selectedVideo != null) ...[
            FutureBuilder<int>(
              future: _getVideoSize(_selectedVideo!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }

                final originalSize = _formatFileSize(snapshot.data!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('原始大小: $originalSize'),
                    if (_processedVideo != null)
                      FutureBuilder<int>(
                        future: _getVideoSize(_processedVideo!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }

                          final compressedSize =
                              _formatFileSize(snapshot.data!);
                          final originalSize = _selectedVideo!.lengthSync();
                          final compressionRatio =
                              (1 - (snapshot.data! / originalSize)) * 100;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('压缩后大小: $compressedSize'),
                              Text(
                                  '压缩率: ${compressionRatio.toStringAsFixed(1)}%'),
                            ],
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedVideo == null ? null : _compressVideo,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('压缩'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityOption(RequestType quality, String label) {
    final bool isSelected = _selectedQuality == quality;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedQuality = quality;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<int> _getVideoSize(File file) async {
    return file.length();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Future<Map<String, dynamic>> _getVideoInfo(File file) async {
    final fileName = path.basename(file.path);
    final fileSize = _formatFileSize(await file.length());
    final format = path.extension(file.path).replaceAll('.', '').toUpperCase();

    final mediaInfo = await VideoCompress.getMediaInfo(file.path);
    final width = mediaInfo.width?.toString() ?? 'Unknown';
    final height = mediaInfo.height?.toString() ?? 'Unknown';
    final duration = mediaInfo.duration != null
        ? '${(mediaInfo.duration! / 1000).toStringAsFixed(1)} 秒'
        : 'Unknown';

    return {
      'fileName': fileName,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'format': format,
      'duration': duration,
      'path': file.path,
    };
  }

  Widget _buildInfoTab() {
    if (_selectedVideo == null) {
      return Center(child: Text('没有选择视频'));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _getVideoInfo(_selectedVideo!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final info = snapshot.data!;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('文件名', info['fileName']),
              _buildInfoItem('大小', info['fileSize']),
              _buildInfoItem('分辨率', '${info['width']} x ${info['height']}'),
              _buildInfoItem('格式', info['format']),
              _buildInfoItem('时长', info['duration']),
              _buildInfoItem('路径', info['path']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('视频压缩'),
        centerTitle: true,
        actions: [
          if (_processedVideo != null)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveVideo,
            ),
        ],
      ),
      body: _selectedVideo == null
          ? Center(
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
                    '请选择视频',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _pickVideo,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('选择视频'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildVideoPreview(),
                    ),
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              Tab(
                                icon: Icon(Icons.compress),
                                text: '压缩',
                              ),
                              Tab(
                                icon: Icon(Icons.info_outline),
                                text: '信息',
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 250,
                            child: TabBarView(
                              children: [
                                _buildCompressionControls(),
                                _buildInfoTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 8.0,
                            percent: Provider.of<MediaEditorService>(context)
                                .compressionProgress,
                            center: Text(
                              '${(Provider.of<MediaEditorService>(context).compressionProgress * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            progressColor: Colors.blue,
                            backgroundColor: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '处理中...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _selectedVideo == null
          ? null
          : FloatingActionButton(
              onPressed: _pickVideo,
              child: Icon(Icons.video_library),
            ),
    );
  }
}
