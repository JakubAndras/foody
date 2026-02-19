import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingLoadingPlanScreen extends StatefulWidget {
  const OnboardingLoadingPlanScreen({
    super.key,
    required this.onNext,
    required this.step,
    required this.totalSteps,
  });

  final VoidCallback onNext;
  final int step;
  final int totalSteps;

  @override
  State<OnboardingLoadingPlanScreen> createState() => _OnboardingLoadingPlanScreenState();
}

class _OnboardingLoadingPlanScreenState extends State<OnboardingLoadingPlanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _didMoveNext = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _moveNextOnce();
        }
      })
      ..forward();
  }

  void _moveNextOnce() {
    if (_didMoveNext) {
      return;
    }
    _didMoveNext = true;
    widget.onNext();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _progressController,
          builder: (context, _) {
            final double progress = _progressController.value.clamp(0, 1);
            final int percent = (progress * 100).round();

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _moveNextOnce,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Center(
                      child: Text('$percent%', style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Center(
                      child: Text(
                        "We're setting everything\nup for you",
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Container(
                        height: AppSizes.progressBarHeight,
                        color: AppColors.border,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppGradients.loading,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Center(
                      child: Text(
                        'Estimating your metabolic age...',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Daily recommendation for', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.s),
                    _Bullet(text: 'Calories'),
                    _Bullet(text: 'Carbs'),
                    _Bullet(text: 'Protein'),
                    _Bullet(text: 'Fats'),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text('•', style: style),
          const SizedBox(width: AppSpacing.s),
          Text(text, style: style),
        ],
      ),
    );
  }
}
