import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/media_service.dart';

class PhotoCleanupScreen extends StatefulWidget {
  final String title;
  final List<AssetEntity> photos;

  PhotoCleanupScreen({
    required this.title,
    required this.photos,
  });

  @override
  _PhotoCleanupScreenState createState() => _PhotoCleanupScreenState();
}

class _PhotoCleanupScreenState extends State<PhotoCleanupScreen> {
  Set<AssetEntity> _selectedPhotos = {};
  bool _isSelectMode = false;

  @override
  Widget build(BuildContext context) {
    final mediaService = Provider.of<MediaService>(context);
    final hasPhotos = widget.photos.isNotEmpty;

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
          if (hasPhotos && _isSelectMode)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedPhotos.length == widget.photos.length) {
                    _selectedPhotos.clear();
                  } else {
                    _selectedPhotos = Set.from(widget.photos);
                  }
                });
              },
              child: Text(
                _selectedPhotos.length == widget.photos.length ? '全不选' : '全选',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (hasPhotos && !_isSelectMode)
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
      body: !hasPhotos
          ? _buildEmptyState()
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                final isSelected = _selectedPhotos.contains(photo);

                return GestureDetector(
                  onTap: () {
                    if (_isSelectMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedPhotos.remove(photo);
                        } else {
                          _selectedPhotos.add(photo);
                        }
                      });
                    } else {
                      // Open photo viewer
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectMode) {
                      setState(() {
                        _isSelectMode = true;
                        _selectedPhotos.add(photo);
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildAssetThumb(photo),
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
      bottomNavigationBar: _isSelectMode && _selectedPhotos.isNotEmpty
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
                      '已选择 ${_selectedPhotos.length} 项',
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
                                Text('是否确认删除选中的 ${_selectedPhotos.length} 项？'),
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
                                  // Delete selected photos
                                  for (var photo in _selectedPhotos) {
                                    await mediaService.deleteMediaFile(photo);
                                  }
                                  setState(() {
                                    _selectedPhotos.clear();
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

  Widget _buildAssetThumb(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.image,
                      color: Colors.grey[600],
                    ),
            ),
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
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
