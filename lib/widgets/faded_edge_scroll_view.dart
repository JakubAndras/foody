import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

/// A [SingleChildScrollView] wrapped in a [Stack] with top and bottom
/// gradient fade overlays. Used by the three main tab screens (Dashboard,
/// Progress, Profile) so the scroll-edge appearance can be changed in one
/// place.
class FadedEdgeScrollView extends StatelessWidget {
  const FadedEdgeScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.topFadeHeight = 104.0,
    this.bottomFadeHeight = 120.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final double topFadeHeight;
  final double bottomFadeHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: controller,
          padding: padding,
          child: child,
        ),
        // Top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: topFadeHeight,
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
        // Bottom fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: bottomFadeHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.9),
                    AppColors.background.withValues(alpha: 0.9),
                    AppColors.background.withValues(alpha: 0.7),
                    AppColors.background.withValues(alpha: 0.2),
                    AppColors.background.withValues(alpha: 0),
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
