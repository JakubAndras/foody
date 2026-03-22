import 'dart:io';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/export/export_service.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/services/weight_entry_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportDateRange { last7, last30, allTime, custom }

class ExportController extends GetxController {
  static ExportController get to => Get.find();

  final selectedRange = ExportDateRange.last7.obs;
  final customStart = Rxn<DateTime>();
  final customEnd = Rxn<DateTime>();
  final isExporting = false.obs;

  void selectRange(ExportDateRange range) => selectedRange.value = range;

  void setCustomDates(DateTime start, DateTime end) {
    customStart.value = start;
    customEnd.value = end;
  }

  (DateTime, DateTime) _resolveDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (selectedRange.value) {
      case ExportDateRange.last7:
        return (today.subtract(const Duration(days: 6)), today);
      case ExportDateRange.last30:
        return (today.subtract(const Duration(days: 29)), today);
      case ExportDateRange.allTime:
        return (DateTime(2000), today);
      case ExportDateRange.custom:
        return (customStart.value ?? today, customEnd.value ?? today);
    }
  }

  static final _fileDateFmt = DateFormat('dd_MM_yyyy');

  String _dateRangeLabel() {
    final fmt = DateFormat('MMM d, yyyy');
    final (start, end) = _resolveDateRange();
    if (selectedRange.value == ExportDateRange.allTime) return tr(LocaleKeys.export_all_time);
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  String _fileNameDateRange() {
    final (start, end) = _resolveDateRange();
    return '${_fileDateFmt.format(start)}_${_fileDateFmt.format(end)}';
  }

  Future<(List<DayRecord>, List<WeightEntry>)> _fetchData() async {
    final (start, end) = _resolveDateRange();
    final endInclusive = end.add(const Duration(days: 1));

    final allRecords = await DayRecordRepository.to.getAllDayRecords();
    final records = allRecords.where((r) => !r.date.isBefore(start) && r.date.isBefore(endInclusive)).toList()..sort((a, b) => a.date.compareTo(b.date));

    final allWeights = await WeightEntryRepository.to.getAllEntries();
    final weights = allWeights.where((w) => !w.date.isBefore(start) && w.date.isBefore(endInclusive)).toList()..sort((a, b) => a.date.compareTo(b.date));

    return (records, weights);
  }

  Future<void> exportPdf() async {
    isExporting.value = true;
    try {
      final (records, weights) = await _fetchData();
      if (records.isEmpty && weights.isEmpty) {
        Get.snackbar(tr(LocaleKeys.export_pdf_title), tr(LocaleKeys.export_no_data), snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final goals = NutritionGoalsService.to.goalsForDate(DateTime.now());
      final session = SessionManager.to;
      final bytes = await ExportService.generatePdf(
        records,
        weights,
        _dateRangeLabel(),
        calorieGoal: goals.calorieGoal,
        proteinGoal: goals.proteinGoal,
        carbsGoal: goals.carbsGoal,
        fatGoal: goals.fatGoal,
        dietType: session.dietType.value?.name,
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
      Get.snackbar(tr(LocaleKeys.common_error), tr(LocaleKeys.export_error), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportCsv() async {
    isExporting.value = true;
    try {
      final (records, weights) = await _fetchData();
      if (records.isEmpty && weights.isEmpty) {
        Get.snackbar(tr(LocaleKeys.export_pdf_title), tr(LocaleKeys.export_no_data), snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final csvString = ExportService.generateCsv(records, weights);
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
      Get.snackbar(tr(LocaleKeys.common_error), tr(LocaleKeys.export_error), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isExporting.value = false;
    }
  }
}
