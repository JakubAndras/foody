import 'package:diplomka/database/entities/day_record_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class DayRecordDao {
  @Query('SELECT * FROM DayRecord')
  Stream<List<DayRecordEntity>> watchDayRecords();

  @Query('''SELECT * FROM DayRecord WHERE date = :date''')
  Future<DayRecordEntity?> findDayRecordByDate(int date);

  @Query('''SELECT * FROM DayRecord WHERE id = :id''')
  Future<DayRecordEntity?> findDayRecordById(int id);

  @Query('''SELECT * FROM DayRecord ORDER BY date DESC''')
  Future<List<DayRecordEntity>> getAllDayRecords();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDayRecord(DayRecordEntity dayRecord);

  @update
  Future<void> updateDayRecord(DayRecordEntity dayRecord);

  @delete
  Future<void> deleteDayRecord(DayRecordEntity dayRecord);
}
