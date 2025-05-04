import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SystemInfoService extends ChangeNotifier {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  double _cpuUsage = 0;
  double _memoryUsage = 0;
  int _batteryLevel = 0;
  String _batteryStatus = '未知';
  double _batteryTemperature = 0;

  SystemInfoService() {
    _initBatteryInfo();
    _initSystemInfo();
  }

  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  int get batteryLevel => _batteryLevel;
  String get batteryStatus => _batteryStatus;
  double get batteryTemperature => _batteryTemperature;

  Future<void> _initBatteryInfo() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      final status = await _battery.batteryState;
      _batteryStatus = _getBatteryStatusString(status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting battery info: $e');
    }
  }

  Future<void> _initSystemInfo() async {
    try {
      // 获取设备信息
      final deviceInfo = await _deviceInfo.deviceInfo;

      // 由于Flutter的限制，我们无法直接获取CPU和内存使用率
      // 这里我们使用一些默认值
      _cpuUsage = 0;
      _memoryUsage = 0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error getting system info: $e');
    }
  }

  String _getBatteryStatusString(BatteryState status) {
    switch (status) {
      case BatteryState.full:
        return '已充满';
      case BatteryState.charging:
        return '充电中';
      case BatteryState.discharging:
        return '放电中';
      default:
        return '未知';
    }
  }

  void updateInfo() {
    _initBatteryInfo();
    _initSystemInfo();
  }
}
