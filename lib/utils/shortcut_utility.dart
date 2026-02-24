import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter/foundation.dart';

class ShortcutUtility {
  /// Sends a sequence of virtual keys as "KeyDown" and then "KeyUp" in reverse order.
  /// For example, [VK_LCONTROL, VK_S] will result in:
  /// Ctrl Down, S Down, S Up, Ctrl Up.
  static Future<void> triggerShortcut(List<int> virtualKeys) async {
    if (virtualKeys.isEmpty) return;

    // 1. Prepare focus - switch back to the previous window
    _prepareFocus();

    // 2. Small delay to allow focus transition
    await Future.delayed(const Duration(milliseconds: 100));

    // 3. Prepare SendInput data
    final inputCount = virtualKeys.length * 2;
    final inputs = calloc<INPUT>(inputCount);

    try {
      for (var i = 0; i < virtualKeys.length; i++) {
        final vk = virtualKeys[i];
        final isExtended = _isExtendedKey(vk);

        // Key Down
        final keyDown = inputs[i];
        keyDown.type = INPUT_KEYBOARD;
        keyDown.ki.wVk = vk;
        keyDown.ki.dwFlags = isExtended ? KEYEVENTF_EXTENDEDKEY : 0;

        // Key Up (LIFO for modifiers)
        final upIndex = inputCount - 1 - i;
        final keyUp = inputs[upIndex];
        keyUp.type = INPUT_KEYBOARD;
        keyUp.ki.wVk = vk;
        keyUp.ki.dwFlags =
            KEYEVENTF_KEYUP | (isExtended ? KEYEVENTF_EXTENDEDKEY : 0);
      }

      // 4. Send the input
      final result = SendInput(inputCount, inputs, sizeOf<INPUT>());
      debugPrint("ShortcutUtility: Sent $inputCount inputs, result: $result");

      if (result != inputCount) {
        debugPrint(
          "ShortcutUtility: Warning - Not all inputs were sent! (Error: ${GetLastError()})",
        );
      }
    } finally {
      free(inputs);
    }
  }

  /// Switches focus to the next window in the Z-order (the one that was likely active before us).
  static void _prepareFocus() {
    final currentHwnd = GetForegroundWindow();

    // Attempt to find the previous window in Z-order that is a "real" window
    var nextHwnd = GetWindow(currentHwnd, GW_HWNDNEXT);

    while (nextHwnd != 0) {
      if (IsWindowVisible(nextHwnd) != 0) {
        // Skip common phantom windows or our own window
        final length = GetWindowTextLength(nextHwnd);
        if (length > 0) {
          debugPrint("ShortcutUtility: Switching focus to HWND $nextHwnd");

          // Use a combination of SetForegroundWindow and SetFocus
          SetForegroundWindow(nextHwnd);
          SetActiveWindow(nextHwnd);
          return;
        }
      }
      nextHwnd = GetWindow(nextHwnd, GW_HWNDNEXT);
    }

    debugPrint("ShortcutUtility: Could not find a suitable window to focus.");
  }

  static bool _isExtendedKey(int vk) {
    return (vk >= VK_PRIOR &&
            vk <=
                VK_DOWN) || // PageUp, PageDown, End, Home, Left, Up, Right, Down
        (vk >= VK_INSERT && vk <= VK_DELETE) || // Insert, Delete
        vk == VK_LWIN ||
        vk == VK_RWIN ||
        vk == VK_RMENU ||
        vk == VK_RCONTROL ||
        vk == VK_DIVIDE ||
        vk == VK_NUMLOCK;
  }
}
