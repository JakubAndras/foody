import 'dart:async';
import 'dart:io' show Platform;

import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/screens/logs/voice_widgets.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/voice/voice_transcription_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/ask_ai_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ask_ai_query_response.dart';
import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  late final AskAiController _controller;

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

  @override
  void initState() {
    super.initState();
    _controller = AskAiController.to;
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.11).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _refreshPermissionStatus();
  }

  @override
  void dispose() {
    _voiceService.cancelListening().catchError((_) {});
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ── Voice methods ──

  Future<void> _refreshPermissionStatus() async {
    final micStatus = await Permission.microphone.status;
    final speechStatus = await Permission.speech.status;
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
              _dictationBaseText = _textController.text.trim();
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
    if (_controller.isLoading.value) return;
    final appLocale = context.locale;
    final preferredVoiceLanguageCode = LanguageSettingsService.to.resolveVoiceLogLanguageCode(appLanguageCode: appLocale.languageCode);

    if (!_hasPermission) {
      final micStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();
      if (!micStatus.isGranted || !speechStatus.isGranted) return;
      setState(() => _hasPermission = true);
    }

    final ready = await _ensureSpeechReady();
    if (!ready) return;

    try {
      _dictationBaseText = _textController.text.trim();
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
      setState(() {
        _isListening = false;
        _dictationBaseText = _textController.text.trim();
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
    if (_textController.text != nextText) {
      _textController.value = TextEditingValue(text: nextText, selection: TextSelection.collapsed(offset: nextText.length));
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
    final service = LanguageSettingsService.to;
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
                    Obx(() {
                      final current = service.voiceLogLanguagePreference.value;
                      return Column(
                        children: [
                          _buildLanguageRow('🇺🇸', tr(LocaleKeys.language_settings_option_english), current == VoiceLogLanguagePreference.english, () async {
                            await service.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.english);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          }),
                          Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
                          _buildLanguageRow('🇨🇿', tr(LocaleKeys.language_settings_option_czech), current == VoiceLogLanguagePreference.czech, () async {
                            await service.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.czech);
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

  // ── Ask AI methods ──

  Future<void> _handleAsk() async {
    if (_isListening) await _stopListening();

    final query = _textController.text.trim();
    if (query.isEmpty) return;

    final result = await _controller.submitQuery(query);
    if (result == null && _controller.errorMessage.value != null) {
      showSnackBar(
        context: context,
        message: tr(LocaleKeys.ask_ai_title),
        subtitle: _controller.errorMessage.value!,
        type: SnackBarType.error,
      );
    }
  }

  void _clearResponse() {
    _controller.clearResponse();
    _textController.clear();
  }

  Future<void> _handleShare() async {
    final response = _controller.response.value;
    final query = _controller.lastQuery.value;
    if (response == null) return;

    final text = [
      tr(LocaleKeys.ask_ai_title),
      '',
      '${tr(LocaleKeys.ask_ai_question_label)}: $query',
      '',
      '${tr(LocaleKeys.ask_ai_summary_label)}: ${response.summaryValue} ${response.summaryLabel}',
      '${tr(LocaleKeys.ask_ai_period_label)}: ${response.periodLabel}',
      if (response.primaryMonthDays.isNotEmpty) '${tr(LocaleKeys.ask_ai_affected_days_label)}: ${response.primaryMonthDays.join(', ')}',
      '',
      response.responseText,
    ].join('\n');

    try {
      await AppShareService.shareText(text: text, title: tr(LocaleKeys.ask_ai_title), subject: tr(LocaleKeys.ask_ai_share_subject), context: context);
    } catch (_) {
      showSnackBar(context: context, message: tr(LocaleKeys.ask_ai_share_unavailable), subtitle: tr(LocaleKeys.ask_ai_share_error), type: SnackBarType.error);
    }
  }

  void _handleExampleTap(String question) {
    Navigator.of(context).pop();
    _textController.text = question;
    _handleAsk();
  }

  void _showExampleQuestionsSheet() {
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
              AskAiSectionHeader(title: tr(LocaleKeys.ask_ai_example_questions), icon: CupertinoIcons.question, iconGradient: AppGradients.askAiExample, iconRadius: AppRadii.xs, iconSize: 28),
              const SizedBox(height: AppSpacing.m),
              AskAiExampleQuestionCard(label: tr(LocaleKeys.ask_ai_example_1), height: 68, onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_1))),
              const SizedBox(height: AppSpacing.s),
              AskAiExampleQuestionCard(label: tr(LocaleKeys.ask_ai_example_2), height: 68, onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_2))),
              const SizedBox(height: AppSpacing.s),
              AskAiExampleQuestionCard(label: tr(LocaleKeys.ask_ai_example_3), onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_3))),
              const SizedBox(height: AppSpacing.s),
              AskAiExampleQuestionCard(label: tr(LocaleKeys.ask_ai_example_4), onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_4))),
              const SizedBox(height: AppSpacing.s),
              AskAiExampleQuestionCard(label: tr(LocaleKeys.ask_ai_example_5), onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_5))),
            ],
          ),
        ),
      ),
    );
  }

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
              child: Obx(() {
                final response = _controller.response.value;
                final loading = _controller.isLoading.value;

                if (response != null) {
                  return _buildResponseContent(response);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Platform.isAndroid ? AppSpacing.l : AppSpacing.s),
                    AskAiPromptCard(controller: _textController, isLoading: loading || _isListening, onAsk: _handleAsk, onClear: () => _textController.clear()),
                    if (loading) ...[
                      const SizedBox(height: AppSpacing.m),
                      const AskAiLoadingSkeleton(),
                    ],
                  ],
                );
              }),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: AppSpacing.m,
              right: AppSpacing.m,
              child: Obx(() {
                final hasResponse = _controller.response.value != null;
                return ProfileTopBar(
                  title: tr(LocaleKeys.ask_ai_title),
                  onBack: () => Get.back(),
                  actions: [
                    if (hasResponse)
                      CustomGlassIconButtonGroup(
                        items: [
                          (icon: CupertinoIcons.arrow_counterclockwise, onPressed: _clearResponse),
                          (icon: CupertinoIcons.info_circle, onPressed: _showExampleQuestionsSheet),
                        ],
                      )
                    else
                      CustomGlassIconButtonGroup(
                        items: [
                          (icon: CupertinoIcons.globe, onPressed: () => _showVoiceLanguageSheet(context)),
                          (icon: CupertinoIcons.info_circle, onPressed: _showExampleQuestionsSheet),
                        ],
                      ),
                  ],
                );
              }),
            ),
            // Bottom mic button
            Obx(() {
              final hasResponse = _controller.response.value != null;
              if (hasResponse) return const SizedBox.shrink();
              return Positioned(
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
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
                    if (_isListening || _speechErrorMessage != null)
                      Text(
                        _speechErrorMessage ?? tr(LocaleKeys.voice_listening),
                        style: AppTextStyles.body14.copyWith(color: _speechErrorMessage == null ? AppColors.textPrimary : AppColors.error, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseContent(AskAiQueryResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.m),
        AskAiResponseCard(text: response.responseText),
        const SizedBox(height: AppSpacing.m),
        AskAiSummaryCard(
          value: response.summaryValue,
          label: response.summaryLabel,
          icon: response.summaryIcon,
          iconGradient: response.summaryGradient,
          panelGradient: response.summarySurfaceGradient,
          valueGradient: response.summaryGradient,
        ),
        if (response.affectedDays.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          AskAiCalendarCard(
            allAffectedDays: response.affectedDays,
            affectedGradient: response.summaryGradient,
            initialYear: response.primaryYear,
            initialMonth: response.primaryMonth,
            onDayTap: (date) => Get.to(() => DashboardPreviewScreen(date: date)),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        SizedBox(
          width: double.infinity,
          child: AskAiPrimaryButton(
            label: tr(LocaleKeys.common_share),
            leading: Icon(CupertinoIcons.share, size: AppSizes.iconMd, color: AppColors.onPrimary),
            gradient: AppGradients.primary,
            onPressed: _handleShare,
          ),
        ),
      ],
    );
  }
}
