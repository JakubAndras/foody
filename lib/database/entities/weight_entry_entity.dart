import 'package:floor/floor.dart';

@Entity(tableName: 'WeightEntry')
class WeightEntryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final DateTime date;
  final double weight;
  final String? photoPath;

  WeightEntryEntity({
    this.id,
    required this.date,
    required this.weight,
    this.photoPath,
  });

  WeightEntryEntity copyWith({
    int? id,
    DateTime? date,
    double? weight,
    String? photoPath,
  }) {
    return WeightEntryEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
