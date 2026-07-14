import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/weight_entry_repository.dart';

/// Reaktivní seznam vážení.
/// Stav je `AsyncValue<List<WeightEntry>>` — `build()` provede iniciální načtení,
/// mutace zapíší do repozitáře a znovu načtou stav.
class WeightEntriesNotifier extends AsyncNotifier<List<WeightEntry>> {
  @override
  Future<List<WeightEntry>> build() => ref.watch(weightEntryRepositoryProvider).getAllEntries();

  Future<void> saveEntry(WeightEntry entry) async {
    await ref.read(weightEntryRepositoryProvider).upsertEntry(entry);
    state = await AsyncValue.guard(() => ref.read(weightEntryRepositoryProvider).getAllEntries());
  }

  Future<void> deleteEntry(WeightEntry entry) async {
    await ref.read(weightEntryRepositoryProvider).deleteEntry(entry);
    state = await AsyncValue.guard(() => ref.read(weightEntryRepositoryProvider).getAllEntries());
  }
}

final weightEntriesProvider = AsyncNotifierProvider<WeightEntriesNotifier, List<WeightEntry>>(WeightEntriesNotifier.new);

/// Odvozený stav: poslední (nejnovější) záznam nebo null. Nahrazuje getter `latestEntry`.
final latestWeightEntryProvider = Provider<WeightEntry?>(
  (ref) => ref.watch(weightEntriesProvider).value?.firstOrNull,
);
