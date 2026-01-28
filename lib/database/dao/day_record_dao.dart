import 'package:diplomka/model/day_record.dart';
import 'package:floor/floor.dart';

@dao
abstract class DayRecordDao {
  @Query('SELECT * FROM DayRecord')
  Stream<List<DayRecord>> watchDayRecords();

  @Query('''SELECT * FROM DayRecord WHERE date = :date''')
  Future<DayRecord?> findDayRecordByDate(int date);

  @Query('''SELECT * FROM DayRecord ORDER BY date DESC''')
  Future<List<DayRecord>> getAllDayRecords();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDayRecord(DayRecord dayRecord);

  @update
  Future<void> updateDayRecord(DayRecord dayRecord);

  @delete
  Future<void> deleteDayRecord(DayRecord dayRecord);
}
