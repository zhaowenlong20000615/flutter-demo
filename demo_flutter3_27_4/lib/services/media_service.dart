import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart' as fcs;
import '../models/contact_info.dart';

class MediaService with ChangeNotifier {
  List<AssetEntity> _images = [];
  List<AssetEntity> _videos = [];
  List<AssetEntity> _audio = [];
  List<ContactInfo> _contacts = [];
  Set<AssetEntity> _selectedAssets = {};
  Set<ContactInfo> _selectedContacts = {};

  List<AssetEntity> get images => _images;
  List<AssetEntity> get videos => _videos;
  List<AssetEntity> get audio => _audio;
  List<ContactInfo> get contacts => _contacts;
  Set<AssetEntity> get selectedAssets => _selectedAssets;
  Set<ContactInfo> get selectedContacts => _selectedContacts;

  Future<void> loadMediaFiles() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps.hasAccess) {
      try {
        // 获取所有相册
        final List<AssetPathEntity> paths =
            await PhotoManager.getAssetPathList();
        if (paths.isEmpty) return;

        // 获取"全部"相册
        final AssetPathEntity path = paths.first;

        // 清空旧数据
        _images = [];
        _videos = [];
        _audio = [];

        // 获取媒体资源
        final List<AssetEntity> assets =
            await path.getAssetListRange(start: 0, end: 1000);

        // 按类型分类
        for (var asset in assets) {
          switch (asset.type) {
            case AssetType.image:
              _images.add(asset);
              break;
            case AssetType.video:
              _videos.add(asset);
              break;
            case AssetType.audio:
              _audio.add(asset);
              break;
            default:
              break;
          }
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error loading media files: $e');
      }
    }
  }

  Future<void> loadContacts() async {
    if (await Permission.contacts.request().isGranted) {
      try {
        final fcsContacts = await fcs.FlutterContactsService.getContacts();
        _contacts =
            fcsContacts.map((c) => ContactInfo.fromFcsContact(c)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading contacts: $e');
      }
    }
  }

  Future<void> deleteMediaFile(AssetEntity asset) async {
    try {
      final List<String> result =
          await PhotoManager.editor.deleteWithIds([asset.id]);
      if (result.isNotEmpty) {
        _images.removeWhere((a) => a.id == asset.id);
        _videos.removeWhere((a) => a.id == asset.id);
        _audio.removeWhere((a) => a.id == asset.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting media file: $e');
    }
  }

  Future<void> deleteContact(ContactInfo contact) async {
    try {
      if (contact.originalContact != null) {
        await fcs.FlutterContactsService.deleteContact(
            contact.originalContact!);
      }
      _contacts.remove(contact);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting contact: $e');
    }
  }

  Future<void> addContact(ContactInfo contact) async {
    try {
      if (contact.originalContact != null) {
        await fcs.FlutterContactsService.addContact(contact.originalContact!);
      }
      _contacts.add(contact);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding contact: $e');
    }
  }

  Future<void> updateContact(ContactInfo contact) async {
    try {
      if (contact.originalContact != null) {
        await fcs.FlutterContactsService.updateContact(
            contact.originalContact!);
      }
      final index =
          _contacts.indexWhere((c) => c.identifier == contact.identifier);
      if (index != -1) {
        _contacts[index] = contact;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating contact: $e');
    }
  }

  void toggleAssetSelection(AssetEntity asset) {
    if (_selectedAssets.contains(asset)) {
      _selectedAssets.remove(asset);
    } else {
      _selectedAssets.add(asset);
    }
    notifyListeners();
  }

  void toggleContactSelection(ContactInfo contact) {
    if (_selectedContacts.contains(contact)) {
      _selectedContacts.remove(contact);
    } else {
      _selectedContacts.add(contact);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedAssets() async {
    final List<String> ids = _selectedAssets.map((asset) => asset.id).toList();
    final List<String> deletedIds =
        await PhotoManager.editor.deleteWithIds(ids);

    if (deletedIds.isNotEmpty) {
      // 移除已删除的资源
      _images.removeWhere((asset) => deletedIds.contains(asset.id));
      _videos.removeWhere((asset) => deletedIds.contains(asset.id));
      _audio.removeWhere((asset) => deletedIds.contains(asset.id));
      _selectedAssets.clear();
      notifyListeners();
    }
  }

  Future<void> deleteSelectedContacts() async {
    for (final contact in _selectedContacts) {
      await deleteContact(contact);
    }
    _selectedContacts.clear();
    notifyListeners();
  }

  void clearSelections() {
    _selectedAssets.clear();
    _selectedContacts.clear();
    notifyListeners();
  }

  Map<String, int> getMediaStatistics() {
    return {
      '图片': _images.length,
      '视频': _videos.length,
      '音频': _audio.length,
    };
  }

  Map<String, int> getContactStatistics() {
    return {
      '总联系人': _contacts.length,
      '有电话号码': _contacts.where((c) => c.phones?.isNotEmpty ?? false).length,
    };
  }
}
