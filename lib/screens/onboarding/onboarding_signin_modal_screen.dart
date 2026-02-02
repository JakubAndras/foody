import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingSignInModalScreen extends StatelessWidget {
  const OnboardingSignInModalScreen({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: AppColors.overlayDark),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: const OnboardingLanguageChip(label: 'EN'),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.xl),
                    topRight: Radius.circular(AppRadii.xl),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: AppSizes.iconXl),
                        Text(
                          'Sign In',
                          style: textTheme.headlineMedium,
                        ),
                        SizedBox(
                          width: AppSizes.iconXl,
                          height: AppSizes.iconXl,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                              onTap: onNext,
                              child: const Icon(
                                CupertinoIcons.xmark,
                                size: AppSizes.iconMd,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OnboardingSolidButton(
                      label: 'Sign in with Apple',
                      //leading: const Icon(CupertinoIcons.apple_logo, color: AppColors.onPrimary, size: AppSizes.iconMd),
                      onPressed: onNext,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OnboardingOutlinedButton(
                      label: 'Sign in with Google',
                      leading: const OnboardingGoogleMark(),
                      onPressed: onNext,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OnboardingOutlinedButton(
                      label: 'Continue with email',
                      leading: const Icon(CupertinoIcons.mail_solid, color: AppColors.textPrimary, size: AppSizes.iconMd),
                      onPressed: onNext,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text.rich(
                      TextSpan(
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        children: [
                          const TextSpan(text: "By continuing you agree to app's "),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textMuted,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textMuted,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
