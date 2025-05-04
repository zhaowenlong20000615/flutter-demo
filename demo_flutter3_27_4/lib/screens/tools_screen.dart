import 'package:flutter/material.dart';
import 'photo_management_screen.dart';
import 'video_management_screen.dart';
import 'contact_management_screen.dart';
import 'image_editor_screen.dart';
import 'video_editor_screen.dart';

class ToolsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('工具中心', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 30),
        children: [
          _SearchBar(),
          SizedBox(height: 28),
          _CategorySection(
            title: '照片和视频',
            icon: Icons.photo_library_rounded,
            tools: [
              ToolItem(
                icon: Icons.cleaning_services_outlined,
                gradient: [Color(0xFF3C5FFE), Color(0xFF7AA5FF)],
                label: '照片清理',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoManagementScreen(),
                    ),
                  );
                },
              ),
              ToolItem(
                icon: Icons.video_camera_back_rounded,
                gradient: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                label: '视频清理',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoManagementScreen(),
                    ),
                  );
                },
              ),
              ToolItem(
                icon: Icons.photo_size_select_large_rounded,
                gradient: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                label: '照片压缩',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageEditorScreen(),
                    ),
                  );
                },
              ),
              ToolItem(
                icon: Icons.video_camera_back_rounded,
                gradient: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                label: '视频压缩',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoEditorScreen(),
                    ),
                  );
                },
              ),
              ToolItem(
                icon: Icons.location_on_rounded,
                gradient: [Color(0xFFFDC830), Color(0xFFF37335)],
                label: '照片位置清理',
                onTap: () {},
              ),
              ToolItem(
                icon: Icons.qr_code_scanner_rounded,
                gradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                label: '隐私扫描',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 32),
          _CategorySection(
            title: '实用工具',
            icon: Icons.widgets_rounded,
            tools: [
              ToolItem(
                icon: Icons.people_outlined,
                gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
                label: '联系人清理',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactManagementScreen(),
                    ),
                  );
                },
              ),
              ToolItem(
                icon: Icons.check_circle_rounded,
                gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
                label: '短信过滤',
                onTap: () {},
              ),
              ToolItem(
                icon: Icons.person_rounded,
                gradient: [Color(0xFF834D9B), Color(0xFFD04ED6)],
                label: '联系人备份',
                onTap: () {},
              ),
              ToolItem(
                icon: Icons.content_cut_rounded,
                gradient: [Color(0xFF396AFC), Color(0xFF2948FF)],
                label: '清空剪贴板',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 32),
          _CategorySection(
            title: '电池优化',
            icon: Icons.battery_charging_full_rounded,
            tools: [
              ToolItem(
                icon: Icons.battery_charging_full_rounded,
                gradient: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                label: '省电教程',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '搜索工具...',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ToolItem> tools;

  const _CategorySection({
    required this.title,
    required this.icon,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          itemBuilder: (context, index) => tools[index],
        ),
      ],
    );
  }
}

class ToolItem extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String label;
  final VoidCallback onTap;

  const ToolItem({
    required this.icon,
    required this.gradient,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
