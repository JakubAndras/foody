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

  // RESEARCH-ONLY: all fields below are research-only. Drop columns
  // (`inputSource`, `aiProvider`, `aiModel`, `aiOriginal*`, `wasEditedByUser`,
  // `editedAtMs`, `deletedAtMs`) and constructor params before production. See
  // RESEARCH_ONLY.md.
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
  final int? editedAtMs;
  final int? deletedAtMs;
  // RESEARCH-ONLY: end

  MealEntity({
    this.id,
    required this.dayRecordId,
    required this.name,
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
    this.editedAtMs,
    this.deletedAtMs,
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
    int? editedAtMs,
    int? deletedAtMs,
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
      editedAtMs: editedAtMs ?? this.editedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
    );
  }
}
