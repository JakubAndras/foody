import 'dart:async';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/logs/voice_permission_screen.dart';
import 'package:diplomka/screens/logs/voice_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

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

class _VoiceLogScreenState extends State<VoiceLogScreen> {
  final AudioRecorder _record = AudioRecorder();
  final TextEditingController _controller = TextEditingController();
  bool _hasPermission = false;
  bool _permissionPermanentlyDenied = false;
  bool _isRecording = false;
  bool _isPaused = false;
  String? _recordingPath;
  VoiceLogMode _mode = VoiceLogMode.meals;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _initPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    _record.dispose();
    super.dispose();
  }

  Future<void> _initPermission() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;
    setState(() {
      _hasPermission = status.isGranted;
      _permissionPermanentlyDenied = status.isPermanentlyDenied;
    });
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _initPermission();
      if (!_hasPermission) return;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/voice_log_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _record.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    setState(() {
      _recordingPath = filePath;
      _isRecording = true;
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    await _record.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });

    if (_recordingPath != null) {
      final sampleText = _mode == VoiceLogMode.meals
          ? 'One banana and average chicken breast with rice'
          : '30 minutes of running on a flat road, 1 hour of average training in the gym';
      _controller.text = sampleText;
    }
  }

  Future<void> _togglePause() async {
    if (!_isRecording) return;
    if (_isPaused) {
      await _record.resume();
    } else {
      await _record.pause();
    }
    if (!mounted) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _toggleMode(VoiceLogMode mode) {
    if (_mode == mode) return;
    if (_isRecording) {
      _stopRecording();
    }
    setState(() {
      _mode = mode;
    });
  }

  void _handleAnalyze() {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _mode == VoiceLogMode.meals ? 'Analyzing meals...' : 'Analyzing exercise... ',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return VoicePermissionScreen(
        isPermanentlyDenied: _permissionPermanentlyDenied,
        onRequestPermission: _initPermission,
      );
    }

    final isExercise = _mode == VoiceLogMode.exercise;
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                      enabled: !_isRecording,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    VoiceLogAnalyzeButton(
                      label: isExercise ? 'Analyze Exercise' : 'Analyze Meals',
                      onTap: _handleAnalyze,
                      enabled: hasText,
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
            VoiceMicButton(
              gradient: !isExercise && !_isRecording ? AppGradients.primary : null,
              color: isExercise || _isRecording ? AppColors.violetStrong : null,
              onTap: _isRecording ? _stopRecording : _startRecording,
              onLongPress: _togglePause,
            ),
            const SizedBox(height: AppSpacing.s),
            if (_isRecording || _isPaused)
              Text(
                _isPaused ? 'Paused' : 'Listening...',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.violetStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
