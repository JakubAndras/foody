import 'package:floor/floor.dart';

@Entity(
  tableName: 'DayRecord',
  indices: [
    Index(value: ['date'], unique: true),
  ],
)
class DayRecordEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final DateTime date;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  DayRecordEntity({
    this.id,
    required this.date,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  DayRecordEntity copyWith({
    int? id,
    DateTime? date,
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) {
    return DayRecordEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
    );
  }
}
