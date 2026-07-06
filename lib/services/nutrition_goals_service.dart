import 'dart:async';

import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cache nutričních cílů podle data.
/// Stav = mapa normalizovaných dat na `NutritionGoals` (`goalsByDate`).
class NutritionGoalsNotifier extends Notifier<Map<DateTime, NutritionGoals>> {
  @override
  Map<DateTime, NutritionGoals> build() {
    unawaited(refreshForDate(ref.read(selectedDateProvider)));
    return <DateTime, NutritionGoals>{};
  }

  NutritionGoals goalsForDate(DateTime date, {DayRecord? fallbackRecord}) {
    final normalizedDate = _normalize(date);
    final cached = state[normalizedDate];
    if (cached != null) {
      return cached;
    }

    final historical = _resolveGoalsFromKnownDayRecords(normalizedDate);
    if (historical != null) {
      return historical;
    }

    if (fallbackRecord != null) {
      return NutritionGoals.fromDayRecord(fallbackRecord);
    }
    return NutritionGoals.defaults;
  }

  Future<void> refreshForDate(DateTime date) async {
    final normalizedDate = _normalize(date);
    final dayRecord = await ref.read(dayRecordProvider.notifier).getDayRecord(normalizedDate);
    if (dayRecord == null) {
      _removeDate(normalizedDate);
      return;
    }
    state = {...state, normalizedDate: NutritionGoals.fromDayRecord(dayRecord)};
  }

  void syncFromDayRecord({
    required DateTime date,
    required DayRecord? dayRecord,
  }) {
    final normalizedDate = _normalize(date);
    if (dayRecord == null) {
      _removeDate(normalizedDate);
      return;
    }
    state = {...state, normalizedDate: NutritionGoals.fromDayRecord(dayRecord)};
  }

  Future<void> saveGoalsEffectiveFromDate({
    required DateTime effectiveDate,
    required NutritionGoals goals,
  }) async {
    final normalizedEffectiveDate = _normalize(effectiveDate);
    final records = await ref.read(dayRecordProvider.notifier).getAllDayRecords();

    final futureOrTodayRecords = records.where((record) {
      final recordDate = _normalize(record.date);
      return !recordDate.isBefore(normalizedEffectiveDate);
    }).toList();

    if (!futureOrTodayRecords.any((record) => _normalize(record.date) == normalizedEffectiveDate)) {
      futureOrTodayRecords.add(DayRecord.initial(normalizedEffectiveDate));
    }

    final updatedGoals = <DateTime, NutritionGoals>{};
    for (final record in futureOrTodayRecords) {
      final normalizedDate = _normalize(record.date);
      final updatedRecord = goals.applyToDayRecord(record).copyWith(date: normalizedDate);
      await ref.read(dayRecordRepositoryProvider).upsertDayRecord(updatedRecord);
      updatedGoals[normalizedDate] = goals;
    }

    final next = {...state, ...updatedGoals};
    next.removeWhere((date, _) => date.isAfter(normalizedEffectiveDate));
    next[normalizedEffectiveDate] = goals;
    state = next;

    await ref.read(dayRecordProvider.notifier).refreshDayRecords();
  }

  void _removeDate(DateTime normalizedDate) {
    if (!state.containsKey(normalizedDate)) {
      return;
    }
    final next = {...state}..remove(normalizedDate);
    state = next;
  }

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  NutritionGoals? _resolveGoalsFromKnownDayRecords(DateTime targetDate) {
    DayRecord? bestMatch;
    for (final record in ref.read(dayRecordProvider).dayRecords) {
      final recordDate = _normalize(record.date);
      if (recordDate.isAfter(targetDate)) {
        continue;
      }
      if (bestMatch == null || recordDate.isAfter(_normalize(bestMatch.date))) {
        bestMatch = record;
      }
    }
    if (bestMatch == null) {
      return null;
    }
    return NutritionGoals.fromDayRecord(bestMatch);
  }
}

final nutritionGoalsProvider = NotifierProvider<NutritionGoalsNotifier, Map<DateTime, NutritionGoals>>(NutritionGoalsNotifier.new);
