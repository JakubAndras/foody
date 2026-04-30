import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/utils/app_limits.dart';

class Meal {
  final int? id;
  final int? dayRecordId;
  final String name;
  final List<Ingredient> ingredients;
  final DateTime timestamp;
  final String? photoPath;
  final bool isFavorite;
  final double? confidence;
  final String? barcode;

  // RESEARCH-ONLY: all fields below are research-only. Mirror MealEntity
  // telemetry. Remove with the entity columns. See RESEARCH_ONLY.md.
  final String? inputSource;
  final String? aiProvider;
  final String? aiModel;
  final String? aiOriginalName;
  final double? aiOriginalCalories;
  final double? aiOriginalProteins;
  final double? aiOriginalCarbs;
  final double? aiOriginalFats;
  final double? aiOriginalConfidence;
  final bool wasEditedByUser;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  // RESEARCH-ONLY: end

  Meal({
    this.id,
    this.dayRecordId,
    required this.name,
    required this.ingredients,
    required this.timestamp,
    this.photoPath,
    this.isFavorite = false,
    this.confidence,
    this.barcode,
    // RESEARCH-ONLY: research-only ctor params below
    this.inputSource,
    this.aiProvider,
    this.aiModel,
    this.aiOriginalName,
    this.aiOriginalCalories,
    this.aiOriginalProteins,
    this.aiOriginalCarbs,
    this.aiOriginalFats,
    this.aiOriginalConfidence,
    this.wasEditedByUser = false,
    this.editedAt,
    this.deletedAt,
  });

  // Factory constructor for creating a new Meal instance from a map.
  factory Meal.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List;
    List<Ingredient> ingredients = ingredientsList.map((i) => Ingredient.fromJson(i as Map<String, dynamic>)).toList();
    return Meal(
      id: json['id'] as int?,
      dayRecordId: json['dayRecordId'] as int?,
      name: json['name'] as String,
      ingredients: ingredients,
      timestamp: DateTime.parse(json['timestamp'] as String),
      photoPath: json['photoPath'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
      // RESEARCH-ONLY: research-only fromJson fields below
      inputSource: json['inputSource'] as String?,
      aiProvider: json['aiProvider'] as String?,
      aiModel: json['aiModel'] as String?,
      aiOriginalName: json['aiOriginalName'] as String?,
      aiOriginalCalories: (json['aiOriginalCalories'] as num?)?.toDouble(),
      aiOriginalProteins: (json['aiOriginalProteins'] as num?)?.toDouble(),
      aiOriginalCarbs: (json['aiOriginalCarbs'] as num?)?.toDouble(),
      aiOriginalFats: (json['aiOriginalFats'] as num?)?.toDouble(),
      aiOriginalConfidence: (json['aiOriginalConfidence'] as num?)?.toDouble(),
      wasEditedByUser: json['wasEditedByUser'] == true || json['wasEditedByUser'] == 1,
      editedAt: json['editedAt'] != null ? DateTime.tryParse(json['editedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt'] as String) : null,
    );
  }

  // Factory constructor for creating a new Meal instance from an Answer object.
  // RESEARCH-ONLY: this factory also populates aiOriginal* snapshot fields
  // so the long-term test can later detect user edits. When stripping
  // telemetry, simplify back to the pre-thesis form (no aiOriginal* args on
  // Ingredient or on the returned Meal). See RESEARCH_ONLY.md.
  factory Meal.fromAnswer(Answer answer) {
    final snappedAmount = _snapToFraction(answer.amount.clamp(0.0, 100.875));

    List<Ingredient> ingredients = answer.ingredients.map((ingResponse) {
      double weight = ingResponse.weightGrams ?? 0.0;
      // Fallback: parse weight from quantity string if AI didn't provide weight_grams
      if (weight <= 0) {
        final RegExp numRegExp = RegExp(r'\d+(\.\d+)?');
        final Match? match = numRegExp.firstMatch(ingResponse.quantity);
        if (match != null) {
          weight = double.tryParse(match.group(0)!) ?? 0.0;
        }
      }

      final clampedCalories = ingResponse.nutritionalValues.calories.toDouble().clamp(0, AppLimits.ingredientMaxCalories.toDouble()).toDouble();
      final clampedProteins = ingResponse.nutritionalValues.proteins.clamp(0, AppLimits.ingredientMaxMacro.toDouble()).toDouble();
      final clampedCarbs = ingResponse.nutritionalValues.carbs.clamp(0, AppLimits.ingredientMaxMacro.toDouble()).toDouble();
      final clampedFats = ingResponse.nutritionalValues.fats.clamp(0, AppLimits.ingredientMaxMacro.toDouble()).toDouble();

      return Ingredient(
        name: ingResponse.name,
        weight: weight,
        amount: snappedAmount,
        calories: clampedCalories,
        proteins: clampedProteins,
        carbs: clampedCarbs,
        fats: clampedFats,
        confidence: ingResponse.confidence,
        aiOriginalName: ingResponse.name,
        aiOriginalWeight: weight,
        aiOriginalAmount: snappedAmount,
        aiOriginalCalories: clampedCalories,
        aiOriginalProteins: clampedProteins,
        aiOriginalCarbs: clampedCarbs,
        aiOriginalFats: clampedFats,
        aiOriginalConfidence: ingResponse.confidence,
      );
    }).toList();

    final totalCalories = ingredients.fold<double>(0, (s, i) => s + i.calories);
    final totalProteins = ingredients.fold<double>(0, (s, i) => s + i.proteins);
    final totalCarbs = ingredients.fold<double>(0, (s, i) => s + i.carbs);
    final totalFats = ingredients.fold<double>(0, (s, i) => s + i.fats);

    return Meal(
      name: answer.name,
      ingredients: ingredients,
      timestamp: DateTime.now(),
      confidence: answer.confidence,
      aiOriginalName: answer.name,
      aiOriginalCalories: totalCalories,
      aiOriginalProteins: totalProteins,
      aiOriginalCarbs: totalCarbs,
      aiOriginalFats: totalFats,
      aiOriginalConfidence: answer.confidence,
    );
  }

  /// Snaps a double to the nearest supported whole + fraction value.
  /// Supported fractions: 0, ⅛(0.125), ¼(0.25), ⅓(0.333), ⅜(0.375), ½(0.5), ⅔(0.667), ⅝(0.625), ¾(0.75), ⅞(0.875).
  static double _snapToFraction(double value) {
    if (value <= 0) return 0.125; // minimum allowed amount
    const fractions = [0.0, 0.125, 0.25, 1 / 3, 0.375, 0.5, 2 / 3, 0.625, 0.75, 0.875];
    final whole = value.truncate();
    final frac = value - whole;
    double bestFrac = 0;
    double bestDiff = double.infinity;
    for (final f in fractions) {
      final diff = (frac - f).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestFrac = f;
      }
    }
    final result = whole + bestFrac;
    return result <= 0 ? 0.125 : result;
  }

  // Method for converting a Meal instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayRecordId': dayRecordId,
      'name': name,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'photoPath': photoPath,
      'isFavorite': isFavorite,
      'confidence': confidence,
      'barcode': barcode,
      // RESEARCH-ONLY: research-only toJson fields below
      'inputSource': inputSource,
      'aiProvider': aiProvider,
      'aiModel': aiModel,
      'aiOriginalName': aiOriginalName,
      'aiOriginalCalories': aiOriginalCalories,
      'aiOriginalProteins': aiOriginalProteins,
      'aiOriginalCarbs': aiOriginalCarbs,
      'aiOriginalFats': aiOriginalFats,
      'aiOriginalConfidence': aiOriginalConfidence,
      'wasEditedByUser': wasEditedByUser,
      'editedAt': editedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  Meal copyWith({
    int? id,
    int? dayRecordId,
    String? name,
    List<Ingredient>? ingredients,
    DateTime? timestamp,
    String? photoPath,
    bool clearPhotoPath = false,
    bool? isFavorite,
    double? confidence,
    String? barcode,
    // RESEARCH-ONLY: research-only copyWith params below
    String? inputSource,
    String? aiProvider,
    String? aiModel,
    String? aiOriginalName,
    double? aiOriginalCalories,
    double? aiOriginalProteins,
    double? aiOriginalCarbs,
    double? aiOriginalFats,
    double? aiOriginalConfidence,
    bool? wasEditedByUser,
    DateTime? editedAt,
    DateTime? deletedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      dayRecordId: dayRecordId ?? this.dayRecordId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      timestamp: timestamp ?? this.timestamp,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
      barcode: barcode ?? this.barcode,
      inputSource: inputSource ?? this.inputSource,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
      aiOriginalName: aiOriginalName ?? this.aiOriginalName,
      aiOriginalCalories: aiOriginalCalories ?? this.aiOriginalCalories,
      aiOriginalProteins: aiOriginalProteins ?? this.aiOriginalProteins,
      aiOriginalCarbs: aiOriginalCarbs ?? this.aiOriginalCarbs,
      aiOriginalFats: aiOriginalFats ?? this.aiOriginalFats,
      aiOriginalConfidence: aiOriginalConfidence ?? this.aiOriginalConfidence,
      wasEditedByUser: wasEditedByUser ?? this.wasEditedByUser,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  double get totalCalories =>
      ingredients.fold(0, (sum, item) => sum + item.calories);
  double get totalProteins =>
      ingredients.fold(0, (sum, item) => sum + item.proteins);
  double get totalCarbs =>
      ingredients.fold(0, (sum, item) => sum + item.carbs);
  double get totalFats => ingredients.fold(0, (sum, item) => sum + item.fats);
  double get totalWeight => ingredients.fold(0, (sum, item) => sum + item.weight);
}
