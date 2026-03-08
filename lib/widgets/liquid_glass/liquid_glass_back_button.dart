import 'dart:math' as math;
import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum LiquidGlassBackButtonIcon { back, close }

class LiquidGlassBackButton extends StatefulWidget {
  final VoidCallback? onTap;
  final LiquidGlassBackButtonIcon icon;
  final double size;
  final Color? iconColor;

  const LiquidGlassBackButton({super.key, this.onTap, this.icon = LiquidGlassBackButtonIcon.back, this.size = AppSizes.backButtonSize, this.iconColor});

  const LiquidGlassBackButton.back({super.key, this.onTap, this.size = AppSizes.backButtonSize, this.iconColor}) : icon = LiquidGlassBackButtonIcon.back;

  const LiquidGlassBackButton.close({super.key, this.onTap, this.size = AppSizes.backButtonSize, this.iconColor}) : icon = LiquidGlassBackButtonIcon.close;

  @override
  State<LiquidGlassBackButton> createState() => _LiquidGlassBackButtonState();
}

class _LiquidGlassBackButtonState extends State<LiquidGlassBackButton> with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final AnimationController _glintController;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 160), reverseDuration: const Duration(milliseconds: 260));
    _glintController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _ambientController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glintController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
    _glintController.forward(from: 0);
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    _pressController.reverse();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppColors.textPrimary;
    final iconSize = widget.size * 0.45;
    final semanticLabel = widget.icon == LiquidGlassBackButtonIcon.back ? 'Back' : 'Close';
    final animation = Listenable.merge([_pressController, _glintController, _ambientController]);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final press = Curves.easeOutCubic.transform(_pressController.value);
        final ambient = Curves.easeInOutSine.transform(_ambientController.value);
        final glint = Curves.easeOutCubic.transform(_glintController.value);
        final scale = lerpDouble(1.0, 0.94, press)!;
        final translateY = lerpDouble(0.0, 1.6, press)!;
        final blurSigma = lerpDouble(16.0, 12.0, press)!;
        final shadowOpacity = lerpDouble(0.14, 0.08, press)!;
        final glowOpacity = lerpDouble(0.14, 0.22, ambient)!;
        final iconTint = Color.lerp(iconColor, Colors.white, 0.12 * press) ?? iconColor;

        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Semantics(
              button: true,
              label: semanticLabel,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: shadowOpacity),
                            blurRadius: lerpDouble(18, 12, press)!,
                            spreadRadius: -5,
                            offset: Offset(0, lerpDouble(10, 6, press)!),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: glowOpacity * (1 - press * 0.55)),
                            blurRadius: lerpDouble(12, 8, press)!,
                            spreadRadius: -6,
                            offset: const Offset(-1.5, -2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                          child: CustomPaint(
                            painter: _GlassButtonPainter(pressProgress: press, ambientProgress: ambient, glintProgress: glint),
                            child: Center(
                              child: Transform.translate(
                                offset: Offset(widget.icon == LiquidGlassBackButtonIcon.back ? -0.55 * press : 0, 0.35 * press),
                                child: Transform.scale(
                                  scale: lerpDouble(1.0, 0.97, press)!,
                                  child: Icon(
                                    widget.icon == LiquidGlassBackButtonIcon.back ? Icons.arrow_back_ios_new_rounded : Icons.close_rounded,
                                    size: iconSize,
                                    color: iconTint,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassButtonPainter extends CustomPainter {
  final double pressProgress;
  final double ambientProgress;
  final double glintProgress;

  _GlassButtonPainter({required this.pressProgress, required this.ambientProgress, required this.glintProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Offset.zero & size;

    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(lerpDouble(-0.45, 0.18, ambientProgress)!, lerpDouble(-0.58, -0.12, pressProgress)!),
        radius: 1.2,
        colors: [
          Color.lerp(const Color(0xAAFFFFFF), const Color(0xCCFFFFFF), pressProgress)!,
          Color.lerp(const Color(0x52FFFFFF), const Color(0x42FFFFFF), pressProgress)!,
          const Color(0x1AF6FBFF),
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, fillPaint);

    final tintPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.16 + ambientProgress * 0.06),
          const Color(0x10FFFFFF),
          const Color(0x1ADBE9F5),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, tintPaint);

    final ambientGlowRect = Rect.fromCenter(
      center: Offset(lerpDouble(size.width * 0.3, size.width * 0.72, ambientProgress)!, lerpDouble(size.height * 0.26, size.height * 0.38, ambientProgress)!),
      width: size.width * 0.68,
      height: size.height * 0.38,
    );
    final ambientGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.22 + (1 - pressProgress) * 0.06),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(ambientGlowRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(ambientGlowRect, ambientGlowPaint);

    final topHighlightRect = Rect.fromLTWH(size.width * 0.08, -size.height * 0.12, size.width * 0.84, size.height * 0.58);
    final topHighlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.34 + (1 - pressProgress) * 0.1),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(topHighlightRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(topHighlightRect, topHighlightPaint);

    final bottomShadePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.8),
        radius: 0.95,
        colors: [
          Colors.black.withValues(alpha: 0),
          Colors.black.withValues(alpha: 0.08 + pressProgress * 0.08),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, bottomShadePaint);

    _paintGlint(canvas, size);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.72),
          Colors.white.withValues(alpha: 0.18 + ambientProgress * 0.06),
          Colors.white.withValues(alpha: 0.08),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius - 0.4, borderPaint);

    final innerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.04),
          Colors.black.withValues(alpha: 0.08 + pressProgress * 0.04),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius - 1.5, innerBorderPaint);

    final baseArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.black.withValues(alpha: 0.08 + pressProgress * 0.05)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 1.2), math.pi * 0.18, math.pi * 0.64, false, baseArcPaint);
  }

  void _paintGlint(Canvas canvas, Size size) {
    if (glintProgress <= 0 || glintProgress >= 1) return;

    final envelope = math.sin(glintProgress * math.pi).clamp(0.0, 1.0);
    final glintCenter = Offset(lerpDouble(-size.width * 0.18, size.width * 1.18, glintProgress)!, lerpDouble(size.height * 0.1, size.height * 0.9, glintProgress)!);

    canvas.save();
    canvas.translate(glintCenter.dx, glintCenter.dy);
    canvas.rotate(-math.pi / 4.6);

    final glintRect = Rect.fromCenter(center: Offset.zero, width: size.width * 0.34, height: size.height * 1.7);
    final glintPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.22 * envelope),
          Colors.white.withValues(alpha: 0.7 * envelope),
          Colors.white.withValues(alpha: 0.18 * envelope),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
      ).createShader(glintRect)
      ..blendMode = BlendMode.screen
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(glintRect, glintPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassButtonPainter oldDelegate) {
    return oldDelegate.pressProgress != pressProgress || oldDelegate.ambientProgress != ambientProgress || oldDelegate.glintProgress != glintProgress;
  }
}
