import 'dart:io';

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/export/export_service.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/services/weight_entry_repository.dart';
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

  String _dateRangeLabel() {
    final fmt = DateFormat('MMM d, yyyy');
    final (start, end) = _resolveDateRange();
    if (selectedRange.value == ExportDateRange.allTime) return 'All Time';
    return '${fmt.format(start)} – ${fmt.format(end)}';
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
      final bytes = await ExportService.generatePdf(records, weights, _dateRangeLabel());
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/foody_report.pdf');
      await file.writeAsBytes(bytes);
      await AppShareService.share(
        request: AppShareRequest(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Foody Nutrition Report',
        ),
      );
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportCsv() async {
    isExporting.value = true;
    try {
      final (records, weights) = await _fetchData();
      final csvString = ExportService.generateCsv(records, weights);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/foody_report.csv');
      await file.writeAsString(csvString);
      await AppShareService.share(
        request: AppShareRequest(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Foody Nutrition Report',
        ),
      );
    } finally {
      isExporting.value = false;
    }
  }
}
