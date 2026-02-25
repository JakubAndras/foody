import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/exercise.dart';

class DayRecord {
  final int? id;
  final DateTime date;
  final List<Meal> meals;
  final List<Exercise> exercises;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  DayRecord({
    this.id,
    required this.date,
    required this.meals,
    this.exercises = const [],
    this.calorieGoal = 2000, // Default calorie goal
    this.proteinGoal = 150, // Default protein goal
    this.carbsGoal = 250, // Default carbs goal
    this.fatGoal = 70, // Default fat goal
  });

  factory DayRecord.initial(DateTime date) {
    return DayRecord(
      date: date,
      meals: [],
      exercises: const [],
    );
  }

  // Factory constructor for creating a new DayRecord instance from a map (used for export/import).
  factory DayRecord.fromJson(Map<String, dynamic> json) {
    var mealsList = json['meals'] as List;
    var exercisesList = (json['exercises'] as List?) ?? const [];
    List<Meal> meals = mealsList.map((i) => Meal.fromJson(i as Map<String, dynamic>)).toList();
    List<Exercise> exercises = exercisesList.map((i) => Exercise.fromJson(i as Map<String, dynamic>)).toList();
    return DayRecord(
      id: json['id'] as int?,
      date: DateTime.parse(json['date'] as String),
      meals: meals,
      exercises: exercises,
      calorieGoal: (json['calorieGoal'] as num).toDouble(),
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      carbsGoal: (json['carbsGoal'] as num).toDouble(),
      fatGoal: (json['fatGoal'] as num).toDouble(),
    );
  }

  // Method for converting a DayRecord instance to a map (used for export/import).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
    };
  }

  DayRecord copyWith({
    int? id,
    DateTime? date,
    List<Meal>? meals,
    List<Exercise>? exercises,
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) {
    return DayRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      exercises: exercises ?? this.exercises,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
    );
  }

  double get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  }

  double get totalProteins {
    return meals.fold(0, (sum, meal) => sum + meal.totalProteins);
  }

  double get totalCarbs {
    return meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  }

  double get totalFats {
    return meals.fold(0, (sum, meal) => sum + meal.totalFats);
  }

  double get totalExerciseCalories {
    return exercises.fold(0, (sum, exercise) => sum + exercise.caloriesBurned);
  }

  double get netCalories {
    return totalCalories - totalExerciseCalories;
  }

  double get caloriesLeft {
    return calorieGoal - netCalories;
  }

  double get proteinsLeft {
    return proteinGoal - totalProteins;
  }

  double get carbsLeft {
    return carbsGoal - totalCarbs;
  }

  double get fatsLeft {
    return fatGoal - totalFats;
  }
}
