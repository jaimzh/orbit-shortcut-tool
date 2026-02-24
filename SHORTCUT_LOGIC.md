# Orbit: Shortcut System Architecture & Data Flow

This document outlines how data moves from a JSON file to a physical keyboard event on Windows.

## 📦 Core Technology Stack

- **`win32` & `ffi`**: Responsible for the low-level Windows API integration (simulating keystrokes and window focus).
- **`path_provider`**: Locates the system's "Documents" folder for persistent storage.
- **`file_picker`**: Handles the OS-native file selection dialog for the "Load" feature.
- **`provider`**: Orchestrates state changes, ensuring the UI updates when a new config is loaded.

---

## 🛠 Component Breakdown & Trace Guide

### 1. The Data Model: `PlanetAction` (`lib/models/planet_action.dart`)

This is the "Translator". It takes raw JSON strings and maps them to Flutter/Windows values.

- **Icon Mapping**: Converts a string like `"save"` to `Icons.save`.
- **Key Mapping**: Converts a string like `"CTRL"` to the Windows virtual key code `VK_LCONTROL` (0x11).
- **Trigger**: The `trigger()` method is called by the UI, which then handed off to the execution utility.

### 2. The Librarian: `ShortcutManager` (`lib/utils/shortcut_manager.dart`)

Handles all File I/O operations.

- **Storage**: Manages `shortcuts.json` in `Documents/OrbitShortcuts/`.
- **Default Config**: The `_createDefaultConfig` method contains the hardcoded "first-run" settings.
- **Importing**: Uses `file_picker` to read an external JSON, validates it via `jsonDecode`, and overwrites the local working config.

### 3. The Brain: `UISettingsProvider` (`lib/providers/ui_settings_provider.dart`)

The central hub for app state.

- **`actions` List**: Holds the active list of `PlanetAction` objects.
- **`loadShortcuts()`**: The "Reload" logic. It tells the Librarian to read the file and then calls `notifyListeners()` to redraw the UI.
- **`importShortcuts()`**: The "Load" logic. Coordinates the file picker and the subsequent UI refresh.

### 4. The Executor: `ShortcutUtility` (`lib/utils/shortcut_utility.dart`)

Where the "magic" happens. This class has no state; it only performs actions.

- **`_prepareFocus()`**: Uses `GetForegroundWindow` and `SetForegroundWindow` from `win32` to find the app you were using _before_ you clicked the Orbit and switches focus back to it.
- **`triggerShortcut()`**:
  1. Distinguishes between normal and "Extended" keys (like WIN or Arrows).
  2. Builds a C-style array of `INPUT` structures using `ffi`.
  3. Calls `SendInput` to inject the keystrokes into the Windows input stream.

---

## 🔄 Data Lifecycle (Step-by-Step)

1. **Initialization**:
   - `main.dart` starts `UISettingsProvider`.
   - Provider calls `ShortcutManager.loadShortcuts()`.
   - Librarian checks if `Documents/OrbitShortcuts/shortcuts.json` exists. If not, it writes the defaults.
   - Provider notifies the UI; the `Orbit` widget builds `Planet` widgets for each item.

2. **Triggering a Shortcut**:
   - User clicks a **Planet**.
   - `Planet` widget calls `action.trigger()`.
   - `PlanetAction` calls `ShortcutUtility.triggerShortcut(virtualKeys)`.
   - `ShortcutUtility` minimizes the "stolen focus" by switching back to your previous app.
   - `ShortcutUtility` sends the key-down and key-up signals to Windows.

3. **Loading a New Config**:
   - User selects **Load** from the context menu.
   - `UISettingsProvider` calls `ShortcutManager.importFromFile()`.
   - Librarian opens the `file_picker`.
   - New content is saved to the local `shortcuts.json`.
   - Provider calls `loadShortcuts()` to refresh the internal list and the UI.

---

## 🔍 Code Tracing Tips

If you want to follow the data "hot path":

1. Start at `lib/widgets/orbit.dart` inside the `Planet` class's `onTapUp`.
2. Step into `widget.action.trigger()` in `lib/models/planet_action.dart`.
3. Step into `ShortcutUtility.triggerShortcut()` in `lib/utils/shortcut_utility.dart`.
4. Observe the `debugPrint` statements in your terminal to see the inputs being sent.
