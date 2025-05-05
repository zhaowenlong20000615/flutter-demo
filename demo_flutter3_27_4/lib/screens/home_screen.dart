import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/app_service.dart';
import '../services/battery_service.dart';
import '../services/media_service.dart';
import '../screens/photo_management_screen.dart';
import '../screens/video_management_screen.dart';
import '../screens/contact_management_screen.dart';
import '../screens/pro_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    await storageService.analyzeStorage();

    final mediaService = Provider.of<MediaService>(context, listen: false);
    await mediaService.loadMediaFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('极速手机管家',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.5,
              color: Colors.white,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset('assets/images/pro.png', width: 24, height: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3B70), Color(0xFF29539B), Color(0xFF3A6073)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Welcome message
                  const Text(
                    '欢迎回来',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    '让我们保持您的设备顺畅运行',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 圆环进度
                  _buildStorageProgress(),

                  const SizedBox(height: 32),

                  // Section title
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 16),
                    child: Text(
                      '设备状态',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 存储/CPU/内存统计
                  _buildStatCards(),

                  const SizedBox(height: 32),

                  // Section title
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 16),
                    child: Text(
                      '清理工具',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 功能入口
                  _buildFeatureGrid(),

                  const SizedBox(height: 32),

                  // 清理指南
                  _buildCleaningGuide(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageProgress() {
    return Consumer<StorageService>(builder: (context, storageService, _) {
      // 计算存储空间使用百分比
      final usedPercentage = storageService.totalSpace > 0
          ? storageService.usedSpace / storageService.totalSpace
          : 0.0;

      return _GlassmorphicContainer(
        height: 450,
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              '设备存储',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect behind circle
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7FF0FF).withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Decorative circles
                ...List.generate(6, (index) {
                  final angle = index * (3.14159 * 2 / 6);
                  return Positioned(
                    left: 110 + 105 * math.cos(angle),
                    top: 110 + 105 * math.sin(angle),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: 240,
                  height: 240,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: usedPercentage),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Stack(
                      children: [
                        // Background track with gradient
                        CustomPaint(
                          painter: _CircleProgressBackgroundPainter(
                            strokeWidth: 20,
                          ),
                          size: const Size(240, 240),
                        ),
                        // Progress arc
                        CustomPaint(
                          painter: _CircleProgressPainter(
                            progress: value,
                            strokeWidth: 20,
                          ),
                          size: const Size(240, 240),
                        ),
                        // Small circles at start and end of progress
                        Positioned(
                          top: 10,
                          left: 120 - 5,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7FF0FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF7FF0FF).withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // End circle (animated)
                        Positioned(
                          top: 10 + 220 * math.sin(value * 2 * math.pi),
                          left: 120 - 5 + 220 * math.cos(value * 2 * math.pi),
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF7FF0FF).withOpacity(0.7),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '已用空间',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween:
                            Tween<double>(begin: 0, end: usedPercentage * 100),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _AnimatedButton(
              onPressed: () async {
                await storageService.cleanJunkFiles();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_fix_high),
                  SizedBox(width: 8),
                  Text(
                    '智能清理',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child:
              Consumer<StorageService>(builder: (context, storageService, _) {
            return _StatCard(
              title: '存储空间',
              value: '${storageService.usedSpace.toStringAsFixed(2)} GB',
              icon: Icons.storage,
              color: const Color(0xFF7FF0FF),
            );
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Consumer<BatteryService>(builder: (context, batteryService, _) {
            return _StatCard(
              title: 'CPU负载',
              value: '${batteryService.batteryLevel}%',
              icon: Icons.speed,
              color: const Color(0xFFFFB2E6),
            );
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer<AppService>(builder: (context, appService, _) {
            final stats = appService.getAppStatistics();
            return _StatCard(
              title: '应用数量',
              value: '${stats['全部'] ?? 0}',
              icon: Icons.memory,
              color: const Color(0xFFFFF07F),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return Consumer<MediaService>(builder: (context, mediaService, _) {
      final mediaStats = mediaService.getMediaStatistics();

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _FeatureButton(
            icon: Icons.image,
            color: const Color(0xFF7FF0FF),
            label: '照片清理',
            sub: '${mediaStats['图片'] ?? 0} 项目',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoManagementScreen(),
                ),
              );
            },
          ),
          _FeatureButton(
            icon: Icons.play_circle_filled_rounded,
            color: const Color(0xFFFFB2E6),
            label: '视频清理',
            sub: '${mediaStats['视频'] ?? 0} 项目',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoManagementScreen(),
                ),
              );
            },
          ),
          _FeatureButton(
            icon: Icons.people_alt_rounded,
            color: const Color(0xFFFFF07F),
            label: '联系人清理',
            sub: '${mediaService.contacts.length} 项目',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactManagementScreen(),
                ),
              );
            },
          ),
          _FeatureButton(
            icon: Icons.apps_rounded,
            color: const Color(0xFF7FFFB2),
            label: '应用清理',
            sub:
                '${Provider.of<AppService>(context, listen: false).getAppStatistics()['用户'] ?? 0} 项目',
            onTap: () {},
          ),
        ],
      );
    });
  }

  Widget _buildCleaningGuide(BuildContext context) {
    return _GlassmorphicContainer(
      height: 80,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF07F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tips_and_updates_rounded,
              color: Color(0xFFFFF07F), size: 28),
        ),
        title: const Text(
          '清理指南',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          '怎么清理更多的空间',
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

class _GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;

  const _GlassmorphicContainer({
    required this.child,
    this.height = 400,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B9E), Color(0xFFFF2D7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF2D7A).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Create shader for gradient
    final gradientShader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [
        Color(0xFF7FF0FF),
        Color(0xFF94B9FF),
        Color(0xFFB2A4FF),
        Color(0xFFFFB2E6),
        Color(0xFF7FF0FF),
      ],
      tileMode: TileMode.clamp,
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      progress * 2 * math.pi, // Convert to radians
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CircleProgressBackgroundPainter extends CustomPainter {
  final double strokeWidth;

  _CircleProgressBackgroundPainter({
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Create a path for the dashed background
    final Path path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
    );

    // Create the dash effect
    final dashWidth = 6.0;
    final dashSpace = 4.0;
    final dashCount = (2 * math.pi * radius) ~/ (dashWidth + dashSpace);

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final dashPathEffect = PathDashPathEffect(
      Path()..addRect(Rect.fromLTWH(0, 0, dashWidth, strokeWidth)),
      dashWidth + dashSpace,
      phase: 0,
      pathLength: dashCount * (dashWidth + dashSpace),
    );

    canvas.drawPath(
      dashPathEffect.applyTo(path),
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PathDashPathEffect {
  final Path dashPath;
  final double dashDistance;
  final double phase;
  final double pathLength;

  PathDashPathEffect(
    this.dashPath,
    this.dashDistance, {
    this.phase = 0.0,
    required this.pathLength,
  });

  Path applyTo(Path path) {
    final Path result = Path();
    final PathMetrics metrics = path.computeMetrics();
    metrics.forEach((PathMetric metric) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double currentPhase = (phase + distance) % (dashDistance * 2);
        if (currentPhase < dashDistance) {
          final Path extractPath = metric.extractPath(
            distance,
            distance + dashPath.getBounds().width,
          );
          result.addPath(
            extractPath,
            Offset.zero,
          );
        }
        distance += dashDistance;
      }
    });
    return result;
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassmorphicContainer(
      height: 120,
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassmorphicContainer(
      height: 160,
      borderRadius: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sub,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
