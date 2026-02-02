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
    this.calorieGoal = 2000,
    this.proteinGoal = 150,
    this.carbsGoal = 250,
    this.fatGoal = 70,
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
