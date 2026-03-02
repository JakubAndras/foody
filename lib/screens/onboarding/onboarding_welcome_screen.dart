import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/onboarding/onboarding_signin_modal_screen.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key, this.onNext, this.onSkip});

  final VoidCallback? onNext;
  final Future<void> Function()? onSkip;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Positioned(
            //   top: AppSpacing.md,
            //   right: AppSpacing.md,
            //   child: const OnboardingLanguageChip(label: 'EN'),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    tr(LocaleKeys.onboarding_welcome_title),
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(height: 1.25),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  OnboardingPrimaryButton(
                    label: tr(LocaleKeys.onboarding_get_started),
                    onPressed: onNext,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  OnboardingOutlinedButton(
                    label: tr(LocaleKeys.onboarding_skip_onboarding),
                    onPressed: onSkip == null
                        ? null
                        : () async {
                            await onSkip!.call();
                          },
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        tr(LocaleKeys.onboarding_already_have_account),
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                      ),
                      InkWell(
                        onTap: () => _showSignInModal(context),
                        child: Text(
                          tr(LocaleKeys.onboarding_sign_in),
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayDark40,
      builder: (context) => OnboardingSignInSheetContent(
        onClose: () => Navigator.of(context).pop(),
        onContinue: () {
          Navigator.of(context).pop();
          onNext?.call();
        },
      ),
    );
  }
}
