import 'package:floor/floor.dart';

import 'day_record_entity.dart';

@Entity(
  tableName: 'Meal',
  foreignKeys: [
    ForeignKey(
      childColumns: ['dayRecordId'],
      parentColumns: ['id'],
      entity: DayRecordEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class MealEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int dayRecordId;
  final String name;
  final DateTime timestamp;
  final String? photoPath;
  final bool isFavorite;
  final double? confidence;
  final String? barcode;

  MealEntity({
    this.id,
    required this.dayRecordId,
    required this.name,
    required this.timestamp,
    this.photoPath,
    this.isFavorite = false,
    this.confidence,
    this.barcode,
  });

  MealEntity copyWith({
    int? id,
    int? dayRecordId,
    String? name,
    DateTime? timestamp,
    String? photoPath,
    bool? isFavorite,
    double? confidence,
    String? barcode,
  }) {
    return MealEntity(
      id: id ?? this.id,
      dayRecordId: dayRecordId ?? this.dayRecordId,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      photoPath: photoPath ?? this.photoPath,
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
      barcode: barcode ?? this.barcode,
    );
  }
}
