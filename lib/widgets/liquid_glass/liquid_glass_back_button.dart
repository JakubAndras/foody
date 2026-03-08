import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

enum LiquidGlassBackButtonIcon { back, close }

class LiquidGlassBackButton extends StatefulWidget {
  final VoidCallback? onTap;
  final LiquidGlassBackButtonIcon icon;
  final double size;
  final Color? iconColor;

  const LiquidGlassBackButton({
    super.key,
    this.onTap,
    this.icon = LiquidGlassBackButtonIcon.back,
    this.size = AppSizes.backButtonSize,
    this.iconColor,
  });

  const LiquidGlassBackButton.back({
    super.key,
    this.onTap,
    this.size = AppSizes.backButtonSize,
    this.iconColor,
  }) : icon = LiquidGlassBackButtonIcon.back;

  const LiquidGlassBackButton.close({
    super.key,
    this.onTap,
    this.size = AppSizes.backButtonSize,
    this.iconColor,
  }) : icon = LiquidGlassBackButtonIcon.close;

  @override
  State<LiquidGlassBackButton> createState() => _LiquidGlassBackButtonState();
}

class _LiquidGlassBackButtonState extends State<LiquidGlassBackButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _overlayOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut, reverseCurve: Curves.easeOutCubic),
    );
    _overlayOpacity = Tween<double>(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut, reverseCurve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppColors.textPrimary;
    final iconSize = widget.size * 0.45;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedBuilder(
                animation: _overlayOpacity,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GlassButtonPainter(pressOverlay: _overlayOpacity.value),
                    child: Center(
                      child: widget.icon == LiquidGlassBackButtonIcon.back
                          ? Icon(Icons.arrow_back_ios_new_rounded, size: iconSize, color: iconColor)
                          : Icon(Icons.close_rounded, size: iconSize, color: iconColor),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassButtonPainter extends CustomPainter {
  final double pressOverlay;

  _GlassButtonPainter({required this.pressOverlay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glass fill
    final fillPaint = Paint()..color = const Color(0x50FFFFFF);
    canvas.drawCircle(center, radius, fillPaint);

    // Press overlay
    if (pressOverlay > 0) {
      final pressPaint = Paint()..color = Color.fromRGBO(0, 0, 0, pressOverlay);
      canvas.drawCircle(center, radius, pressPaint);
    }

    // Specular highlight arc at the top
    final highlightRect = Rect.fromLTWH(size.width * 0.15, -radius * 0.35, size.width * 0.7, size.height * 0.7);
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x40FFFFFF),
          const Color(0x00FFFFFF),
        ],
      ).createShader(highlightRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawOval(highlightRect, highlightPaint);

    // Subtle border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0x50FFFFFF),
          const Color(0x18FFFFFF),
          const Color(0x08FFFFFF),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 0.4, borderPaint);
  }

  @override
  bool shouldRepaint(_GlassButtonPainter oldDelegate) => oldDelegate.pressOverlay != pressOverlay;
}
