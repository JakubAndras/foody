import 'dart:io';

import 'package:diplomka/database/entities/ai_attempt_entity.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/ai_feature/ai_attempt_log_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/export/export_service.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/services/weight_entry_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportDateRange { last7, last30, allTime, custom }

/// Druh uživatelské zprávy z exportu (dříve `SnackBarType`).
enum ExportMessageKind { info, error }

/// Jednorázová uživatelská zpráva vystavená ve stavu (dříve `showSnackBar`).
/// Notifier nenaviguje ani nezobrazuje UI; nese jen locale klíče a druh, UI je
/// promítne do snackbaru přes `ref.listen`. Každý výskyt je nová instance, takže
/// `ref.listen` pozná i dvě po sobě jdoucí stejné zprávy.
@immutable
class ExportMessage {
  const ExportMessage({required this.titleKey, required this.subtitleKey, required this.kind});

  final String titleKey;
  final String subtitleKey;
  final ExportMessageKind kind;
}

/// Sentinel pro `copyWith`, aby šlo nullovatelnou `message` explicitně nastavit na `null`.
const Object _undefined = Object();

/// Immutable stav exportní obrazovky.
@immutable
class ExportState {
  const ExportState({this.selectedRange = ExportDateRange.last7, this.customStart, this.customEnd, this.isExporting = false, this.message});

  final ExportDateRange selectedRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final bool isExporting;

  /// Poslední uživatelská zpráva (dříve `showSnackBar`). UI reaguje přes `ref.listen`.
  final ExportMessage? message;

  ExportState copyWith({ExportDateRange? selectedRange, DateTime? customStart, DateTime? customEnd, bool? isExporting, Object? message = _undefined}) {
    return ExportState(
      selectedRange: selectedRange ?? this.selectedRange,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      isExporting: isExporting ?? this.isExporting,
      message: message == _undefined ? this.message : message as ExportMessage?,
    );
  }
}

class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() => const ExportState();

  void selectRange(ExportDateRange range) => state = state.copyWith(selectedRange: range);

  void setCustomDates(DateTime start, DateTime end) {
    state = state.copyWith(customStart: start, customEnd: end);
  }

  (DateTime, DateTime) _resolveDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (state.selectedRange) {
      case ExportDateRange.last7:
        return (today.subtract(const Duration(days: 6)), today);
      case ExportDateRange.last30:
        return (today.subtract(const Duration(days: 29)), today);
      case ExportDateRange.allTime:
        return (DateTime(2000), today);
      case ExportDateRange.custom:
        return (state.customStart ?? today, state.customEnd ?? today);
    }
  }

  static final _fileDateFmt = DateFormat('dd_MM_yyyy');

  String _dateRangeLabel() {
    final fmt = DateFormat('MMM d, yyyy');
    final (start, end) = _resolveDateRange();
    if (state.selectedRange == ExportDateRange.allTime) return tr(LocaleKeys.export_all_time);
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  String _fileNameDateRange() {
    final (start, end) = _resolveDateRange();
    return '${_fileDateFmt.format(start)}_${_fileDateFmt.format(end)}';
  }

  Future<(List<DayRecord>, List<WeightEntry>)> _fetchData() async {
    final (start, end) = _resolveDateRange();
    final endInclusive = end.add(const Duration(days: 1));

    // RESEARCH-ONLY: include soft-deleted meals/ingredients in the export.
    // For production, swap back to `getAllDayRecords()`.
    final allRecords = await ref.read(dayRecordRepositoryProvider).getAllDayRecordsForExport();
    final records = allRecords.where((r) => !r.date.isBefore(start) && r.date.isBefore(endInclusive)).toList()..sort((a, b) => a.date.compareTo(b.date));

    final allWeights = await ref.read(weightEntryRepositoryProvider).getAllEntries();
    final weights = allWeights.where((w) => !w.date.isBefore(start) && w.date.isBefore(endInclusive)).toList()..sort((a, b) => a.date.compareTo(b.date));

    return (records, weights);
  }

  // RESEARCH-ONLY: research-only fetch. Drop with telemetry.
  Future<List<AiAttemptEntity>> _fetchAiAttempts() async {
    final (start, end) = _resolveDateRange();
    final endInclusive = end.add(const Duration(days: 1));
    return ref.read(aiAttemptLogServiceProvider).getAttempts(start: start, end: endInclusive);
  }

  Future<void> exportPdf() async {
    state = state.copyWith(isExporting: true);
    try {
      final (records, weights) = await _fetchData();
      if (records.isEmpty && weights.isEmpty) {
        state = state.copyWith(
          message: const ExportMessage(titleKey: LocaleKeys.export_pdf_title, subtitleKey: LocaleKeys.export_no_data, kind: ExportMessageKind.info),
        );
        return;
      }
      final goals = ref.read(nutritionGoalsProvider.notifier).goalsForDate(DateTime.now());
      final session = ref.read(sessionProvider);
      final aiAttempts = await _fetchAiAttempts();
      final bytes = await ExportService.generatePdf(
        records,
        weights,
        _dateRangeLabel(),
        calorieGoal: goals.calorieGoal,
        proteinGoal: goals.proteinGoal,
        carbsGoal: goals.carbsGoal,
        fatGoal: goals.fatGoal,
        dietType: session.dietType?.name,
        aiAttempts: aiAttempts,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/foody_report_${_fileNameDateRange()}.pdf');
      await file.writeAsBytes(bytes);
      await AppShareService.share(
        request: AppShareRequest(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: tr(LocaleKeys.export_pdf_title),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        message: const ExportMessage(titleKey: LocaleKeys.common_error, subtitleKey: LocaleKeys.export_error, kind: ExportMessageKind.error),
      );
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }

  Future<void> exportCsv() async {
    state = state.copyWith(isExporting: true);
    try {
      final (records, weights) = await _fetchData();
      if (records.isEmpty && weights.isEmpty) {
        state = state.copyWith(
          message: const ExportMessage(titleKey: LocaleKeys.export_pdf_title, subtitleKey: LocaleKeys.export_no_data, kind: ExportMessageKind.info),
        );
        return;
      }
      final session = ref.read(sessionProvider);
      // RESEARCH-ONLY: AI attempt log fetched alongside records.
      final aiAttempts = await _fetchAiAttempts();
      final csvString = ExportService.generateCsv(
        records,
        weights,
        heightCm: session.heightCm,
        weightKg: session.weightKg,
        goalWeightKg: session.goalWeightKg,
        sex: session.sex?.name,
        goal: session.goal?.name,
        dietType: session.dietType?.name,
        customDietPreferences: session.customDietPreferences,
        weightChangeRateKgPerWeek: session.weightChangeRateKgPerWeek,
        prefersMetric: session.prefersMetric,
        dateOfBirth: session.dateOfBirth,
        aiAttempts: aiAttempts,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/foody_report_${_fileNameDateRange()}.csv');
      await file.writeAsString(csvString);
      await AppShareService.share(
        request: AppShareRequest(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: tr(LocaleKeys.export_pdf_title),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        message: const ExportMessage(titleKey: LocaleKeys.common_error, subtitleKey: LocaleKeys.export_error, kind: ExportMessageKind.error),
      );
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }
}

final exportProvider = NotifierProvider<ExportNotifier, ExportState>(ExportNotifier.new);
