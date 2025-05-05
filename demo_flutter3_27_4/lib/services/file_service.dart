import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart' as fcs;
import 'package:path/path.dart' as path;
import '../models/contact_info.dart';

class FileService with ChangeNotifier {
  List<File> _images = [];
  List<File> _videos = [];
  List<File> _audio = [];
  List<ContactInfo> _contacts = [];
  Set<File> _selectedFiles = {};
  Set<ContactInfo> _selectedContacts = {};

  List<File> get images => _images;
  List<File> get videos => _videos;
  List<File> get audio => _audio;
  List<ContactInfo> get contacts => _contacts;
  Set<File> get selectedFiles => _selectedFiles;
  Set<ContactInfo> get selectedContacts => _selectedContacts;

  Future<void> loadMediaFiles() async {
    if (await Permission.storage.request().isGranted) {
      try {
        final List<Directory> storageDirectories =
            await getExternalStorageDirectories() ?? [];
        for (var dir in storageDirectories) {
          await _scanMediaFiles(dir);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading media files: $e');
      }
    }
  }

  Future<void> _scanMediaFiles(Directory directory) async {
    try {
      final List<FileSystemEntity> entities =
          await directory.list(recursive: true).toList();

      for (var entity in entities) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          if (path.endsWith('.jpg') ||
              path.endsWith('.jpeg') ||
              path.endsWith('.png') ||
              path.endsWith('.gif')) {
            _images.add(entity);
          } else if (path.endsWith('.mp4') ||
              path.endsWith('.avi') ||
              path.endsWith('.mov')) {
            _videos.add(entity);
          } else if (path.endsWith('.mp3') ||
              path.endsWith('.wav') ||
              path.endsWith('.aac')) {
            _audio.add(entity);
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning media files: $e');
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

  Future<void> deleteMediaFile(File file) async {
    try {
      await file.delete();
      _images.remove(file);
      _videos.remove(file);
      _audio.remove(file);
      notifyListeners();
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

  void toggleFileSelection(File file) {
    if (_selectedFiles.contains(file)) {
      _selectedFiles.remove(file);
    } else {
      _selectedFiles.add(file);
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

  Future<void> deleteSelectedFiles() async {
    for (final file in _selectedFiles) {
      await deleteMediaFile(file);
    }
    _selectedFiles.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedContacts() async {
    for (final contact in _selectedContacts) {
      await deleteContact(contact);
    }
    _selectedContacts.clear();
    notifyListeners();
  }

  void clearSelections() {
    _selectedFiles.clear();
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
