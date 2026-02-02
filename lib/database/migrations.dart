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
