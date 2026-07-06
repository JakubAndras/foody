import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/streak_service.dart';

/// Odvozený stav streak informací. Počítá se nad **všemi** záznamy dní.
///
/// Záznamy načítáme PŘÍMO z repozitáře (čistý dotaz), NE přes
/// `dayRecordProvider.notifier.getAllDayRecords()` — ta totiž volá
/// `refreshDayRecords()`, čímž mění stav `dayRecordProvider`. V kombinaci
/// s `ref.watch(dayRecordProvider)` níže by to vytvořilo nekonečnou smyčku
/// (watch → getAllDayRecords → změna stavu → invalidace → znovu…), takže by
/// streak zůstal navždy v `loading`. `ref.watch` ponecháváme jen kvůli
/// reaktivnímu přepočtu při změně záznamů.
final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  ref.watch(dayRecordProvider);
  debugPrint('[Streak] streakInfoProvider: recompute start');
  final records = await ref.read(dayRecordRepositoryProvider).getAllDayRecords();
  final info = ref.read(streakServiceProvider).calculateStreakInfo(records);
  debugPrint('[Streak] streakInfoProvider: ${records.length} records → current=${info.currentStreak}, longest=${info.longestStreak}');
  return info;
});
