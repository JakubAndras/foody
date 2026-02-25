import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/logs/voice_widgets.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/services/voice/voice_transcription_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum VoiceLogMode { meals, exercise }

class VoiceLogScreen extends StatefulWidget {
  const VoiceLogScreen({
    super.key,
    this.initialMode = VoiceLogMode.meals,
  });

  final VoiceLogMode initialMode;

  @override
  State<VoiceLogScreen> createState() => _VoiceLogScreenState();
}

class _VoiceLogScreenState extends State<VoiceLogScreen> with SingleTickerProviderStateMixin {
  final VoiceTranscriptionService _voiceService = VoiceTranscriptionService();
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _hasPermission = false;
  bool _permissionPermanentlyDenied = false;
  bool _isListening = false;
  bool _isPaused = false;
  bool _isAnalyzing = false;
  bool _speechReady = false;
  String _dictationBaseText = '';
  String _currentSessionTranscript = '';
  String? _speechErrorMessage;
  VoiceLogMode _mode = VoiceLogMode.meals;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.11).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _refreshPermissionStatus();
  }

  @override
  void dispose() {
    _voiceService.cancelListening().catchError((_) {});
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshPermissionStatus() async {
    try {
      final microphoneStatus = await Permission.microphone.status;

      PermissionStatus speechStatus = PermissionStatus.granted;
      if (Platform.isIOS) {
        speechStatus = await Permission.speech.status;
      }

      if (!mounted) return;
      setState(() {
        _hasPermission = microphoneStatus.isGranted && speechStatus.isGranted;
        _permissionPermanentlyDenied = microphoneStatus.isPermanentlyDenied || microphoneStatus.isRestricted || speechStatus.isPermanentlyDenied || speechStatus.isRestricted;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasPermission = false;
        _permissionPermanentlyDenied = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    try {
      final microphoneStatus = await Permission.microphone.request();

      PermissionStatus speechStatus = PermissionStatus.granted;
      if (Platform.isIOS) {
        speechStatus = await Permission.speech.request();
      }

      if (!mounted) return;
      setState(() {
        _hasPermission = microphoneStatus.isGranted && speechStatus.isGranted;
        _permissionPermanentlyDenied = microphoneStatus.isPermanentlyDenied || microphoneStatus.isRestricted || speechStatus.isPermanentlyDenied || speechStatus.isRestricted;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasPermission = false;
        _permissionPermanentlyDenied = false;
        _speechErrorMessage = 'Unable to request voice permissions. Please try again.';
      });
    }
  }

  Future<void> _showVoicePermissionDialog() async {
    if (!mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Voice permission dialog',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.m,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: AppColors.violetStrong,
                          size: AppSizes.iconLg,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Microphone Access',
                        style: AppTextStyles.title18Tight.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        _permissionPermanentlyDenied
                            ? 'Voice access is disabled. Open Settings to enable microphone and speech recognition.'
                            : 'Allow microphone and speech recognition to dictate your meals or exercise.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14Relaxed.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Row(
                        children: [
                          Expanded(
                            child: _PermissionDialogButton(
                              label: 'Not now',
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: _PermissionDialogButton(
                              label: _permissionPermanentlyDenied ? 'Open Settings' : 'Allow',
                              emphasized: true,
                              onTap: () async {
                                Navigator.of(context).pop();
                                if (_permissionPermanentlyDenied) {
                                  await openAppSettings();
                                  await _refreshPermissionStatus();
                                } else {
                                  await _requestPermission();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    try {
      final available = await _voiceService.initialize(
        onError: _handleSpeechError,
        onStatus: _handleSpeechStatus,
      );
      if (!mounted) return false;

      if (!available) {
        setState(() {
          _speechErrorMessage = 'Speech recognition is unavailable on this device.';
        });
        return false;
      }

      setState(() {
        _speechReady = true;
        _speechErrorMessage = null;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _speechErrorMessage = 'Failed to initialize speech recognition.';
      });
      return false;
    }
  }

  Future<void> _startListening() async {
    if (_isAnalyzing) return;
    final appLocale = context.locale;
    final preferredVoiceLanguageCode = LanguageSettingsService.to.resolveVoiceLogLanguageCode(
      appLanguageCode: appLocale.languageCode,
    );

    if (!_hasPermission) {
      await _showVoicePermissionDialog();
      if (!_hasPermission) return;
    }

    final ready = await _ensureSpeechReady();
    if (!ready) return;

    try {
      _dictationBaseText = _controller.text.trim();
      _currentSessionTranscript = '';
      await _voiceService.startListening(
        onResult: _handleSpeechResult,
        appLocale: appLocale,
        preferredLanguageCode: preferredVoiceLanguageCode,
      );
      if (!mounted) return;
      setState(() {
        _isListening = true;
        _isPaused = false;
        _speechErrorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isPaused = false;
        _speechErrorMessage = 'Could not start voice recognition. Please try again.';
      });
    }
  }

  Future<void> _stopListening({bool paused = false}) async {
    if (!_isListening && !paused) return;
    try {
      await _voiceService.stopListening();
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isPaused = paused;
        _dictationBaseText = _controller.text.trim();
        _currentSessionTranscript = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isPaused = false;
        _speechErrorMessage = 'Failed to stop voice recognition cleanly.';
      });
    }
  }

  Future<void> _togglePause() async {
    if (_isListening) {
      await _stopListening(paused: true);
      return;
    }
    if (_isPaused) {
      await _startListening();
    }
  }

  Future<void> _toggleMode(VoiceLogMode mode) async {
    if (_mode == mode) return;
    String? cancellationErrorMessage;

    if (_isListening || _isPaused) {
      try {
        await _voiceService.cancelListening();
      } catch (_) {
        cancellationErrorMessage = 'Could not cancel current listening session.';
      }
    }

    if (!mounted) return;
    setState(() {
      _mode = mode;
      _isListening = false;
      _isPaused = false;
      _currentSessionTranscript = '';
      _speechErrorMessage = cancellationErrorMessage;
    });
  }

  Future<void> _handleAnalyze() async {
    final description = _controller.text.trim();
    if (description.isEmpty || _isAnalyzing) return;

    FocusManager.instance.primaryFocus?.unfocus();
    if (_isListening) {
      await _stopListening();
    }

    setState(() {
      _isAnalyzing = true;
    });

    if (_mode == VoiceLogMode.meals) {
      _startMealAnalysisAndNavigate(description);
      return;
    }

    _startExerciseAnalysisAndNavigate(description);
  }

  void _startMealAnalysisAndNavigate(String description) {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    unawaited(
      DashboardController.to.analyzeMealFromVoice(
        selectedDate: selectedDate,
        description: description,
        scrollToTodayMealsOnStart: true,
      ),
    );
    _navigateToDashboardRoot();
  }

  void _startExerciseAnalysisAndNavigate(String description) {
    final selectedDate = SelectedDateService.to.selectedDate.value;
    unawaited(
      DashboardController.to.analyzeExerciseFromVoice(
        selectedDate: selectedDate,
        description: description,
        scrollToTodayMealsOnStart: true,
      ),
    );
    _navigateToDashboardRoot();
  }

  void _navigateToDashboardRoot() {
    if (Get.isRegistered<MainScreenController>()) {
      MainScreenController.to.showDashboardTab();
    }
    Get.until((route) => route.isFirst);
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) return;

    if (status == SpeechToText.listeningStatus) {
      setState(() {
        _isListening = true;
        _isPaused = false;
      });
      return;
    }

    if (status == SpeechToText.notListeningStatus || status == SpeechToText.doneStatus) {
      setState(() {
        _isListening = false;
        if (!_isPaused) {
          _dictationBaseText = _controller.text.trim();
          _currentSessionTranscript = '';
        }
      });
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _isPaused = false;
      _currentSessionTranscript = '';
      if (error.errorMsg.contains('permission')) {
        _hasPermission = false;
        _speechErrorMessage = 'Microphone or speech permission is missing.';
      } else {
        _speechErrorMessage = 'Voice recognition error: ${error.errorMsg}';
      }
    });
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) return;

    _currentSessionTranscript = recognized;
    final nextText = _mergeTranscript(
      _dictationBaseText,
      _currentSessionTranscript,
    );
    if (_controller.text != nextText) {
      _controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    if (result.finalResult) {
      _dictationBaseText = nextText;
      _currentSessionTranscript = '';
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _mergeTranscript(String baseText, String recognizedText) {
    if (baseText.isEmpty) return recognizedText;
    return '$baseText $recognizedText';
  }

  @override
  Widget build(BuildContext context) {
    final isExercise = _mode == VoiceLogMode.exercise;
    final hasText = _controller.text.trim().isNotEmpty;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              VoiceLogIconButton(
                                icon: Icons.close,
                                onTap: () => Navigator.of(context).maybePop(),
                              ),
                              VoiceLogIconButton(
                                icon: Icons.help_outline,
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Voice log tips coming soon.')),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        VoiceLogToggle(
                          isExercise: isExercise,
                          onSelectMeals: () => _toggleMode(VoiceLogMode.meals),
                          onSelectExercise: () => _toggleMode(VoiceLogMode.exercise),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              boxShadow: AppShadows.cardSubtle,
                            ),
                            child: Column(
                              children: [
                                VoiceLogTextArea(
                                  controller: _controller,
                                  hintText: isExercise
                                      ? "Dictate your exercise here... e.g., '30 minutes of running on a flat road, 1 hour of average training in the gym'"
                                      : "Dictate your meals here... e.g., 'one banana, average chicken breast with rice'",
                                  onChanged: (_) => setState(() {}),
                                  enabled: !_isListening && !_isAnalyzing,
                                ),
                                const SizedBox(height: AppSpacing.m),
                                VoiceLogAnalyzeButton(
                                  label: _isAnalyzing ? (isExercise ? 'Analyzing Exercise...' : 'Analyzing Meals...') : (isExercise ? 'Analyze Exercise' : 'Analyze Meals'),
                                  onTap: _handleAnalyze,
                                  enabled: hasText && !_isAnalyzing,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                          child: Text(
                            isExercise
                                ? 'Tap the microphone to start recording, or type your exercise directly into the field above.'
                                : 'Tap the microphone to start recording, or type your meals directly into the field above.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body14Relaxed,
                          ),
                        ),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final scale = _isListening ? _pulseAnimation.value : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: VoiceMicButton(
                            gradient: !isExercise && !_isListening ? AppGradients.primary : null,
                            color: isExercise || _isListening ? AppColors.violetStrong : null,
                            onTap: _isListening ? _stopListening : _startListening,
                            onLongPress: _togglePause,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        if (_isListening || _isPaused || _isAnalyzing || _speechErrorMessage != null)
                          Text(
                            _speechErrorMessage ?? (_isAnalyzing ? 'Analyzing...' : (_isPaused ? 'Paused' : 'Listening...')),
                            style: AppTextStyles.body14.copyWith(
                              color: _speechErrorMessage == null ? AppColors.violetStrong : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PermissionDialogButton extends StatelessWidget {
  const _PermissionDialogButton({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: emphasized ? AppColors.violetStrong : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: emphasized
              ? null
              : Border.all(
                  color: AppColors.outline,
                  width: 1,
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body14.copyWith(
            color: emphasized ? AppColors.onPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
