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
    'home': Icons.home,
    'rocket': Icons.rocket_launch,
    'star': Icons.star,
    'refresh': Icons.refresh,
    'edit': Icons.edit,
    'file': Icons.insert_drive_file,
    'folder': Icons.folder,
    'music': Icons.music_note,
    'video': Icons.video_library,
    'image': Icons.image,
  };

  static final Map<String, int> keyNameMap = {
    'CONTROL': VK_LCONTROL,
    'CTRL': VK_LCONTROL,
    'SHIFT': VK_LSHIFT,
    'ALT': VK_LMENU,
    'WIN': VK_LWIN,
    'COMMAND': VK_LWIN,
    'META': VK_LWIN,
    'ENTER': VK_RETURN,
    'SPACE': VK_SPACE,
    'ESCAPE': VK_ESCAPE,
    'BACKSPACE': VK_BACK,
    'TAB': VK_TAB,
    'DELETE': VK_DELETE,
    'INSERT': VK_INSERT,
    'HOME': VK_HOME,
    'END': VK_END,
    'PAGEUP': VK_PRIOR,
    'PAGEDOWN': VK_NEXT,
    'LEFT': VK_LEFT,
    'RIGHT': VK_RIGHT,
    'UP': VK_UP,
    'DOWN': VK_DOWN,
    '[': VK_OEM_4,
    ']': VK_OEM_6,
    ';': VK_OEM_1,
    '\'': VK_OEM_7,
    ',': VK_OEM_COMMA,
    '.': VK_OEM_PERIOD,
    '/': VK_OEM_2,
    '\\': VK_OEM_5,
    '=': VK_OEM_PLUS,
    '-': VK_OEM_MINUS,
    // A-Z
    'A': 0x41, 'B': 0x42, 'C': 0x43, 'D': 0x44, 'E': 0x45, 'F': 0x46,
    'G': 0x47, 'H': 0x48, 'I': 0x49, 'J': 0x4A, 'K': 0x4B, 'L': 0x4C,
    'M': 0x4D, 'N': 0x4E, 'O': 0x4F, 'P': 0x50, 'Q': 0x51, 'R': 0x52,
    'S': 0x53, 'T': 0x54, 'U': 0x55, 'V': 0x56, 'W': 0x57, 'X': 0x58,
    'Y': 0x59, 'Z': 0x5A,
    // Numbers
    '0': 0x30, '1': 0x31, '2': 0x32, '3': 0x33, '4': 0x34,
    '5': 0x35, '6': 0x36, '7': 0x37, '8': 0x38, '9': 0x39,
    // F-Keys
    'F1': VK_F1, 'F2': VK_F2, 'F3': VK_F3, 'F4': VK_F4, 'F5': VK_F5,
    'F6': VK_F6, 'F7': VK_F7, 'F8': VK_F8, 'F9': VK_F9, 'F10': VK_F10,
    'F11': VK_F11, 'F12': VK_F12,
  };
}
