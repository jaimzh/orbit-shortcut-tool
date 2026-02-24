import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'providers/ui_settings_provider.dart';
import 'utils/constants.dart';
import 'widgets/orbit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(
      AppConstants.baseWindowSize * 1.2,
      AppConstants.baseWindowSize * 1.2,
    ),
    minimumSize: Size(
      AppConstants.minWindowSize * 1.2,
      AppConstants.minWindowSize * 1.2,
    ),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setHasShadow(false);
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => UISettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orbit',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showContextMenu(BuildContext context, Offset position) {
    final settings = context.read<UISettingsProvider>();
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<void>>[
        PopupMenuItem(
          onTap: settings.toggleDarkAssets,
          height: 32,
          child: Center(
            child: Icon(
              settings.isDarkAssets ? Icons.light_mode : Icons.dark_mode,
              size: 18,
            ),
          ),
        ),
        PopupMenuItem(
          onTap: settings.increaseScale,
          height: 32,
          child: const Center(child: Icon(Icons.add, size: 18)),
        ),
        PopupMenuItem(
          onTap: settings.decreaseScale,
          height: 32,
          child: const Center(child: Icon(Icons.remove, size: 18)),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          onTap: () => settings.importShortcuts(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_open, size: 18),
              SizedBox(width: 8),
              Text("Load", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => settings.loadShortcuts(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 18),
              SizedBox(width: 8),
              Text("Reload", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
      elevation: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        onSecondaryTapDown: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.001),
            ),
            const Center(child: Orbit()),
          ],
        ),
      ),
    );
  }
}
