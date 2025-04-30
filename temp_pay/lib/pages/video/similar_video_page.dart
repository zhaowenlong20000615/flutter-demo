import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:temp_pay/pages/video/models/video_models.dart';

class SimilarVideoPage extends StatefulWidget {
  final List<VideoFile> videos;

  const SimilarVideoPage({super.key, required this.videos});

  @override
  State<SimilarVideoPage> createState() => _SimilarVideoPageState();
}

class _SimilarVideoPageState extends State<SimilarVideoPage> {
  late List<VideoFile> _videos;
  int _selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _videos = widget.videos;
    _updateSelectedCount();
  }

  void _updateSelectedCount() {
    _selectedCount = _videos.where((video) => video.isSelected).length;
  }

  Future<void> _deleteSelectedVideos() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              '确认删除',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3033),
              ),
            ),
            content: Text(
              '确定要删除选中的 $_selectedCount 个视频吗？',
              style: const TextStyle(fontSize: 16, color: Color(0xFF8F959E)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8F959E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final selectedVideos =
                      _videos.where((video) => video.isSelected).toList();
                  for (final video in selectedVideos) {
                    await PhotoManager.editor.deleteWithIds([video.asset.id]);
                  }

                  setState(() {
                    _videos.removeWhere((video) => video.isSelected);
                    _selectedCount = 0;
                  });

                  Navigator.pop(context);
                  if (_videos.isEmpty) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  '删除',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
          '相似视频',
          style: TextStyle(
            color: Color(0xFF2E3033),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: video.asset.thumbnailData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.memory(
                                snapshot.data!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _videos[index] = VideoFile(
                                  asset: video.asset,
                                  title: video.title,
                                  subtitle: video.subtitle,
                                  isSelected: !video.isSelected,
                                );
                                _updateSelectedCount();
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    video.isSelected
                                        ? const Color(0xFF5C6EFF)
                                        : Colors.white,
                                border: Border.all(
                                  color:
                                      video.isSelected
                                          ? const Color(0xFF5C6EFF)
                                          : Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child:
                                  video.isSelected
                                      ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  video.subtitle,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _selectedCount > 0 ? _deleteSelectedVideos : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedCount > 0
                        ? const Color(0xFF5C6EFF)
                        : const Color(0xFFE8E9EC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: _selectedCount > 0 ? 2 : 0,
                shadowColor:
                    _selectedCount > 0
                        ? const Color(0xFF5C6EFF).withOpacity(0.4)
                        : Colors.transparent,
              ),
              child: Text(
                _selectedCount > 0 ? '删除($_selectedCount)' : '删除',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      _selectedCount > 0
                          ? Colors.white
                          : const Color(0xFF8F959E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
