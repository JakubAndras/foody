import 'package:floor/floor.dart';

// v1 → v2: per-ingredient dietary_violation column.
// Free-text reason set by AI at log time (null = OK / unknown).
// Legacy rows stay null and fall back to keyword matching in DietaryViolationService.
final _migration1to2 = Migration(1, 2, (db) async {
  await db.execute('ALTER TABLE Ingredient ADD COLUMN dietaryViolation TEXT');
  await db.execute('ALTER TABLE IngredientTemplate ADD COLUMN dietaryViolation TEXT');
  await db.execute('ALTER TABLE MealTemplateIngredient ADD COLUMN dietaryViolation TEXT');
});

final List<Migration> appMigrations = [_migration1to2];
