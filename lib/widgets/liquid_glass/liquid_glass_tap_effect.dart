import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Drives the scale animation for a [LiquidGlass] lens config.
///
/// Create with a [TickerProvider] (e.g. from a [TickerProviderStateMixin]),
/// then observe [scale] via a [ValueListenableBuilder] to set animated
/// width / height / position on the lens config.  Call [animate] from the
/// child's tap handler.
///
/// ```dart
/// // In State:
/// late final streakTap = LiquidGlassTapAnimator(vsync: this);
///
/// // In build – observe the scale:
/// ValueListenableBuilder<double>(
///   valueListenable: streakTap.scale,
///   builder: (context, scale, _) => /* width: baseW * scale, ... */,
/// );
///
/// // In child widget – tap handler:
/// onTap: () async {
///   await streakTap.animate();
///   showDialog(...);
/// }
/// ```
class LiquidGlassTapAnimator {
  final double peakScale;
  final ValueNotifier<double> scale;

  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  LiquidGlassTapAnimator({
    required TickerProvider vsync,
    this.peakScale = 1.3,
    Duration forwardDuration = const Duration(milliseconds: 100),
    Duration reverseDuration = const Duration(milliseconds: 100),
  }) : scale = ValueNotifier(1.0) {
    _controller = AnimationController(
      vsync: vsync,
      duration: forwardDuration,
      reverseDuration: reverseDuration,
    );
    _curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    _controller.addListener(() {
      scale.value = lerpDouble(1.0, peakScale, _curved.value)!;
    });
  }

  bool get isAnimating => _controller.isAnimating;

  /// Plays the pop animation (1.0 → [peakScale]).
  /// Returns when the peak is reached so the caller can fire its action.
  /// The settle-back (→ 1.0) runs automatically after.
  Future<void> animate() async {
    if (_controller.isAnimating) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    await _controller.forward();
    _controller.reverse();
  }

  void dispose() {
    _curved.dispose();
    _controller.dispose();
    scale.dispose();
  }
}

/// iOS 26-style pop animation wrapper for regular (non-glass) widgets.
///
/// Scales the [child] from 1.0 → [peakScale] → 1.0 on tap, then fires [onTap].
/// Drop-in replacement for [GestureDetector].
class LiquidGlassTapEffect extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double peakScale;

  const LiquidGlassTapEffect({
    super.key,
    this.onTap,
    required this.child,
    this.peakScale = 1.3,
  });

  @override
  State<LiquidGlassTapEffect> createState() => _LiquidGlassTapEffectState();
}

class _LiquidGlassTapEffectState extends State<LiquidGlassTapEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_controller.isAnimating) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    await _controller.forward();
    if (!mounted) return;
    widget.onTap?.call();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, child) {
          final scale = lerpDouble(1.0, widget.peakScale, _curved.value)!;
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
