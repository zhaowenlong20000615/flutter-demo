import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../services/media_editor_service.dart';

class ImageEditorScreen extends StatefulWidget {
  final File? initialImage;

  const ImageEditorScreen({
    Key? key,
    this.initialImage,
  }) : super(key: key);

  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  File? _processedImage;
  bool _isProcessing = false;
  int _compressionQuality = 70;

  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedImage = widget.initialImage;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _processedImage = null;
      });
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _selectedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪图片',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: '裁剪图片',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _processedImage = File(croppedFile.path);
        _selectedImage = _processedImage;
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _rotateImage(int degrees) async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    final mediaEditorService =
        Provider.of<MediaEditorService>(context, listen: false);
    final String? rotatedPath =
        await mediaEditorService.rotateImage(_selectedImage!, degrees);

    if (rotatedPath != null) {
      setState(() {
        _processedImage = File(rotatedPath);
        _selectedImage = _processedImage;
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _compressImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    final mediaEditorService =
        Provider.of<MediaEditorService>(context, listen: false);
    final String? compressedPath = await mediaEditorService.compressImage(
      _selectedImage!,
      quality: _compressionQuality,
    );

    if (compressedPath != null) {
      setState(() {
        _processedImage = File(compressedPath);
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    // 在实际应用中，这里会调用适当的方法将图片保存到相册
    final mediaEditorService =
        Provider.of<MediaEditorService>(context, listen: false);
    final String? savedPath =
        await mediaEditorService.saveProcessedImageToGallery(
      _processedImage!.path,
    );

    setState(() {
      _isProcessing = false;
    });

    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片已保存')),
      );
      Navigator.pop(context, File(savedPath));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败')),
      );
    }
  }

  Widget _buildImagePreview() {
    final File displayImage = _processedImage ?? _selectedImage!;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          displayImage,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCompressionTab() {
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
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _compressionQuality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 9,
                  label: '$_compressionQuality%',
                  onChanged: (value) {
                    setState(() {
                      _compressionQuality = value.round();
                    });
                  },
                ),
              ),
              Text(
                '$_compressionQuality%',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_selectedImage != null) ...[
            FutureBuilder<int>(
              future: _getImageSize(_selectedImage!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }

                final originalSize = _formatFileSize(snapshot.data!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('原始大小: $originalSize'),
                    if (_processedImage != null)
                      FutureBuilder<int>(
                        future: _getImageSize(_processedImage!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }

                          final compressedSize =
                              _formatFileSize(snapshot.data!);
                          final originalSize = _selectedImage!.lengthSync();
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
              onPressed: _selectedImage == null ? null : _compressImage,
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

  Widget _buildCropRotateTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRotateButton(90, Icons.rotate_90_degrees_cw_outlined),
              _buildRotateButton(180, Icons.rotate_left_outlined),
              _buildRotateButton(270, Icons.rotate_right_outlined),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedImage == null ? null : _cropImage,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('裁剪'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotateButton(int degrees, IconData icon) {
    return InkWell(
      onTap: _selectedImage == null ? null : () => _rotateImage(degrees),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            SizedBox(height: 8),
            Text('$degrees°'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    if (_selectedImage == null) {
      return Center(child: Text('没有选择图片'));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _getImageInfo(_selectedImage!),
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

  Future<int> _getImageSize(File file) async {
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

  Future<Map<String, dynamic>> _getImageInfo(File file) async {
    final fileName = path.basename(file.path);
    final fileSize = _formatFileSize(await file.length());
    final format = path.extension(file.path).replaceAll('.', '').toUpperCase();

    // 实际应用中会获取真实的图片尺寸
    // 这里简化处理
    final width = '1920';
    final height = '1080';

    return {
      'fileName': fileName,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'format': format,
      'path': file.path,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('图片编辑器'),
        centerTitle: true,
        actions: [
          if (_processedImage != null)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveImage,
            ),
        ],
      ),
      body: _selectedImage == null
          ? Center(
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
                    '请选择图片',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('选择图片'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: _buildImagePreview(),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.photo_size_select_large_outlined),
                          text: '压缩',
                        ),
                        Tab(
                          icon: Icon(Icons.crop_rotate),
                          text: '裁剪/旋转',
                        ),
                        Tab(
                          icon: Icon(Icons.info_outline),
                          text: '信息',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCompressionTab(),
                          _buildCropRotateTab(),
                          _buildInfoTab(),
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
      floatingActionButton: _selectedImage == null
          ? null
          : FloatingActionButton(
              onPressed: _pickImage,
              child: Icon(Icons.photo_library),
            ),
    );
  }
}
