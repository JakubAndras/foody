import 'package:diplomka/services/background_task_service.dart';

/// Sdílený pomocník pro řízení viditelnosti načítacího indikátoru.
///
/// Vytaženo z původního `DashboardController` (GetX), kde stejná logika
/// existovala zvlášť pro analýzu jídel a cvičení (`_beginMealAnalysis`/
/// `_endMealAnalysis` a jejich cvičební varianty). Bez jakékoli závislosti na
/// GetX. Každý notifier drží vlastní instanci (jídla / cvičení).
///
/// Zajišťuje dvě věci:
///  * počítá souběžně běžící analýzy (`_active`), takže indikátor zůstává
///    viditelný, dokud běží alespoň jedna,
///  * garantuje minimální dobu viditelnosti ([minVisible], výchozí 900 ms),
///    aby indikátor u rychlých operací neproblikl.
class LoadingVisibilityTracker {
  LoadingVisibilityTracker({this.minVisible = const Duration(milliseconds: 900)});

  final Duration minVisible;

  int _active = 0;
  DateTime? _startedAt;

  /// Zahájí jednu analýzu. Vrací `true` = indikátor má být viditelný.
  /// Volající tuto hodnotu promítne do svého stavu.
  bool begin() {
    _active += 1;
    _startedAt ??= DateTime.now();
    BackgroundTaskService.begin();
    return true;
  }

  /// Ukončí jednu analýzu. Pokud stále běží další, vrací `true` (indikátor
  /// zůstává). Jinak dorovná minimální dobu viditelnosti a vrací `false`.
  Future<bool> end() async {
    if (_active > 0) {
      _active -= 1;
    }

    if (_active > 0) {
      return true;
    }

    final startedAt = _startedAt;
    if (startedAt != null) {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < minVisible) {
        await Future<void>.delayed(minVisible - elapsed);
      }
    }

    _startedAt = null;
    BackgroundTaskService.end();
    return false;
  }
}
