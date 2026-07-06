import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vybrané datum napříč aplikací.
/// Stav = normalizované `DateTime` (bez času).
class SelectedDateNotifier extends Notifier<DateTime> {
  static DateTime normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  DateTime build() => normalize(DateTime.now());

  void setSelectedDate(DateTime date) => state = normalize(date);
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);
