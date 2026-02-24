import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbit_shortcut_tool/models/planet_action.dart';
import 'package:orbit_shortcut_tool/providers/ui_settings_provider.dart';
import 'package:orbit_shortcut_tool/utils/constants.dart';

class Orbit extends StatefulWidget {
  final double size;
  final double radius;

  const Orbit({
    super.key,
    this.size = AppConstants.baseOrbitSize,
    this.radius = AppConstants.baseOrbitRadius,
  });

  @override
  State<Orbit> createState() => _OrbitState();
}

class _OrbitState extends State<Orbit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool isOpen = false;
  bool isOrbHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.toggleDurationMs),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  void toggle() {
    if (isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    isOpen = !isOpen;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UISettingsProvider>();
    final double scale = settings.scale;
    final double currentSize = widget.size * scale;
    final double currentRadius = widget.radius * scale;
    final Color primaryColor = settings.primaryColor;

    return SizedBox(
      width: currentSize,
      height: currentSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Generate Planets from PlanetActions
          ...settings.actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            // Spacing items equally, but starting from the TOP (-pi/2)
            // for perfect symmetry with any number of items
            final totalActions = settings.actions.isEmpty
                ? 1
                : settings.actions.length;
            final angle = (2 * pi / totalActions) * index - (pi / 2);

            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final distance = currentRadius * _animation.value;
                final offset = Offset(
                  cos(angle) * distance,
                  sin(angle) * distance,
                );

                return Transform.translate(
                  offset: offset,
                  child: Opacity(opacity: _animation.value, child: child),
                );
              },
              child: Planet(action: action),
            );
          }),

          // Center Orbit Orb (The trigger button)
          MouseRegion(
            onEnter: (_) => setState(() => isOrbHovering = true),
            onExit: (_) => setState(() => isOrbHovering = false),
            child: GestureDetector(
              onTap: toggle,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: AppConstants.labelFadeDurationMs,
                ),
                width:
                    (isOrbHovering
                        ? AppConstants.hoverTriggerSize
                        : AppConstants.baseTriggerSize) *
                    scale,
                height:
                    (isOrbHovering
                        ? AppConstants.hoverTriggerSize
                        : AppConstants.baseTriggerSize) *
                    scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(
                    alpha: isOrbHovering ? 0.15 : 0.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: isOrbHovering ? 0.15 : 0.08,
                      ),
                      blurRadius: (isOrbHovering ? 12 : 8) * scale,
                      spreadRadius: (isOrbHovering ? 2 : 1) * scale,
                    ),
                  ],
                  border: Border.all(
                    color: primaryColor.withValues(
                      alpha: isOrbHovering ? 0.5 : 0.3,
                    ),
                    width: (isOrbHovering ? 2.0 : 1.5) * scale,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.public,
                    color: primaryColor.withValues(
                      alpha: isOrbHovering ? 1.0 : 0.8,
                    ),
                    size:
                        (isOrbHovering
                            ? AppConstants.hoverTriggerIconSize
                            : AppConstants.baseTriggerIconSize) *
                        scale,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Planet extends StatefulWidget {
  final PlanetAction action;
  final double iconSize;

  const Planet({
    super.key,
    required this.action,
    this.iconSize = AppConstants.basePlanetSize,
  });

  @override
  State<Planet> createState() => _PlanetState();
}

class _PlanetState extends State<Planet> {
  bool isHovering = false;
  bool isPressed = false;
  bool showLabel = false;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  void _startHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(
      const Duration(milliseconds: AppConstants.labelHoverDelayMs),
      () {
        if (mounted && isHovering) {
          setState(() => showLabel = true);
        }
      },
    );
  }

  void _hideLabel() {
    _hoverTimer?.cancel();
    setState(() {
      isHovering = false;
      isPressed = false;
      showLabel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<UISettingsProvider>();
    final double scale = settings.scale;
    final Color primaryColor = settings.primaryColor;
    final double currentIconSize = widget.iconSize * scale;

    return MouseRegion(
      onEnter: (_) {
        setState(() => isHovering = true);
        _startHoverTimer();
      },
      onExit: (_) => _hideLabel(),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) {
          setState(() => isPressed = false);
          debugPrint("Planet tapped: ${widget.action.label}");
          widget.action.trigger();
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // The Icon Orb - This is the anchor point at (0,0)
            AnimatedContainer(
              duration: const Duration(
                milliseconds: AppConstants.hoverDurationMs,
              ),
              curve: Curves.easeOutCubic,
              width: currentIconSize,
              height: currentIconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(
                  alpha: isPressed ? 0.3 : (isHovering ? 0.2 : 0.08),
                ),
                boxShadow: isHovering || isPressed
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.1),
                          blurRadius: 10 * scale,
                          spreadRadius: 1 * scale,
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: primaryColor.withValues(
                    alpha: isHovering ? 0.4 : 0.15,
                  ),
                  width: 1.2 * scale,
                ),
              ),
              child: Center(
                child: Icon(
                  widget.action.icon,
                  color: primaryColor.withValues(alpha: isHovering ? 1.0 : 0.9),
                  size:
                      (isHovering
                          ? AppConstants.hoverPlanetIconSize
                          : AppConstants.basePlanetIconSize) *
                      scale,
                ),
              ),
            ),
            // The Label - Positioned absolutely relative to the center
            Positioned(
              top: currentIconSize + AppConstants.labelTopOffset,
              child: AnimatedOpacity(
                duration: const Duration(
                  milliseconds: AppConstants.labelFadeDurationMs,
                ),
                opacity: showLabel ? 1.0 : 0.0,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(
                    milliseconds: AppConstants.hoverDurationMs,
                  ),
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 1.0),
                    fontSize: AppConstants.labelFontSize * scale,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(
                        color: settings.isDarkAssets
                            ? Colors.white24
                            : Colors.black26,
                        offset: const Offset(0, 1),
                        blurRadius: 2 * scale,
                      ),
                    ],
                  ),
                  child: Text(widget.action.label, textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
