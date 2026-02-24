import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:flutter/foundation.dart';
import '../utils/shortcut_utility.dart';

class PlanetAction {
  final IconData icon;
  final String label;
  final List<int>? virtualKeys;
  final VoidCallback? onTap;

  PlanetAction({
    required this.icon,
    required this.label,
    this.virtualKeys,
    this.onTap,
  });

  factory PlanetAction.fromJson(Map<String, dynamic> json) {
    return PlanetAction(
      icon: _parseIcon(json['icon'] as String),
      label: json['label'] as String,
      virtualKeys: (json['keys'] as List<dynamic>?)
          ?.map((k) => _parseKey(k))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': iconNameMap.entries.firstWhere((e) => e.value == icon).key,
      'label': label,
      'keys': virtualKeys,
    };
  }

  Future<void> trigger() async {
    if (onTap != null) {
      onTap!();
    }
    if (virtualKeys != null) {
      debugPrint("PlanetAction: Triggering shortcut for $label...");
      await ShortcutUtility.triggerShortcut(virtualKeys!);
    }
  }

  static IconData _parseIcon(String name) {
    return iconNameMap[name.toLowerCase()] ?? Icons.help_outline;
  }

  static int _parseKey(dynamic key) {
    if (key is int) return key;
    if (key is String) {
      return keyNameMap[key.toUpperCase()] ?? 0;
    }
    return 0;
  }

  static final Map<String, IconData> iconNameMap = {
    'save': Icons.save,
    'undo': Icons.undo,
    'redo': Icons.redo,
    'brush': Icons.brush,
    'add': Icons.add,
    'remove': Icons.remove,
    'search': Icons.search,
    'settings': Icons.settings,
    'delete': Icons.delete,
    'copy': Icons.content_copy,
    'paste': Icons.content_paste,
    'cut': Icons.content_cut,
    'public': Icons.public,
  };

  static final Map<String, int> keyNameMap = {
    'CONTROL': VK_LCONTROL,
    'SHIFT': VK_LSHIFT,
    'ALT': VK_LMENU,
    'S': 0x53,
    'Z': 0x5A,
    'Y': 0x59,
    'B': 0x42,
    '[': VK_OEM_4,
    ']': VK_OEM_6,
    'ENTER': VK_RETURN,
    'SPACE': VK_SPACE,
    'ESCAPE': VK_ESCAPE,
  };
}
