import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/liquid_glass/liquid_glass_system.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

/// A universal glass-effect container powered by [liquid_glass_easy].
///
/// Child content is always visible. The liquid-glass border glow and
/// refraction overlay once the shader finishes loading (typically one
/// frame). Works in Row, Column, scrollable layouts, or fixed parents.
///
/// ```dart
/// GlassContainer(child: Text('Hello'))
/// GlassContainer.pill(child: Row(children: [Icon(Icons.star), Text('5')]))
/// ```
class GlassContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppLiquidGlassLensConfig lensConfig;
  final AppLiquidGlassViewConfig viewConfig;
  final Color backgroundColor;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.lensConfig = AppLiquidGlassPresets.cardLens,
    this.viewConfig = AppLiquidGlassPresets.snapshot,
    this.backgroundColor = AppColors.backgroundAlt,
    this.width,
    this.height,
  });

  /// Pill-shaped glass container — great for indicators, badges, chips.
  const GlassContainer.pill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xxs),
    this.lensConfig = AppLiquidGlassPresets.mainTabBarLens,
    this.viewConfig = AppLiquidGlassPresets.snapshot,
    this.backgroundColor = AppColors.backgroundAlt,
    this.width,
    this.height,
  });

  /// Stronger glass — higher blur, more prominent border. Good for overlays / sheets.
  const GlassContainer.prominent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.lensConfig = AppLiquidGlassPresets.scanTipLens,
    this.viewConfig = AppLiquidGlassPresets.snapshot,
    this.backgroundColor = AppColors.backgroundAlt,
    this.width,
    this.height,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  final _measureKey = GlobalKey();
  Size? _measuredSize;
  bool _didSchedule = false;

  double get _cornerRadius => widget.lensConfig.shape is RoundedRectangleShape ? (widget.lensConfig.shape as RoundedRectangleShape).cornerRadius : 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Resolve width: explicit > bounded constraints > measured
      double? width = widget.width;
      if (width == null && constraints.maxWidth != double.infinity) {
        width = constraints.maxWidth;
      }
      width ??= _measuredSize?.width;

      // Resolve height: explicit > bounded constraints > measured
      double? height = widget.height;
      if (height == null && constraints.maxHeight != double.infinity) {
        height = constraints.maxHeight;
      }
      height ??= _measuredSize?.height;

      if (width != null && height != null) {
        return _buildGlass(width, height);
      }

      // First frame(s): render plain content to measure size
      _scheduleMeasure();
      return _buildContent(key: _measureKey);
    });
  }

  void _scheduleMeasure() {
    if (_didSchedule) return;
    _didSchedule = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _didSchedule = false;
      final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && mounted) {
        final size = box.size;
        if (size != _measuredSize) {
          setState(() => _measuredSize = size);
        }
      }
    });
  }

  /// Always-visible content container — same visual shape as the glass version.
  Widget _buildContent({Key? key}) {
    return Container(
      key: key,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: AppColors.border, width: widget.lensConfig.shape.borderWidth),
      ),
      child: widget.child,
    );
  }

  /// Content is always visible at the bottom of the Stack.
  /// Glass border / refraction overlays on top once shaders are ready.
  Widget _buildGlass(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Always-visible content (bottom layer)
          Positioned.fill(child: _buildContent()),
          // Glass overlay — border glow, refraction, chromatic aberration
          // Uses transparent background so the content below shows through
          // until the lens child renders (after shader loads).
          Positioned.fill(
            child: IgnorePointer(
              child: AppLiquidGlassLayer(
                viewConfig: widget.viewConfig,
                backgroundWidget: ColoredBox(color: widget.backgroundColor),
                children: [
                  widget.lensConfig.build(
                    width: width,
                    height: height,
                    position: const LiquidGlassOffsetPosition(left: 0, top: 0),
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
