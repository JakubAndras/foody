import 'dart:async';
import 'dart:io' show Platform;

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/meal.dart';
// RESEARCH-ONLY: imports for research-only telemetry wiring
import 'package:diplomka/model/meal_entry_source.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
// RESEARCH-ONLY: end
import 'package:diplomka/state/language_settings_notifier.dart';
import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/screens/logs/voice_widgets.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/voice/voice_transcription_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class FixResultScreen extends ConsumerStatefulWidget {
  final bool showSyncCards;
  final Meal? baseMeal;
  final DateTime? selectedDate;
  final bool isNewMeal;

  const FixResultScreen({super.key, this.showSyncCards = false, this.baseMeal, this.selectedDate, this.isNewMeal = false});

  @override
  ConsumerState<FixResultScreen> createState() => _FixResultScreenState();
}

class _FixResultScreenState extends ConsumerState<FixResultScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  // Voice state
  final VoiceTranscriptionService _voiceService = VoiceTranscriptionService();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _hasPermission = false;
  bool _isListening = false;
  bool _speechReady = false;
  String _dictationBaseText = '';
  String _currentSessionTranscript = '';
  String? _speechErrorMessage;
  bool _showAnalyzeHint = false;
  Timer? _analyzeHintTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.11).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _refreshPermissionStatus();
  }

  @override
  void dispose() {
    _analyzeHintTimer?.cancel();
    _voiceService.cancelListening().catchError((_) {});
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ── Voice methods ──

  Future<void> _refreshPermissionStatus() async {
    final micStatus = await Permission.microphone.status;
    // Permission.speech is iOS-only (maps to NSSpeechRecognitionUsageDescription).
    // On Android it always returns 'denied', which would block voice from
    // ever starting. Default to 'granted' on Android — RECORD_AUDIO is the
    // only permission speech_to_text actually needs there.
    final speechStatus = Platform.isIOS ? await Permission.speech.status : PermissionStatus.granted;
    if (!mounted) return;
    setState(() => _hasPermission = micStatus.isGranted && speechStatus.isGranted);
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    try {
      final available = await _voiceService.initialize(
        onError: (error) {
          if (!mounted) return;
          setState(() => _speechErrorMessage = tr(LocaleKeys.voice_recognition_error, namedArgs: {'error': error.errorMsg}));
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              _dictationBaseText = _controller.text.trim();
              _currentSessionTranscript = '';
            });
          }
        },
      );
      if (!available) {
        if (!mounted) return false;
        setState(() => _speechErrorMessage = tr(LocaleKeys.voice_speech_unavailable));
        return false;
      }
      setState(() {
        _speechReady = true;
        _speechErrorMessage = null;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() => _speechErrorMessage = tr(LocaleKeys.voice_speech_init_failed));
      return false;
    }
  }

  Future<void> _startListening() async {
    if (_isSubmitting) return;
    final appLocale = context.locale;
    final preferredVoiceLanguageCode = ref.read(languageSettingsServiceProvider).resolveVoiceLogLanguageCode(appLanguageCode: appLocale.languageCode, preference: ref.read(languageSettingsProvider).voiceLogLanguagePreference);

    if (!_hasPermission) {
      final micStatus = await Permission.microphone.request();
      // Permission.speech is iOS-only — see _refreshPermissionStatus comment.
      final speechStatus = Platform.isIOS ? await Permission.speech.request() : PermissionStatus.granted;
      if (!micStatus.isGranted || !speechStatus.isGranted) return;
      setState(() => _hasPermission = true);
    }

    final ready = await _ensureSpeechReady();
    if (!ready) return;

    try {
      _dictationBaseText = _controller.text.trim();
      _currentSessionTranscript = '';
      await _voiceService.startListening(onResult: _handleSpeechResult, appLocale: appLocale, preferredLanguageCode: preferredVoiceLanguageCode);
      if (!mounted) return;
      setState(() {
        _isListening = true;
        _speechErrorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _speechErrorMessage = tr(LocaleKeys.voice_start_failed);
      });
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    try {
      await _voiceService.stopListening();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      if (_controller.text.trim().isNotEmpty) {
        _showAnalyzeHint = true;
        _analyzeHintTimer?.cancel();
        _analyzeHintTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showAnalyzeHint = false);
        });
      }
      setState(() {
        _isListening = false;
        _dictationBaseText = _controller.text.trim();
        _currentSessionTranscript = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _speechErrorMessage = tr(LocaleKeys.voice_stop_failed);
      });
    }
  }

  void _handleSpeechResult(dynamic result) {
    if (!_isListening) return;
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) return;

    _currentSessionTranscript = recognized;
    final nextText = _mergeTranscript(_dictationBaseText, _currentSessionTranscript);
    if (nextText.length <= 500 && _controller.text != nextText) {
      _controller.value = TextEditingValue(text: nextText, selection: TextSelection.collapsed(offset: nextText.length));
    }

    if (result.finalResult) {
      _dictationBaseText = nextText;
      _currentSessionTranscript = '';
    }

    if (mounted) setState(() {});
  }

  String _mergeTranscript(String baseText, String recognizedText) {
    if (baseText.isEmpty) return recognizedText;
    return '$baseText $recognizedText';
  }

  void _showVoiceLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.xxl),
                topRight: Radius.circular(AppRadii.xxl),
                bottomLeft: Radius.circular(AppRadii.xxl + 10),
                bottomRight: Radius.circular(AppRadii.xxl + 10),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xxs, AppSpacing.l, AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SheetDragHandle(color: AppColors.textTertiary.withValues(alpha: 0.3)),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(child: Text(tr(LocaleKeys.language_settings_voice_language_title), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700))),
                        GestureDetector(
                          onTap: () => Navigator.of(sheetContext).pop(),
                          child: Container(
                            width: AppSizes.iconButtonSm,
                            height: AppSizes.iconButtonSm,
                            decoration: BoxDecoration(color: AppColors.surfaceMuted, shape: BoxShape.circle),
                            child: Icon(CupertinoIcons.xmark, size: AppSizes.iconSm, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tr(LocaleKeys.language_settings_voice_language_subtitle), style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Consumer(builder: (context, ref, _) {
                      final current = ref.watch(languageSettingsProvider).voiceLogLanguagePreference;
                      final notifier = ref.read(languageSettingsProvider.notifier);
                      return Column(
                        children: [
                          _buildLanguageRow('🇺🇸', tr(LocaleKeys.language_settings_option_english), current == VoiceLogLanguagePreference.english, () async {
                            await notifier.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.english);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          }),
                          Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
                          _buildLanguageRow('🇨🇿', tr(LocaleKeys.language_settings_option_czech), current == VoiceLogLanguagePreference.czech, () async {
                            await notifier.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.czech);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageRow(String flag, String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.m),
            Expanded(child: Text(label, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500))),
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

  // ── Tip bottom sheet ──

  void _showTipSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadii.xxl),
              topRight: Radius.circular(AppRadii.xxl),
              bottomLeft: Radius.circular(AppRadii.xxl + 10),
              bottomRight: Radius.circular(AppRadii.xxl + 10),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xxs, AppSpacing.l, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetDragHandle(color: AppColors.textTertiary.withValues(alpha: 0.3)),
              const SizedBox(height: AppSpacing.l),
              Text(tr(LocaleKeys.meal_fix_issue), style: AppTextStyles.title18.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              Text(tr(LocaleKeys.fix_result_tip_subtitle), style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.m),
              _TipRow(icon: CupertinoIcons.flame, text: tr(LocaleKeys.fix_result_tip_cooking)),
              _TipRow(icon: CupertinoIcons.xmark_circle, text: tr(LocaleKeys.fix_result_tip_ingredient)),
              _TipRow(icon: CupertinoIcons.speedometer, text: tr(LocaleKeys.fix_result_tip_portion)),
              _TipRow(icon: CupertinoIcons.plus_circle, text: tr(LocaleKeys.fix_result_tip_missing)),
              _TipRow(icon: CupertinoIcons.mic, text: tr(LocaleKeys.fix_result_tip_voice)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Analyze ──

  Future<void> _handleUpdate() async {
    if (_isListening) await _stopListening();
    if (!mounted) return;
    _showAnalyzeHint = false;
    _analyzeHintTimer?.cancel();

    final text = _controller.text.trim();
    if (text.isEmpty) {
      showSnackBar(context: context, message: tr(LocaleKeys.fix_result_add_details), subtitle: tr(LocaleKeys.fix_result_hint), type: SnackBarType.info);
      return;
    }

    setState(() => _isSubmitting = true);
    final photoPath = widget.baseMeal?.photoPath;
    final photoFile = MediaStorage.existingMealPhotoFile(photoPath);
    final imageFiles = photoFile == null ? null : [photoFile];
    // RESEARCH-ONLY: modality routed to AiAttempt log
    final result = await ref.read(aiPipelineServiceProvider).analyzeMeal(
      imageFiles: imageFiles,
      description: text,
      modality: MealEntrySource.fixWithAiRerun.code,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!result.isSuccess || result.response == null) {
      showSnackBar(context: context, message: tr(LocaleKeys.error_analysis_failed), subtitle: result.message ?? tr(LocaleKeys.common_try_again), type: SnackBarType.error);
      return;
    }

    if (result.status == AiAnalysisStatus.lowConfidence) {
      showSnackBar(context: context, message: tr(LocaleKeys.error_low_confidence), subtitle: result.message ?? tr(LocaleKeys.error_low_confidence_review), type: SnackBarType.warning);
    }

    final analyzedMeal = Meal.fromAnswer(result.response!.answer);
    final baseMeal = widget.baseMeal;
    // RESEARCH-ONLY: provider/model/source resolution is research-only.
    // When stripping telemetry, drop the four extra copyWith args below.
    final providerCode = ref.read(aiServiceManagerProvider.notifier).currentProviderCode;
    final modelCode = ref.read(aiServiceManagerProvider.notifier).currentModelCode;
    final isRerun = !widget.isNewMeal && baseMeal?.id != null;
    final resolvedSource = isRerun ? MealEntrySource.fixWithAiRerun.code : (baseMeal?.inputSource ?? MealEntrySource.textAi.code);
    final updatedMeal = analyzedMeal.copyWith(
      id: baseMeal?.id,
      dayRecordId: baseMeal?.dayRecordId,
      timestamp: baseMeal?.timestamp ?? DateTime.now(),
      photoPath: baseMeal?.photoPath,
      name: analyzedMeal.name.isEmpty && baseMeal != null ? baseMeal.name : analyzedMeal.name,
      // RESEARCH-ONLY: research-only fields below
      inputSource: resolvedSource,
      aiProvider: providerCode,
      aiModel: modelCode,
    );

    Navigator.of(context).pop(updatedMeal);
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: AppColors.meshBase,
        body: Stack(
          children: [
            VariableBlurScrollView(
              topBlurSigma: 52,
              topFadeHeight: 40,
              bottomFadeHeight: 0,
              backgroundColor: Colors.transparent,
              fadeColor: AppColors.meshBase,
              backgroundWidget: const MeshGradientBackground(),
              padding: EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.mega + AppSpacing.xxl, AppSpacing.m, AppSpacing.xl + AppSpacing.mega + (Platform.isAndroid ? MediaQuery.of(context).padding.bottom : 0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Platform.isAndroid ? AppSpacing.l : AppSpacing.s),
                  AskAiPromptCard(
                    controller: _controller,
                    isLoading: _isSubmitting || _isListening,
                    hintText: tr(LocaleKeys.fix_result_hint),
                    buttonLabel: tr(LocaleKeys.fix_result_update),
                    loadingLabel: tr(LocaleKeys.fix_result_updating),
                    onAsk: _controller.text.trim().isEmpty ? null : _handleUpdate,
                    onClear: () => _controller.clear(),
                  ),
                ],
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: AppSpacing.m,
              right: AppSpacing.m,
              child: ProfileTopBar(
                title: tr(LocaleKeys.meal_fix_issue),
                onBack: () => Navigator.of(context).maybePop(),
                actions: [
                  CustomGlassIconButtonGroup(items: [
                    (icon: CupertinoIcons.globe, onPressed: () => _showVoiceLanguageSheet(context)),
                    (icon: CupertinoIcons.info_circle, onPressed: _showTipSheet),
                  ]),
                ],
              ),
            ),
            // Bottom mic button
            Positioned(
              // Android-only extra bottom padding to lift the mic above the
              // gesture bar (matches the bottom-button pattern across the app).
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl + (Platform.isAndroid ? AppSpacing.m : 0),
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final scale = _isListening ? _pulseAnimation.value : 1.0;
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: VoiceMicButton(
                        gradient: _isListening ? AppGradients.askAiPrimary : AppGradients.primary,
                        onTap: _isListening ? _stopListening : _startListening,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  if (_isListening || _speechErrorMessage != null || _showAnalyzeHint)
                    Text(
                      _speechErrorMessage ??
                          (_showAnalyzeHint ? tr(LocaleKeys.voice_tap_analyze) : tr(LocaleKeys.voice_listening)),
                      style: AppTextStyles.body14.copyWith(color: _speechErrorMessage == null ? AppColors.textPrimary : AppColors.error, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(text, style: AppTextStyles.body14Relaxed)),
        ],
      ),
    );
  }
}
