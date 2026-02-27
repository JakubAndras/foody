import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/services/streak_service.dart';

import 'base_controller.dart';

class StreakController extends BaseController {
  static StreakController get to => Get.find();

  StreakController({
    DayRecordController? dayRecordController,
    StreakService? streakService,
  })  : _dayRecordController = dayRecordController ?? DayRecordController.to,
        _streakService = streakService ?? StreakService.to;

  final DayRecordController _dayRecordController;
  final StreakService _streakService;

  StreakInfo calculateFromRecords(Iterable<DayRecord> records) {
    return _streakService.calculateStreakInfo(records);
  }

  // Calculates streak information.
  Future<StreakInfo> getStreakInfo() async {
    try {
      final List<DayRecord> allRecordsRaw = await _dayRecordController.getAllDayRecords();
      return _streakService.calculateStreakInfo(allRecordsRaw);
    } catch (e) {
      // Log the error and return initial/empty state or rethrow a custom exception
      debugPrint('Error calculating streak info: $e');
      // Consider returning StreakInfo.initial() or a specific error state
      // depending on how you want the UI to react.
      return StreakInfo.initial(); // Fallback to initial state on error
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
