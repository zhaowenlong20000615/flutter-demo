import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

class BatteryService extends ChangeNotifier {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryStatus = BatteryState.unknown;
  bool _isPowerSavingMode = false;

  BatteryService() {
    _initBatteryInfo();
  }

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryStatus => _batteryStatus;
  bool get isPowerSavingMode => _isPowerSavingMode;

  Future<void> _initBatteryInfo() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryStatus = await _battery.batteryState;
      _isPowerSavingMode = await _battery.isInBatterySaveMode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting battery info: $e');
    }

    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryStatus = state;
      _battery.batteryLevel.then((level) {
        _batteryLevel = level;
        notifyListeners();
      });
    });
  }

  void updateBatteryInfo() {
    _initBatteryInfo();
  }

  Future<void> optimizeBattery() async {
    // TODO: 实现电池优化功能
  }
}
