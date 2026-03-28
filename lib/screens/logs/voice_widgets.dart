import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class VoiceLogIconButton extends StatelessWidget {
  const VoiceLogIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: AppShadows.control),
        child: Icon(icon, color: AppColors.textPrimary, size: AppSizes.iconMd),
      ),
    );
  }
}

class VoiceLogToggle extends StatelessWidget {
  const VoiceLogToggle({super.key, required this.isExercise, required this.onSelectMeals, required this.onSelectExercise});

  final bool isExercise;
  final VoidCallback onSelectMeals;
  final VoidCallback onSelectExercise;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onSelectMeals,
          child: Text(
            tr(LocaleKeys.common_meals),
            style: AppTextStyles.title18.copyWith(color: isExercise ? AppColors.textMutedLight : AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        GestureDetector(
          onTap: isExercise ? onSelectMeals : onSelectExercise,
          child: Container(
            width: AppSizes.voiceToggleWidth,
            height: AppSizes.voiceToggleHeight,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: isExercise ? AppGradients.askAiPrimary : AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Align(
              alignment: isExercise ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: AppSizes.voiceToggleKnob,
                height: AppSizes.voiceToggleKnob,
                decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: AppShadows.control),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        GestureDetector(
          onTap: onSelectExercise,
          child: Text(
            tr(LocaleKeys.common_exercise),
            style: AppTextStyles.title18.copyWith(color: isExercise ? AppColors.textPrimary : AppColors.textMutedLight, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class VoiceLogFrostedSurface extends StatelessWidget {
  const VoiceLogFrostedSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.voiceFrostedSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class VoiceLogTextArea extends StatelessWidget {
  const VoiceLogTextArea({super.key, required this.controller, required this.hintText, this.onChanged, this.enabled = true});

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.askAiInputHeight,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.m)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: null,
        style: AppTextStyles.body14.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTextStyles.body14.copyWith(color: AppColors.textTertiary),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class VoiceLogAnalyzeButton extends StatelessWidget {
  const VoiceLogAnalyzeButton({super.key, required this.label, required this.onTap, this.enabled = true});

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FoodyPrimaryButton(label: label, onTap: enabled ? onTap : null, icon: CupertinoIcons.sparkles, gradient: AppGradients.askAiPrimary, height: AppSizes.voiceAnalyzeHeight);
  }
}

class VoiceMicButton extends StatelessWidget {
  const VoiceMicButton({super.key, this.gradient, this.color, required this.onTap, this.onLongPress});

  final Gradient? gradient;
  final Color? color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: AppSizes.voiceMicSize,
        height: AppSizes.voiceMicSize,
        decoration: BoxDecoration(gradient: gradient, color: color, shape: BoxShape.circle, boxShadow: AppShadows.button),
        child: Icon(CupertinoIcons.mic_fill, size: AppSizes.voiceMicIcon, color: AppColors.onPrimary),
      ),
    );
  }
}
