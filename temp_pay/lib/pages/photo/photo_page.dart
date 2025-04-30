import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:temp_pay/pages/photo/models/photo_models.dart';
import 'package:temp_pay/pages/photo/photo_detail_page.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  List<PhotoItem> _screenshots = [];
  List<PhotoItem> _similarPhotos = [];
  List<PhotoItem> _blurPhotos = [];
  List<PhotoItem> _burstPhotos = [];
  List<PhotoItem> _livePhotos = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (state.hasAccess) {
      _loadPhotos();
    } else {
      // Handle permission denied
    }
  }

  Future<void> _loadPhotos() async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          needTitle: true,
        ),
        orders: [
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ],
      ),
    );

    if (paths.isEmpty) return;

    final List<AssetEntity> allPhotos = await paths[0].getAssetListRange(
      start: 0,
      end: 1000,
    );

    // Group photos by date
    final Map<String, List<AssetEntity>> groupedPhotos = {};
    for (final photo in allPhotos) {
      final date = photo.createDateTime;
      final dateStr = '${date.month}月 ${date.day}, ${date.year}';
      groupedPhotos.putIfAbsent(dateStr, () => []).add(photo);
    }

    // Convert to PhotoItem list
    final List<PhotoItem> photos = groupedPhotos.entries.map((entry) {
      return PhotoItem(
        date: entry.key,
        images: entry.value.map((asset) => ImageItem(asset: asset)).toList(),
      );
    }).toList();

    setState(() {
      _screenshots = photos.where((item) {
        return item.images.any((image) => image.asset.title?.toLowerCase().contains('screenshot') ?? false);
      }).toList();
      
      _similarPhotos = photos.where((item) {
        return item.images.any((image) => image.asset.title?.toLowerCase().contains('similar') ?? false);
      }).toList();
      
      _blurPhotos = photos.where((item) {
        return item.images.any((image) => image.asset.title?.toLowerCase().contains('blur') ?? false);
      }).toList();
      
      _burstPhotos = photos.where((item) {
        return item.images.any((image) => image.asset.title?.toLowerCase().contains('burst') ?? false);
      }).toList();
      
      _livePhotos = photos.where((item) {
        return item.images.any((image) => image.asset.title?.toLowerCase().contains('live') ?? false);
      }).toList();
    });
  }

  void _navigateToDetail(BuildContext context, String title, List<PhotoItem> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailPage(
          title: title,
          items: items,
        ),
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
          '照片',
          style: TextStyle(
            color: Color(0xFF2E3033),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildPhotoItem(
            context: context,
            icon: Icons.compare_rounded,
            title: '相似照片',
            subtitle: '${_similarPhotos.fold(0, (sum, item) => sum + item.images.length)} 张照片',
            size: '${(_similarPhotos.fold(0, (sum, item) => sum + item.images.fold(0, (sum, image) => sum + (image.asset.size as int? ?? 0))) / 1024 / 1024).toStringAsFixed(2)}M',
            onTap: () => _navigateToDetail(context, '相似照片', _similarPhotos),
            iconColor: const Color(0xFF5C6EFF),
            bgColor: const Color(0xFFEEF0FF),
          ),
          const SizedBox(height: 16),
          _buildPhotoItem(
            context: context,
            icon: Icons.image_outlined,
            title: '模糊图片',
            subtitle: '${_blurPhotos.fold(0, (sum, item) => sum + item.images.length)} 张照片',
            size: '${(_blurPhotos.fold(0, (sum, item) => sum + item.images.fold(0, (sum, image) => sum + (image.asset.size as int? ?? 0))) / 1024 / 1024).toStringAsFixed(2)}M',
            onTap: () => _navigateToDetail(context, '模糊图片', _blurPhotos),
            iconColor: const Color(0xFF6C5CFF),
            bgColor: const Color(0xFFF0EEFF),
          ),
          const SizedBox(height: 16),
          _buildPhotoItem(
            context: context,
            icon: Icons.screenshot_rounded,
            title: '屏幕截图',
            subtitle: '${_screenshots.fold(0, (sum, item) => sum + item.images.length)} 张照片',
            size: '${(_screenshots.fold(0, (sum, item) => sum + item.images.fold(0, (sum, image) => sum + (image.asset.size as int? ?? 0))) / 1024 / 1024).toStringAsFixed(2)}M',
            onTap: () => _navigateToDetail(context, '屏幕截图', _screenshots),
            iconColor: const Color(0xFF5C6EFF),
            bgColor: const Color(0xFFEEF0FF),
          ),
          const SizedBox(height: 16),
          _buildPhotoItem(
            context: context,
            icon: Icons.filter_rounded,
            title: '连拍快照',
            subtitle: '${_burstPhotos.fold(0, (sum, item) => sum + item.images.length)} 张照片',
            size: '${(_burstPhotos.fold(0, (sum, item) => sum + item.images.fold(0, (sum, image) => sum + (image.asset.size as int? ?? 0))) / 1024 / 1024).toStringAsFixed(2)}M',
            onTap: () => _navigateToDetail(context, '连拍快照', _burstPhotos),
            iconColor: const Color(0xFF6C5CFF),
            bgColor: const Color(0xFFF0EEFF),
          ),
          const SizedBox(height: 16),
          _buildPhotoItem(
            context: context,
            icon: Icons.camera_alt_rounded,
            title: '相似实况照片',
            subtitle: '${_livePhotos.fold(0, (sum, item) => sum + item.images.length)} 张照片',
            size: '${(_livePhotos.fold(0, (sum, item) => sum + item.images.fold(0, (sum, image) => sum + (image.asset.size as int? ?? 0))) / 1024 / 1024).toStringAsFixed(2)}M',
            onTap: () => _navigateToDetail(context, '相似实况照片', _livePhotos),
            iconColor: const Color(0xFF5C6EFF),
            bgColor: const Color(0xFFEEF0FF),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem({
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
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.9),
                        iconColor,
                      ],
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