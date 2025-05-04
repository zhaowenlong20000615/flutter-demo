import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

enum AppType {
  all,
  system,
  user,
}

class AppService extends ChangeNotifier {
  List<Application> _apps = [];
  final Set<Application> _selectedApps = {};

  List<Application> get selectedApps => _selectedApps.toList();

  AppService() {
    _loadApps();
  }

  Future<void> _loadApps() async {
    _apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    notifyListeners();
  }

  List<Application> getApps(AppType type) {
    switch (type) {
      case AppType.all:
        return _apps;
      case AppType.system:
        return _apps.where((app) => app.systemApp).toList();
      case AppType.user:
        return _apps.where((app) => !app.systemApp).toList();
    }
  }

  Map<String, int> getAppStatistics() {
    return {
      '全部': _apps.length,
      '系统': _apps.where((app) => app.systemApp).length,
      '用户': _apps.where((app) => !app.systemApp).length,
    };
  }

  void toggleAppSelection(Application app) {
    if (_selectedApps.contains(app)) {
      _selectedApps.remove(app);
    } else {
      _selectedApps.add(app);
    }
    notifyListeners();
  }

  void clearSelections() {
    _selectedApps.clear();
    notifyListeners();
  }

  Future<void> uninstallApp(Application app) async {
    if (!app.systemApp) {
      await DeviceApps.uninstallApp(app.packageName);
      await _loadApps();
    }
  }

  Future<void> uninstallSelectedApps() async {
    for (final app in _selectedApps.where((app) => !app.systemApp)) {
      await DeviceApps.uninstallApp(app.packageName);
    }
    _selectedApps.clear();
    await _loadApps();
  }

  // Future<void> clearAppData(String packageName) async {
  //   try {
  //     final success = await DeviceApps.clearAppData(packageName);
  //     if (success) {
  //       await loadInstalledApps();
  //     }
  //   } catch (e) {
  //     debugPrint('Error clearing app data: $e');
  //   }
  // }
}
