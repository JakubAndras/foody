import 'package:diplomka/database/entities/weight_entry_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class WeightEntryDao {
  @Query('''SELECT * FROM WeightEntry ORDER BY date DESC''')
  Future<List<WeightEntryEntity>> getAllEntries();

  @Query('''SELECT * FROM WeightEntry ORDER BY date DESC''')
  Stream<List<WeightEntryEntity>> watchEntries();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEntry(WeightEntryEntity entry);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateEntry(WeightEntryEntity entry);

  @delete
  Future<void> deleteEntry(WeightEntryEntity entry);

  @Query('''DELETE FROM WeightEntry WHERE id = :id''')
  Future<void> deleteEntryById(int id);
}
