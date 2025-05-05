import 'package:flutter/material.dart';
import '../services/share_service.dart';
import 'pro_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                '设置',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 24),
                children: [
                  // PRO Banner Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3C5FFE), Color(0xFF5B7FFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF3C5FFE).withOpacity(0.3),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 装饰元素
                            Positioned(
                              right: -10,
                              top: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 0,
                              bottom: 0,
                              child: Image.asset(
                                'assets/images/pro.png',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '解锁无限制访问',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: Color(0xFF3C5FFE),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '解锁所有功能',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '了解更多',
                                      style: TextStyle(
                                        color: Color(0xFF3C5FFE),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // First section - My Favorites
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: '我的收藏',
                      iconData: Icons.bookmark_border,
                      showDivider: false,
                    ),
                  ]),

                  // Second section - Password & Privacy
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: '密码设置',
                      iconData: Icons.lock_outline,
                      showDivider: true,
                    ),
                    _buildSettingsTile(
                      title: '隐私保护',
                      iconData: Icons.shield_outlined,
                      showDivider: false,
                    ),
                  ]),

                  // Third section - Share, Rating, Privacy Policy, Eula, About
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: '分享',
                      iconData: Icons.share_outlined,
                      showDivider: true,
                      onTap: () => ShareService.shareApp(context),
                    ),
                    _buildSettingsTile(
                      title: '评价',
                      iconData: Icons.star_border_outlined,
                      showDivider: true,
                    ),
                    _buildSettingsTile(
                      title: '隐私政策',
                      iconData: Icons.privacy_tip_outlined,
                      showDivider: true,
                    ),
                    _buildSettingsTile(
                      title: 'Eula',
                      iconData: Icons.description_outlined,
                      showDivider: true,
                    ),
                    _buildSettingsTile(
                      title: '关于',
                      iconData: Icons.info_outline,
                      showDivider: false,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    IconData? iconData,
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: iconData != null
              ? Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    iconData,
                    color: Color(0xFF3C5FFE),
                    size: 22,
                  ),
                )
              : null,
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            size: 22,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          onTap: onTap ?? () {},
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: iconData != null ? 72 : 20,
            endIndent: 20,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
