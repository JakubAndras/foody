import 'package:floor/floor.dart';

final Migration migration1to2 = Migration(1, 2, (database) async {
  await database.execute('DROP TABLE IF EXISTS Ingredient');
  await database.execute('DROP TABLE IF EXISTS Meal');
  await database.execute('DROP TABLE IF EXISTS DayRecord');

  await database.execute(
    'CREATE TABLE IF NOT EXISTS `DayRecord` ('
    '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '
    '`date` INTEGER NOT NULL, '
    '`calorieGoal` REAL NOT NULL, '
    '`proteinGoal` REAL NOT NULL, '
    '`carbsGoal` REAL NOT NULL, '
    '`fatGoal` REAL NOT NULL'
    ')',
  );
  await database.execute(
    'CREATE UNIQUE INDEX IF NOT EXISTS `index_DayRecord_date` ON `DayRecord` (`date`)',
  );

  await database.execute(
    'CREATE TABLE IF NOT EXISTS `Meal` ('
    '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '
    '`dayRecordId` INTEGER NOT NULL, '
    '`name` TEXT NOT NULL, '
    '`timestamp` INTEGER NOT NULL, '
    'FOREIGN KEY (`dayRecordId`) REFERENCES `DayRecord` (`id`) ON DELETE CASCADE'
    ')',
  );

  await database.execute(
    'CREATE TABLE IF NOT EXISTS `Ingredient` ('
    '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '
    '`mealId` INTEGER NOT NULL, '
    '`name` TEXT NOT NULL, '
    '`weight` REAL NOT NULL, '
    '`calories` REAL NOT NULL, '
    '`proteins` REAL NOT NULL, '
    '`carbs` REAL NOT NULL, '
    '`fats` REAL NOT NULL, '
    'FOREIGN KEY (`mealId`) REFERENCES `Meal` (`id`) ON DELETE CASCADE'
    ')',
  );
});

final Migration migration2to3 = Migration(2, 3, (database) async {
  await database.execute('ALTER TABLE `Meal` ADD COLUMN `photoPath` TEXT');
});

final Migration migration3to4 = Migration(3, 4, (database) async {
  await database.execute('ALTER TABLE `Meal` ADD COLUMN `isFavorite` INTEGER NOT NULL DEFAULT 0');
});

final Migration migration4to5 = Migration(4, 5, (database) async {
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `WeightEntry` ('
    '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '
    '`date` INTEGER NOT NULL, '
    '`weight` REAL NOT NULL'
    ')',
  );
});

final Migration migration5to6 = Migration(5, 6, (database) async {
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `Exercise` ('
    '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '
    '`dayRecordId` INTEGER NOT NULL, '
    '`name` TEXT NOT NULL, '
    '`timestamp` INTEGER NOT NULL, '
    '`durationMinutes` INTEGER, '
    '`caloriesBurned` REAL NOT NULL, '
    'FOREIGN KEY (`dayRecordId`) REFERENCES `DayRecord` (`id`) ON DELETE CASCADE'
    ')',
  );
});

final Migration migration6to7 = Migration(6, 7, (database) async {
  try {
    await database.execute('ALTER TABLE `Exercise` ADD COLUMN `isFavorite` INTEGER NOT NULL DEFAULT 0');
  } catch (_) {
    // Column may already exist if the table was created with a newer schema.
  }
});

final Migration migration7to8 = Migration(7, 8, (database) async {
  try {
    await database.execute('ALTER TABLE `Meal` ADD COLUMN `confidence` REAL');
  } catch (_) {}
  try {
    await database.execute('ALTER TABLE `Ingredient` ADD COLUMN `confidence` REAL');
  } catch (_) {}
});

final Migration migration8to9 = Migration(8, 9, (database) async {
  try {
    await database.execute('ALTER TABLE `Exercise` ADD COLUMN `source` TEXT');
  } catch (_) {}
});

final Migration migration10to11 = Migration(10, 11, (database) async {
  try {
    await database.execute('ALTER TABLE `WeightEntry` ADD COLUMN `photoPath` TEXT');
  } catch (_) {}
});

final Migration migration9to10 = Migration(9, 10, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS `MealTemplate` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `name` TEXT NOT NULL,
      `normalizedName` TEXT NOT NULL,
      `photoPath` TEXT,
      `isFavorite` INTEGER NOT NULL DEFAULT 0,
      `lastUsedAt` INTEGER NOT NULL,
      `usageCount` INTEGER NOT NULL DEFAULT 1
    )
  ''');
  await database.execute('CREATE UNIQUE INDEX IF NOT EXISTS `index_MealTemplate_normalizedName` ON `MealTemplate` (`normalizedName`)');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS `MealTemplateIngredient` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `templateId` INTEGER NOT NULL,
      `name` TEXT NOT NULL,
      `weight` REAL NOT NULL,
      `calories` REAL NOT NULL,
      `proteins` REAL NOT NULL,
      `carbs` REAL NOT NULL,
      `fats` REAL NOT NULL,
      FOREIGN KEY (`templateId`) REFERENCES `MealTemplate` (`id`) ON DELETE CASCADE
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS `ExerciseTemplate` (
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `name` TEXT NOT NULL,
      `normalizedName` TEXT NOT NULL,
      `durationMinutes` INTEGER,
      `caloriesBurned` REAL NOT NULL,
      `isFavorite` INTEGER NOT NULL DEFAULT 0,
      `lastUsedAt` INTEGER NOT NULL,
      `usageCount` INTEGER NOT NULL DEFAULT 1
    )
  ''');
  await database.execute('CREATE UNIQUE INDEX IF NOT EXISTS `index_ExerciseTemplate_normalizedName` ON `ExerciseTemplate` (`normalizedName`)');
});
