import 'package:floor/floor.dart';

import 'day_record_entity.dart';

@Entity(
  tableName: 'Exercise',
  foreignKeys: [
    ForeignKey(
      childColumns: ['dayRecordId'],
      parentColumns: ['id'],
      entity: DayRecordEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class ExerciseEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int dayRecordId;
  final String name;
  final DateTime timestamp;
  final int? durationMinutes;
  final double caloriesBurned;
  final bool isFavorite;
  final String? source;

  ExerciseEntity({
    this.id,
    required this.dayRecordId,
    required this.name,
    required this.timestamp,
    this.durationMinutes,
    required this.caloriesBurned,
    this.isFavorite = false,
    this.source,
  });
}
