import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingSignInModalScreen extends StatelessWidget {
  const OnboardingSignInModalScreen({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: OnboardingSignInSheetContent(
          onClose: onNext,
          onContinue: onNext,
        ),
      ),
    );
  }
}

class OnboardingSignInSheetContent extends StatelessWidget {
  const OnboardingSignInSheetContent({
    super.key,
    this.onClose,
    this.onContinue,
  });

  final VoidCallback? onClose;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.xl + bottomInset,
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
                    onTap: onClose,
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
          const SizedBox(height: AppSpacing.l),
          OnboardingSolidButton(
            label: 'Sign in with Apple',
            onPressed: onContinue,
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOutlinedButton(
            label: 'Sign in with Google',
            leading: SizedBox(
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              child: Image.asset('assets/images/google_icon.png'),
            ),
            onPressed: onContinue,
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOutlinedButton(
            label: 'Continue with email',
            leading: const Icon(CupertinoIcons.mail_solid, color: AppColors.textPrimary, size: AppSizes.iconMd),
            onPressed: onContinue,
          ),
          const SizedBox(height: AppSpacing.l),
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
    );
  }
}
