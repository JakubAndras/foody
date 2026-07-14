import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/widgets/sheet_top_bar.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_screen.dart';
import 'package:diplomka/screens/profile/subscreens/preferences_screen.dart';
import 'package:diplomka/state/language_settings_notifier.dart';
import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/screens/profile/subscreens/edit_nutrition_goals_screen.dart';
import 'package:diplomka/screens/profile/subscreens/health_integration_screen.dart';
import 'package:diplomka/screens/profile/subscreens/ring_colors_explained_screen.dart';
import 'package:diplomka/screens/profile/subscreens/motivational_summary_screen.dart';
import 'package:diplomka/screens/profile/subscreens/tracking_reminders_screen.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_intro_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_screen.dart';
import 'package:diplomka/screens/profile/subscreens/faq_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'dart:io';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionHeaderPaddingEnabled = ref.watch(sessionProvider).sectionHeaderPaddingEnabled;
    return Scaffold(
      backgroundColor: AppColors.meshBase,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (context) {
            final bottomInset = Platform.isAndroid ? MediaQuery.of(context).padding.bottom : 0.0;
            final topInset = Platform.isAndroid ? AppSpacing.mega - 8 : AppSpacing.mega + AppSpacing.s;
            return VariableBlurScrollView(
              topBlurSigma: 52,
              topFadeHeight: 40,
              backgroundColor: Colors.transparent,
              fadeColor: AppColors.meshBase,
              backgroundWidget: const MeshGradientBackground(),
              padding: EdgeInsets.fromLTRB(AppSpacing.m, topInset, AppSpacing.m, AppSpacing.mega + 42 + bottomInset),
              //collapsedHeader: Text(tr(LocaleKeys.profile_title), style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //CollapsibleTitle(child: Text(tr(LocaleKeys.profile_title), style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700))),
                  //const SizedBox(height: AppSpacing.s),
                  // const _ProfileHeaderCard(),
                  // const SizedBox(height: AppSpacing.l),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sectionHeaderPaddingEnabled ? AppSpacing.s : 0),
                    child: ProfileSectionHeader(title: tr(LocaleKeys.profile_account)),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _ProfileGroupCard(
                    children: [
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_personal_details),
                        icon: CupertinoIcons.person,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PersonalDetailsScreen())),
                      ),
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_preferences),
                        icon: CupertinoIcons.gear,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PreferencesScreen())),
                      ),
                      _ProfileActionRow(title: tr(LocaleKeys.profile_language), icon: CupertinoIcons.globe, showDivider: false, onTap: () => _showLanguageSheet(context, ref)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sectionHeaderPaddingEnabled ? AppSpacing.s : 0),
                    child: ProfileSectionHeader(title: tr(LocaleKeys.profile_goals_tracking)),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _ProfileGroupCard(
                    children: [
                      _ProfileActionRow(
                        title: tr(LocaleKeys.nutrition_goals_title),
                        icon: CupertinoIcons.location,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditNutritionGoalsScreen())),
                      ),
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_tracking_reminders),
                        icon: CupertinoIcons.bell,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrackingRemindersScreen())),
                      ),
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_motivational_summary),
                        icon: CupertinoIcons.star,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MotivationalSummaryScreen())),
                      ),
                      _ProfileActionRow(
                        title: Platform.isIOS ? tr(LocaleKeys.health_apple_health) : tr(LocaleKeys.health_health_connect),
                        icon: CupertinoIcons.heart,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthIntegrationScreen())),
                      ),
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_ring_colors),
                        icon: CupertinoIcons.circle,
                        showDivider: false,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RingColorsExplainedScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sectionHeaderPaddingEnabled ? AppSpacing.s : 0),
                    child: ProfileSectionHeader(title: tr(LocaleKeys.profile_progress_data)),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _ProfileGroupCard(
                    children: [
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_export_summary),
                        icon: CupertinoIcons.share,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExportPdfIntroScreen())),
                      ),
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_ask_ai),
                        icon: CupertinoIcons.sparkles,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AskAiScreen())),
                      ),
                      _ProfileActionRow(
                        title: tr(LocaleKeys.profile_faq),
                        icon: CupertinoIcons.question_circle,
                        showDivider: false,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqScreen())),
                      ),
                    ],
                  ),
                  // TODO: Test section — hidden, re-enable for development
                  // const SizedBox(height: AppSpacing.l),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: SessionManager.to.sectionHeaderPaddingEnabled.value ? AppSpacing.s : 0),
                  //   child: ProfileSectionHeader(title: 'Test'),
                  // ),
                  // const SizedBox(height: AppSpacing.s),
                  // _ProfileGroupCard(
                  //   children: [
                  //     _ProfileActionRow(title: 'Glass Test', icon: CupertinoIcons.circle_filled, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GlassTestScreen()))),
                  //     _ProfileActionRow(title: 'Liquid Glass Widgets Test', icon: CupertinoIcons.sparkles, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiquidGlassWidgetsTestScreen()))),
                  //     _ProfileActionRow(title: 'Test Onboarding', icon: CupertinoIcons.play_circle, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()))),
                  //     _ProfileActionRow(title: 'Test Scanning Onboarding', icon: CupertinoIcons.viewfinder, showDivider: false, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanOnboardingScreen(forceShow: true)))),
                  //   ],
                  // ),
                  // TODO: Account Actions section — hidden for now, will be needed later
                  // const SizedBox(height: AppSpacing.l),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: SessionManager.to.sectionHeaderPaddingEnabled.value ? AppSpacing.s : 0),
                  //   child: ProfileSectionHeader(title: tr(LocaleKeys.profile_account_actions)),
                  // ),
                  // const SizedBox(height: AppSpacing.s),
                  // _ProfileGroupCard(
                  //   children: [
                  //     _ProfileActionRow(
                  //       title: tr(LocaleKeys.profile_logout),
                  //       icon: CupertinoIcons.square_arrow_right,
                  //       onTap: () => showSnackBar(message: tr(LocaleKeys.profile_logout), subtitle: tr(LocaleKeys.profile_logout_stub), type: SnackBarType.info),
                  //     ),
                  //     _ProfileActionRow(
                  //       title: tr(LocaleKeys.profile_delete_account),
                  //       icon: CupertinoIcons.person_badge_minus,
                  //       showDivider: false,
                  //       onTap: () => showSnackBar(message: tr(LocaleKeys.profile_delete_account), subtitle: tr(LocaleKeys.profile_delete_account_stub), type: SnackBarType.info),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: AppSpacing.s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sectionHeaderPaddingEnabled ? AppSpacing.s : 0),
                    child: Center(
                      child: Text(
                        tr(LocaleKeys.profile_version, namedArgs: {'version': '0.0.0'}),
                        style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    ref.read(languageSettingsProvider.notifier).initialize(context.locale.languageCode);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.xxs),
              SheetDragHandle(color: AppColors.textTertiary.withValues(alpha: 0.3)),
              const SizedBox(height: AppSpacing.s),
              SheetTopBar(title: tr(LocaleKeys.language_settings_title), onClose: () => Navigator.of(sheetContext).pop()),
              const SizedBox(height: AppSpacing.m),
              Consumer(
                builder: (context, ref, _) {
                  final current = ref.watch(languageSettingsProvider).appLanguage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: Column(
                      children: [
                        _LanguageRow(
                          flag: '🇺🇸',
                          label: tr(LocaleKeys.language_settings_option_english),
                          selected: current == AppLanguage.english,
                          onTap: () async {
                            if (current == AppLanguage.english) {
                              Navigator.of(sheetContext).pop();
                              return;
                            }
                            ref.read(languageSettingsProvider.notifier).setAppLanguage(AppLanguage.english);
                            await sheetContext.setLocale(AppLanguage.english.locale);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          },
                        ),
                        Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
                        _LanguageRow(
                          flag: '🇨🇿',
                          label: tr(LocaleKeys.language_settings_option_czech),
                          selected: current == AppLanguage.czech,
                          onTap: () async {
                            if (current == AppLanguage.czech) {
                              Navigator.of(sheetContext).pop();
                              return;
                            }
                            ref.read(languageSettingsProvider.notifier).setAppLanguage(AppLanguage.czech);
                            await sheetContext.setLocale(AppLanguage.czech.locale);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.flag, required this.label, required this.selected, required this.onTap});

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(label, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500)),
            ),
            if (selected)
              Container(
                width: AppSizes.iconMd + 4,
                height: AppSizes.iconMd + 4,
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Icon(CupertinoIcons.checkmark, size: AppSizes.iconSm, color: AppColors.onPrimary),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileGroupCard extends StatelessWidget {
  const _ProfileGroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.l,
      shadow: AppShadows.screenCard,
      border: AppBorders.screenCard,
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({required this.title, required this.icon, this.showDivider = true, this.onTap});

  final String title;
  final IconData icon;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsRow(
      title: title,
      leading: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
      showDivider: showDivider,
      onTap: onTap,
    );
  }
}

