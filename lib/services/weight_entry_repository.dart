import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/weight_entry_dao.dart';
import 'package:diplomka/database/entities/weight_entry_entity.dart';
import 'package:diplomka/di/providers.dart';
import 'package:diplomka/model/weight_entry.dart';

/// Perzistence vážení.
class WeightEntryRepository {
  WeightEntryRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  WeightEntryDao get _weightEntryDao => _database.weightEntryDao;

  Future<List<WeightEntry>> getAllEntries() async {
    final entities = await _weightEntryDao.getAllEntries();
    return entities
        .map(
          (entity) => WeightEntry(
            id: entity.id,
            date: entity.date,
            weight: entity.weight,
            photoPath: entity.photoPath,
          ),
        )
        .toList();
  }

  Stream<List<WeightEntry>> watchEntries() {
    return _weightEntryDao.watchEntries().map(
          (entities) => entities
              .map(
                (entity) => WeightEntry(
                  id: entity.id,
                  date: entity.date,
                  weight: entity.weight,
                  photoPath: entity.photoPath,
                ),
              )
              .toList(),
        );
  }

  Future<WeightEntry> upsertEntry(WeightEntry entry) async {
    final entity = WeightEntryEntity(
      id: entry.id,
      date: entry.date,
      weight: entry.weight,
      photoPath: entry.photoPath,
    );
    if (entry.id == null) {
      final id = await _weightEntryDao.insertEntry(entity);
      return entry.copyWith(id: id);
    }
    await _weightEntryDao.updateEntry(entity);
    return entry;
  }

  Future<void> deleteEntry(WeightEntry entry) async {
    if (entry.id == null) return;
    await _weightEntryDao.deleteEntryById(entry.id!);
  }
}

final weightEntryRepositoryProvider = Provider<WeightEntryRepository>(
  (ref) => WeightEntryRepository(database: ref.watch(databaseProvider)),
);
