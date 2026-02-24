import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../models/planet_action.dart';

class ShortcutManager {
  static const String _fileName = 'shortcuts.json';

  static Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/OrbitShortcuts";
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('$path/$_fileName');
  }

  static Future<List<PlanetAction>> loadShortcuts() async {
    try {
      final file = await _localFile;

      if (!await file.exists()) {
        await _createDefaultConfig(file);
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);

      return jsonList
          .map((j) => PlanetAction.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("ShortcutManager: Error loading shortcuts: $e");
      return [];
    }
  }

  static Future<void> _createDefaultConfig(File file) async {
    final defaultActions = [
      {
        'icon': 'save',
        'label': 'Save',
        'keys': ['CONTROL', 'S'],
      },
      {
        'icon': 'undo',
        'label': 'Undo',
        'keys': ['CONTROL', 'Z'],
      },
      {
        'icon': 'redo',
        'label': 'Redo',
        'keys': ['CONTROL', 'Y'],
      },
      {
        'icon': 'brush',
        'label': 'Brush',
        'keys': ['B'],
      },
      {
        'icon': 'add',
        'label': 'Bigger',
        'keys': [']'],
      },
      {
        'icon': 'remove',
        'label': 'Smaller',
        'keys': ['['],
      },
    ];

    await file.writeAsString(jsonEncode(defaultActions));
  }

  static Future<bool> importFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final File selectedFile = File(result.files.single.path!);
        final String contents = await selectedFile.readAsString();

        // Basic validation: try to decode it
        jsonDecode(contents);

        final localFile = await _localFile;
        await localFile.writeAsString(contents);
        return true;
      }
    } catch (e) {
      debugPrint("ShortcutManager: Error importing file: $e");
    }
    return false;
  }

  static Future<void> editConfigFile() async {
    final file = await _localFile;
    final Uri uri = Uri.file(file.path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("ShortcutManager: Could not launch $uri");
    }
  }
}
