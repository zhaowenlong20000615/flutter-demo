import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:temp_pay/pages/photo/models/photo_models.dart';

class PhotoDetailPage extends StatefulWidget {
  final String title;
  final List<PhotoItem> items;

  const PhotoDetailPage({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  late List<PhotoItem> _items;
  int _selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.items.map((item) {
      return PhotoItem(
        date: item.date,
        images: item.images.map((image) {
          return ImageItem(
            asset: image.asset,
            isSelected: image.isSelected,
          );
        }).toList(),
      );
    }).toList();
    _updateSelectedCount();
  }

  void _updateSelectedCount() {
    _selectedCount = _items.fold(0, (sum, item) {
      return sum + item.images.where((image) => image.isSelected).length;
    });
  }

  void _toggleImageSelection(PhotoItem item, ImageItem image) {
    setState(() {
      final itemIndex = _items.indexOf(item);
      final imageIndex = item.images.indexOf(image);
      _items[itemIndex].images[imageIndex] = ImageItem(
        asset: image.asset,
        isSelected: !image.isSelected,
      );
      _updateSelectedCount();
    });
  }

  Future<void> _deleteSelectedImages() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '确认删除',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3033),
          ),
        ),
        content: Text(
          '确定要删除选中的 $_selectedCount 张照片吗？',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF8F959E),
          ),
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
              final List<AssetEntity> assetsToDelete = [];
              for (var item in _items) {
                for (var image in item.images) {
                  if (image.isSelected) {
                    assetsToDelete.add(image.asset);
                  }
                }
              }

              try {
                await PhotoManager.editor.deleteWithIds(
                  assetsToDelete.map((e) => e.id).toList(),
                );
                
                setState(() {
                  for (var i = _items.length - 1; i >= 0; i--) {
                    _items[i].images.removeWhere((image) => image.isSelected);
                    if (_items[i].images.isEmpty) {
                      _items.removeAt(i);
                    }
                  }
                  _selectedCount = 0;
                });
              } catch (e) {
                // Handle error
              }
              
              Navigator.pop(context);
              if (_items.isEmpty) {
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
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF2E3033),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(
                color: Color(0xFF5C6EFF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8F959E),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: item.images.length,
                      itemBuilder: (context, imageIndex) {
                        final image = item.images[imageIndex];
                        return GestureDetector(
                          onTap: () => _toggleImageSelection(item, image),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  FutureBuilder<Uint8List?>(
                                    future: image.asset.thumbnailData,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data != null) {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: image.isSelected ? const Color(0xFF5C6EFF) : Colors.white,
                                        border: Border.all(
                                          color: image.isSelected ? const Color(0xFF5C6EFF) : Colors.white,
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
                                      child: image.isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
              onPressed: _selectedCount > 0 ? _deleteSelectedImages : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCount > 0 ? const Color(0xFF5C6EFF) : const Color(0xFFE8E9EC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: _selectedCount > 0 ? 2 : 0,
                shadowColor: _selectedCount > 0 ? const Color(0xFF5C6EFF).withOpacity(0.4) : Colors.transparent,
              ),
              child: Text(
                _selectedCount > 0 ? '删除($_selectedCount)' : '删除',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _selectedCount > 0 ? Colors.white : const Color(0xFF8F959E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 