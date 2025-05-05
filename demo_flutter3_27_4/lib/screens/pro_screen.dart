import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pay_service.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({Key? key}) : super(key: key);

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  int _selectedPlan = 0; // 0 表示年度，1 表示周度

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.close, color: Color(0xFF2E5BFF), size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () {
                // 恢复购买使用 PayService
                final payService =
                    Provider.of<PayService>(context, listen: false);
                payService.restorePurchases();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
              ),
              child: const Text(
                '恢复',
                style: TextStyle(
                  color: Color(0xFF2E5BFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 图片堆叠与蓝色对勾
                  _buildImageStack(),

                  const SizedBox(height: 24),

                  // 标题
                  const Text(
                    '高效手机管理工具',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2151),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '全方位提升您的手机使用体验，释放设备潜能',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF1A2151).withOpacity(0.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 功能特点
                  _buildFeatureItem(
                    icon: Icons.people_alt_rounded,
                    title: '定制专属联系人组件',
                    subtitle: '桌面组件可一键联系朋友',
                  ),

                  const SizedBox(height: 24),

                  _buildFeatureItem(
                    icon: Icons.photo_library_rounded,
                    title: '智能相册管理',
                    subtitle: '清理相册节省存储空间',
                  ),

                  const SizedBox(height: 24),

                  _buildFeatureItem(
                    icon: Icons.security_rounded,
                    title: '安全应用管理',
                    subtitle: '应用上锁保护手机隐私',
                  ),

                  const SizedBox(height: 40),

                  // 订阅选项
                  _buildSubscriptionOptions(),

                  const SizedBox(height: 16),

                  // 条款和隐私
                  _buildTermsAndPrivacy(),
                ],
              ),
            ),
          ),

          // 订阅按钮
          _buildSubscribeButton(),
        ],
      ),
    );
  }

  Widget _buildImageStack() {
    return Container(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景蓝色渐变
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2E5BFF).withOpacity(0.2),
                  const Color(0xFFF5F8FF)
                ],
                stops: const [0.2, 0.9],
              ),
            ),
          ),

          // 左侧卡片
          Transform.translate(
            offset: const Offset(-80, 0),
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                height: 150,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF7B61FF).withOpacity(0.2),
                              const Color(0xFF5AC8FA).withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9500), Color(0xFFFF2D55)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9500).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      Positioned(
                        left: -8,
                        bottom: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E5BFF), Color(0xFF5AC8FA)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E5BFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 中间卡片与图标
          Container(
            height: 150,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E5BFF).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E5BFF).withOpacity(0.1),
                      const Color(0xFF5AC8FA).withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 48,
                    color: const Color(0xFF2E5BFF).withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),

          // 顶部对勾
          Positioned(
            top: 70,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E5BFF), Color(0xFF5AC8FA)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E5BFF).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
          ),

          // 右侧蓝色图片图标
          Positioned(
            right: 80,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E5BFF), Color(0xFF5AC8FA)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E5BFF).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.image,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E5BFF).withOpacity(0.1),
                    const Color(0xFF5AC8FA).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E5BFF),
                size: 30,
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
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1A2151).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              '选择您的会员方案',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2151),
              ),
            ),
          ),

          // 年度方案
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlan = 0;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: _selectedPlan == 0
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2E5BFF), Color(0xFF5AC8FA)],
                      )
                    : null,
                color: _selectedPlan == 0 ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _selectedPlan == 0
                        ? const Color(0xFF2E5BFF).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedPlan == 0
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                      border: Border.all(
                        color: _selectedPlan == 0
                            ? Colors.white
                            : const Color(0xFF2E5BFF),
                        width: 2,
                      ),
                    ),
                    child: _selectedPlan == 0
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '¥288.00',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _selectedPlan == 0
                                  ? Colors.white
                                  : const Color(0xFF2E5BFF),
                            ),
                          ),
                          Text(
                            '/年',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _selectedPlan == 0
                                  ? Colors.white.withOpacity(0.8)
                                  : const Color(0xFF2E5BFF).withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedPlan == 0
                                  ? Colors.white.withOpacity(0.3)
                                  : const Color(0xFF2E5BFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '推荐',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _selectedPlan == 0
                                    ? Colors.white
                                    : const Color(0xFF2E5BFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '订阅试用3天, 然后¥288.00/年',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedPlan == 0
                              ? Colors.white.withOpacity(0.8)
                              : const Color(0xFF1A2151).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 周度方案
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlan = 1;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: _selectedPlan == 1
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2E5BFF), Color(0xFF5AC8FA)],
                      )
                    : null,
                color: _selectedPlan == 1 ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _selectedPlan == 1
                        ? const Color(0xFF2E5BFF).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedPlan == 1
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                      border: Border.all(
                        color: _selectedPlan == 1
                            ? Colors.white
                            : const Color(0xFF2E5BFF),
                        width: 2,
                      ),
                    ),
                    child: _selectedPlan == 1
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Text(
                        '¥18.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _selectedPlan == 1
                              ? Colors.white
                              : const Color(0xFF2E5BFF),
                        ),
                      ),
                      Text(
                        '/周',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedPlan == 1
                              ? Colors.white.withOpacity(0.8)
                              : const Color(0xFF2E5BFF).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E5BFF).withOpacity(0.1),
              border:
                  Border.all(color: const Color(0xFF2E5BFF).withOpacity(0.5)),
            ),
            child: const Icon(Icons.check, color: Color(0xFF2E5BFF), size: 16),
          ),
          const SizedBox(width: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Color(0xFF1A2151), fontSize: 14),
              children: [
                TextSpan(text: '已阅读并同意 '),
                TextSpan(
                  text: '《付费会员协议》',
                  style: TextStyle(
                    color: Color(0xFF2E5BFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // 使用 PayService 处理订阅
          final payService = Provider.of<PayService>(context, listen: false);
          if (_selectedPlan == 0) {
            // 年度订阅
            payService.purchaseYearlySubscription();
          } else {
            // 周度订阅
            payService.purchaseWeeklySubscription();
          }
          // Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5BFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF2E5BFF).withOpacity(0.5),
        ),
        child: const Text(
          '现在订阅',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
