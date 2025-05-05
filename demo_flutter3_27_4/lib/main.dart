import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/app_service.dart';
import 'services/battery_service.dart';
import 'services/media_service.dart';
import 'services/media_editor_service.dart';
import 'services/membership_service.dart';
import 'services/pay_service.dart';
import 'services/file_service.dart';
import 'services/file_editor_service.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => AppService()),
        ChangeNotifierProvider(create: (_) => BatteryService()),
        ChangeNotifierProvider(create: (_) => MediaService()),
        ChangeNotifierProvider(create: (_) => MediaEditorService()),
        ChangeNotifierProvider(create: (_) => MembershipService()),
        ChangeNotifierProvider(create: (_) => PayService()),
        ChangeNotifierProvider(create: (_) => FileService()),
        ChangeNotifierProvider(create: (_) => FileEditorService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final _pages = [
    HomeScreen(),
    PrivacyScreen(),
    ToolsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // Initialize services using providers
    final storageService = Provider.of<StorageService>(context, listen: false);
    final batteryService = Provider.of<BatteryService>(context, listen: false);
    final mediaService = Provider.of<MediaService>(context, listen: false);
    final payService = Provider.of<PayService>(context, listen: false);

    // Initialize each service
    storageService.analyzeStorage();
    batteryService.updateBatteryInfo();
    mediaService.loadMediaFiles();
    payService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '手机管家',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PingFang SC',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF7F9FC),
        primaryColor: Color(0xFF4A6FFF),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF4A6FFF),
          secondary: Color(0xFF5A7EFF),
          tertiary: Color(0xFF00C2CB),
          background: Color(0xFFF7F9FC),
          surface: Colors.white,
          onSurface: Color(0xFF303030),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF303030),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF303030),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerTheme: DividerThemeData(
          space: 1,
          thickness: 0.5,
          color: Colors.grey[200],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A6FFF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Color(0xFF4A6FFF),
                  unselectedItemColor: Color(0xFFAFB4C0),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconSize: 24,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.cleaning_services_outlined),
                      activeIcon: Icon(Icons.cleaning_services),
                      label: '清理',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shield_outlined),
                      activeIcon: Icon(Icons.shield),
                      label: '隐私',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_outlined),
                      activeIcon: Icon(Icons.grid_view),
                      label: '工具箱',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings_outlined),
                      activeIcon: Icon(Icons.settings),
                      label: '设置',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
