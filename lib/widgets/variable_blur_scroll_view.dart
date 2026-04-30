import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';
import 'package:variable_blur/variable_blur.dart';

/// A performant alternative to [FadedEdgeScrollView] that uses the
/// `variable_blur` package (GPU fragment shader) instead of stacking
/// multiple [BackdropFilter] layers.
///
/// Provides the same API surface: top blur region, bottom tint gradient,
/// collapsible header driven by scroll position.
class VariableBlurScrollView extends StatefulWidget {
  const VariableBlurScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.topFadeHeight = 112.0,
    this.bottomFadeHeight = 120.0,
    this.collapsedHeader,
    this.collapseOffset,
    this.topBlurSigma = 0.0,
    this.blurQuality = BlurQuality.medium,
    this.edgeIntensity = 0.06,
    this.topBlurHeight = 0.09,
    this.backgroundColor,
    this.fadeColor,
    this.backgroundWidget,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final double topFadeHeight;
  final double bottomFadeHeight;
  final double topBlurHeight;

  /// Background color for the scroll content area.
  /// Defaults to [AppColors.background]. Set to [Colors.transparent]
  /// when using a [backgroundWidget].
  final Color? backgroundColor;

  /// Color used for the bottom fade-out gradient. Defaults to
  /// [backgroundColor]. When using a transparent content background
  /// over a mesh gradient, set this to [AppColors.meshBase] to avoid
  /// black shadow artifacts.
  final Color? fadeColor;

  /// Optional background widget (e.g. [MeshGradientBackground]) placed
  /// behind the scroll content but inside the blur shader, so the blur
  /// operates on the correct colours.
  final Widget? backgroundWidget;

  /// Maximum Gaussian blur sigma at the very top. Set to 0 to disable blur.
  final double topBlurSigma;

  /// Quality level for the GPU blur shader. Lower = faster.
  final BlurQuality blurQuality;

  /// Controls the smoothness of the blur edge transition (0.0–1.0).
  final double edgeIntensity;

  /// Widget shown centered at the top once [CollapsibleTitleV] scrolls behind
  /// the top fade, or when the scroll offset exceeds [collapseOffset].
  final Widget? collapsedHeader;

  /// Manual fallback: scroll offset at which [collapsedHeader] appears.
  /// Ignored when a [CollapsibleTitleV] is present in the scroll content.
  final double? collapseOffset;

  @override
  State<VariableBlurScrollView> createState() => _VariableBlurScrollViewState();
}

class _VariableBlurScrollViewState extends State<VariableBlurScrollView> {
  final GlobalKey _titleKey = GlobalKey();
  final ValueNotifier<bool> _collapsed = ValueNotifier<bool>(false);
  ScrollController? _ownController;

  ScrollController get _effectiveController => widget.controller ?? (_ownController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    if (widget.collapsedHeader != null) {
      _effectiveController.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(VariableBlurScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      _ownController?.removeListener(_onScroll);
      if (widget.collapsedHeader != null) {
        _effectiveController.addListener(_onScroll);
      }
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onScroll);
    _ownController?.dispose();
    _collapsed.dispose();
    super.dispose();
  }

  void _onScroll() {
    bool shouldCollapse;

    final titleContext = _titleKey.currentContext;
    if (titleContext != null) {
      final RenderBox? titleBox = titleContext.findRenderObject() as RenderBox?;
      final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
      if (titleBox == null || !titleBox.attached || stackBox == null || !stackBox.attached) return;

      final titlePos = titleBox.localToGlobal(Offset.zero, ancestor: stackBox);
      final titleBottom = titlePos.dy + titleBox.size.height;
      shouldCollapse = titleBottom <= widget.topFadeHeight * 0.9;
    } else if (widget.collapseOffset != null) {
      shouldCollapse = _effectiveController.offset >= widget.collapseOffset!;
    } else {
      return;
    }

    if (shouldCollapse != _collapsed.value) {
      _collapsed.value = shouldCollapse;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final useBlur = widget.topBlurSigma > 0;

    final bgColor = widget.backgroundColor ?? AppColors.background;
    final fade = widget.fadeColor ?? bgColor;

    final isTransparent = bgColor == Colors.transparent || bgColor.a == 0;

    Widget scrollView = SingleChildScrollView(
      controller: _effectiveController,
      padding: widget.padding,
      child: widget.child,
    );

    // When content is transparent, place backgroundWidget (e.g. mesh gradient)
    // behind the scroll view so the blur shader has correct pixels to work with.
    Widget scrollContent;
    if (isTransparent && widget.backgroundWidget != null) {
      scrollContent = Stack(children: [widget.backgroundWidget!, scrollView]);
    } else if (isTransparent) {
      scrollContent = scrollView;
    } else {
      scrollContent = Container(color: bgColor, child: scrollView);
    }

    return Stack(
      children: [
        // Main scroll content — optionally wrapped in VariableBlur
        if (useBlur)
          VariableBlur(
            sigma: 8,
            blurSides: BlurSides.vertical(top: widget.topBlurHeight), // ResponsiveBlurSides.vertical(top: 200.0),
            edgeIntensity: widget.edgeIntensity,
            isYFlipNeed: false,
            child: scrollContent,
          )
        else
          scrollContent,
        // Collapsed header
        if (widget.collapsedHeader != null)
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: ValueListenableBuilder<bool>(
                valueListenable: _collapsed,
                builder: (context, collapsed, child) {
                  return AnimatedOpacity(
                    opacity: collapsed ? 1.0 : 0.0,
                    duration: AppTheme.transitionDuration,
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(top: topPadding),
                  height: topPadding + AppSizes.navItemHeight,
                  alignment: Alignment.center,
                  child: widget.collapsedHeader!,
                ),
              ),
            ),
          ),
        // Bottom fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: widget.bottomFadeHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    fade.withValues(alpha: 0.8),
                    fade.withValues(alpha: 0.8),
                    fade.withValues(alpha: 0.6),
                    fade.withValues(alpha: 0.3),
                    fade.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Wrap the large title inside a [VariableBlurScrollView]'s scroll content.
/// Counterpart of [CollapsibleTitle] for the variable-blur variant.
class CollapsibleTitleV extends StatelessWidget {
  const CollapsibleTitleV({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_VariableBlurScrollViewState>();
    if (state == null) return child;

    return KeyedSubtree(
      key: state._titleKey,
      child: ValueListenableBuilder<bool>(
        valueListenable: state._collapsed,
        builder: (context, collapsed, child) {
          return AnimatedOpacity(
            opacity: collapsed ? 0.0 : 1.0,
            duration: AppTheme.transitionDuration,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
