import 'package:flutter/material.dart' hide ShortcutManager;
import 'package:window_manager/window_manager.dart';
import '../utils/constants.dart';
import '../models/planet_action.dart';
import '../utils/shortcut_manager.dart';

class UISettingsProvider extends ChangeNotifier {
  bool _isDarkAssets =
      false; // false = white assets (default), true = dark assets
  double _scale = 1.2;
  List<PlanetAction> _actions = [];

  UISettingsProvider() {
    loadShortcuts();
  }

  bool get isDarkAssets => _isDarkAssets;
  double get scale => _scale;
  List<PlanetAction> get actions => _actions;

  Color get primaryColor => _isDarkAssets ? Colors.black : Colors.white;
  Color get backgroundColor => _isDarkAssets
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.1);

  Future<void> loadShortcuts() async {
    _actions = await ShortcutManager.loadShortcuts();
    notifyListeners();
  }

  Future<void> importShortcuts() async {
    final success = await ShortcutManager.importFromFile();
    if (success) {
      await loadShortcuts();
    }
  }

  Future<void> editShortcuts() async {
    await ShortcutManager.editConfigFile();
  }

  void toggleDarkAssets() {
    _isDarkAssets = !_isDarkAssets;
    notifyListeners();
  }

  void increaseScale() {
    if (_scale < 2.0) {
      _scale += 0.1;
      _updateWindowSize();
      notifyListeners();
    }
  }

  void decreaseScale() {
    if (_scale > 0.5) {
      _scale -= 0.1;
      _updateWindowSize();
      notifyListeners();
    }
  }

  void _updateWindowSize() {
    final double newSize = AppConstants.baseWindowSize * _scale;
    windowManager.setSize(Size(newSize, newSize));
  }
}
