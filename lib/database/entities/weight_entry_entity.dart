import 'package:floor/floor.dart';

@Entity(tableName: 'WeightEntry')
class WeightEntryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final DateTime date;
  final double weight;

  WeightEntryEntity({
    this.id,
    required this.date,
    required this.weight,
  });

  WeightEntryEntity copyWith({
    int? id,
    DateTime? date,
    double? weight,
  }) {
    return WeightEntryEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
    );
  }
}
