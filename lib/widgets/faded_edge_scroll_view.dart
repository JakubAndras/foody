import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

/// A [SingleChildScrollView] wrapped in a [Stack] with top and bottom
/// gradient fade overlays. Used by the three main tab screens (Dashboard,
/// Progress, Profile) so the scroll-edge appearance can be changed in one
/// place.
///
/// Optionally shows a [collapsedHeader] (e.g. a smaller title) centered at
/// the top when the large title (wrapped in [CollapsibleTitle]) scrolls behind
/// the top fade gradient. This mimics the iOS large-title → inline-title
/// collapse behaviour. A single bool drives both widgets — only one is
/// visible at a time.
///
/// Usage:
/// ```dart
/// FadedEdgeScrollView(
///   collapsedHeader: Text('Title', style: AppTextStyles.title17),
///   child: Column(
///     children: [
///       CollapsibleTitle(child: Text('Title', style: AppTextStyles.h1)),
///       // …rest of content
///     ],
///   ),
/// )
/// ```
class FadedEdgeScrollView extends StatefulWidget {
  const FadedEdgeScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.topFadeHeight = 112.0,
    this.bottomFadeHeight = 120.0,
    this.collapsedHeader,
    this.collapseOffset,
    this.topBlurSigma = 0.0,
    this.topBlurSteps = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final double topFadeHeight;
  final double bottomFadeHeight;

  /// Maximum Gaussian blur sigma at the very top. Set to 0 to disable blur.
  final double topBlurSigma;

  /// Number of stacked blur layers used to create the linear gradient blur.
  /// More steps = smoother transition, but heavier on GPU. 6 is a good default.
  final int topBlurSteps;

  /// Widget shown centered at the top of the screen (below the status bar)
  /// once [CollapsibleTitle] scrolls behind the top fade, or when the scroll
  /// offset exceeds [collapseOffset] (if no [CollapsibleTitle] is used).
  final Widget? collapsedHeader;

  /// Manual fallback: scroll offset at which [collapsedHeader] appears.
  /// Ignored when a [CollapsibleTitle] is present in the scroll content
  /// (automatic measurement takes priority).
  final double? collapseOffset;

  @override
  State<FadedEdgeScrollView> createState() => _FadedEdgeScrollViewState();
}

class _FadedEdgeScrollViewState extends State<FadedEdgeScrollView> {
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
  void didUpdateWidget(FadedEdgeScrollView oldWidget) {
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

  /// Builds stacked blur layers that each cover from y=0 down to a fraction
  /// of [topFadeHeight]. Because layers overlap, blur accumulates — strongest
  /// at the top (all layers overlap) and weakest at the bottom (only one layer).
  List<Widget> _buildTopBlurLayers() {
    final int steps = widget.topBlurSteps;
    final double stepSigma = widget.topBlurSigma / steps;

    // steps - 1 actual layers: fraction goes from 1.0 down to 1/(steps-1),
    // so the very bottom edge of topFadeHeight has 0 blur.
    return List.generate(steps - 1, (i) {
      final double fraction = (steps - 1 - i) / (steps - 1);
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: widget.topFadeHeight * fraction,
        child: IgnorePointer(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: stepSigma, sigmaY: stepSigma),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _effectiveController,
          padding: widget.padding,
          child: widget.child,
        ),
        // Top blur — stacked layers creating a linear blur gradient
        // (strongest at the top, fading to zero at the bottom).
        if (widget.topBlurSigma > 0)
          ..._buildTopBlurLayers(),
        // Top tint gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: widget.topFadeHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background,
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.9),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   child: IgnorePointer(
        //     child: Container(
        //       height: widget.bottomFadeHeight,
        //       decoration: BoxDecoration(
        //         gradient: LinearGradient(
        //           begin: Alignment.bottomCenter,
        //           end: Alignment.topCenter,
        //           colors: [
        //             AppColors.background.withValues(alpha: 0.9),
        //             AppColors.background.withValues(alpha: 0.9),
        //             AppColors.background.withValues(alpha: 0.7),
        //             AppColors.background.withValues(alpha: 0.2),
        //             AppColors.background.withValues(alpha: 0),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

/// Wrap the large title inside a [FadedEdgeScrollView]'s scroll content.
/// Driven by the same bool as the collapsed header — when the collapsed header
/// is visible this widget fades out, and vice versa.
class CollapsibleTitle extends StatelessWidget {
  const CollapsibleTitle({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_FadedEdgeScrollViewState>();
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
