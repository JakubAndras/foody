// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  DayRecordDao? _dayRecordDaoInstance;

  MealDao? _mealDaoInstance;

  IngredientDao? _ingredientDaoInstance;

  WeightEntryDao? _weightEntryDaoInstance;

  ExerciseDao? _exerciseDaoInstance;

  MealTemplateDao? _mealTemplateDaoInstance;

  MealTemplateIngredientDao? _mealTemplateIngredientDaoInstance;

  ExerciseTemplateDao? _exerciseTemplateDaoInstance;

  IngredientTemplateDao? _ingredientTemplateDaoInstance;

  AiAttemptDao? _aiAttemptDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DayRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `date` INTEGER NOT NULL, `calorieGoal` REAL NOT NULL, `proteinGoal` REAL NOT NULL, `carbsGoal` REAL NOT NULL, `fatGoal` REAL NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Meal` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `dayRecordId` INTEGER NOT NULL, `name` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `photoPath` TEXT, `isFavorite` INTEGER NOT NULL, `confidence` REAL, `barcode` TEXT, `inputSource` TEXT, `aiProvider` TEXT, `aiModel` TEXT, `aiOriginalName` TEXT, `aiOriginalCalories` REAL, `aiOriginalProteins` REAL, `aiOriginalCarbs` REAL, `aiOriginalFats` REAL, `aiOriginalConfidence` REAL, `wasEditedByUser` INTEGER NOT NULL, `editedAtMs` INTEGER, `deletedAtMs` INTEGER, FOREIGN KEY (`dayRecordId`) REFERENCES `DayRecord` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Ingredient` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mealId` INTEGER NOT NULL, `name` TEXT NOT NULL, `weight` REAL NOT NULL, `amount` REAL, `calories` REAL NOT NULL, `proteins` REAL NOT NULL, `carbs` REAL NOT NULL, `fats` REAL NOT NULL, `confidence` REAL, `isFavorite` INTEGER NOT NULL, `aiOriginalName` TEXT, `aiOriginalWeight` REAL, `aiOriginalAmount` REAL, `aiOriginalCalories` REAL, `aiOriginalProteins` REAL, `aiOriginalCarbs` REAL, `aiOriginalFats` REAL, `aiOriginalConfidence` REAL, `wasEditedByUser` INTEGER NOT NULL, `deletedAtMs` INTEGER, FOREIGN KEY (`mealId`) REFERENCES `Meal` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `WeightEntry` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `date` INTEGER NOT NULL, `weight` REAL NOT NULL, `photoPath` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Exercise` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `dayRecordId` INTEGER NOT NULL, `name` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `durationMinutes` INTEGER, `caloriesBurned` REAL NOT NULL, `isFavorite` INTEGER NOT NULL, `source` TEXT, `confidence` REAL, FOREIGN KEY (`dayRecordId`) REFERENCES `DayRecord` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MealTemplate` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `normalizedName` TEXT NOT NULL, `photoPath` TEXT, `isFavorite` INTEGER NOT NULL, `lastUsedAt` INTEGER NOT NULL, `usageCount` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MealTemplateIngredient` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `templateId` INTEGER NOT NULL, `name` TEXT NOT NULL, `weight` REAL NOT NULL, `calories` REAL NOT NULL, `proteins` REAL NOT NULL, `carbs` REAL NOT NULL, `fats` REAL NOT NULL, FOREIGN KEY (`templateId`) REFERENCES `MealTemplate` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ExerciseTemplate` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `normalizedName` TEXT NOT NULL, `durationMinutes` INTEGER, `caloriesBurned` REAL NOT NULL, `isFavorite` INTEGER NOT NULL, `lastUsedAt` INTEGER NOT NULL, `usageCount` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `IngredientTemplate` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `normalizedName` TEXT NOT NULL, `weight` REAL NOT NULL, `amount` REAL NOT NULL, `calories` REAL NOT NULL, `proteins` REAL NOT NULL, `carbs` REAL NOT NULL, `fats` REAL NOT NULL, `isFavorite` INTEGER NOT NULL, `lastUsedAt` INTEGER NOT NULL, `usageCount` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AiAttempt` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `timestampMs` INTEGER NOT NULL, `kind` TEXT NOT NULL, `modality` TEXT, `provider` TEXT, `model` TEXT, `status` TEXT NOT NULL, `confidence` REAL, `errorMessage` TEXT)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_DayRecord_date` ON `DayRecord` (`date`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_MealTemplate_normalizedName` ON `MealTemplate` (`normalizedName`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_ExerciseTemplate_normalizedName` ON `ExerciseTemplate` (`normalizedName`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_IngredientTemplate_normalizedName` ON `IngredientTemplate` (`normalizedName`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  DayRecordDao get dayRecordDao {
    return _dayRecordDaoInstance ??= _$DayRecordDao(database, changeListener);
  }

  @override
  MealDao get mealDao {
    return _mealDaoInstance ??= _$MealDao(database, changeListener);
  }

  @override
  IngredientDao get ingredientDao {
    return _ingredientDaoInstance ??= _$IngredientDao(database, changeListener);
  }

  @override
  WeightEntryDao get weightEntryDao {
    return _weightEntryDaoInstance ??=
        _$WeightEntryDao(database, changeListener);
  }

  @override
  ExerciseDao get exerciseDao {
    return _exerciseDaoInstance ??= _$ExerciseDao(database, changeListener);
  }

  @override
  MealTemplateDao get mealTemplateDao {
    return _mealTemplateDaoInstance ??=
        _$MealTemplateDao(database, changeListener);
  }

  @override
  MealTemplateIngredientDao get mealTemplateIngredientDao {
    return _mealTemplateIngredientDaoInstance ??=
        _$MealTemplateIngredientDao(database, changeListener);
  }

  @override
  ExerciseTemplateDao get exerciseTemplateDao {
    return _exerciseTemplateDaoInstance ??=
        _$ExerciseTemplateDao(database, changeListener);
  }

  @override
  IngredientTemplateDao get ingredientTemplateDao {
    return _ingredientTemplateDaoInstance ??=
        _$IngredientTemplateDao(database, changeListener);
  }

  @override
  AiAttemptDao get aiAttemptDao {
    return _aiAttemptDaoInstance ??= _$AiAttemptDao(database, changeListener);
  }
}

class _$DayRecordDao extends DayRecordDao {
  _$DayRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _dayRecordEntityInsertionAdapter = InsertionAdapter(
            database,
            'DayRecord',
            (DayRecordEntity item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'calorieGoal': item.calorieGoal,
                  'proteinGoal': item.proteinGoal,
                  'carbsGoal': item.carbsGoal,
                  'fatGoal': item.fatGoal
                },
            changeListener),
        _dayRecordEntityUpdateAdapter = UpdateAdapter(
            database,
            'DayRecord',
            ['id'],
            (DayRecordEntity item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'calorieGoal': item.calorieGoal,
                  'proteinGoal': item.proteinGoal,
                  'carbsGoal': item.carbsGoal,
                  'fatGoal': item.fatGoal
                },
            changeListener),
        _dayRecordEntityDeletionAdapter = DeletionAdapter(
            database,
            'DayRecord',
            ['id'],
            (DayRecordEntity item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'calorieGoal': item.calorieGoal,
                  'proteinGoal': item.proteinGoal,
                  'carbsGoal': item.carbsGoal,
                  'fatGoal': item.fatGoal
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DayRecordEntity> _dayRecordEntityInsertionAdapter;

  final UpdateAdapter<DayRecordEntity> _dayRecordEntityUpdateAdapter;

  final DeletionAdapter<DayRecordEntity> _dayRecordEntityDeletionAdapter;

  @override
  Stream<List<DayRecordEntity>> watchDayRecords() {
    return _queryAdapter.queryListStream('SELECT * FROM DayRecord',
        mapper: (Map<String, Object?> row) => DayRecordEntity(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double),
        queryableName: 'DayRecord',
        isView: false);
  }

  @override
  Future<DayRecordEntity?> findDayRecordByDate(int date) async {
    return _queryAdapter.query('SELECT * FROM DayRecord WHERE date = ?1',
        mapper: (Map<String, Object?> row) => DayRecordEntity(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double),
        arguments: [date]);
  }

  @override
  Future<DayRecordEntity?> findDayRecordById(int id) async {
    return _queryAdapter.query('SELECT * FROM DayRecord WHERE id = ?1',
        mapper: (Map<String, Object?> row) => DayRecordEntity(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double),
        arguments: [id]);
  }

  @override
  Future<List<DayRecordEntity>> getAllDayRecords() async {
    return _queryAdapter.queryList('SELECT * FROM DayRecord ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => DayRecordEntity(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double));
  }

  @override
  Future<int> insertDayRecord(DayRecordEntity dayRecord) {
    return _dayRecordEntityInsertionAdapter.insertAndReturnId(
        dayRecord, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateDayRecord(DayRecordEntity dayRecord) async {
    await _dayRecordEntityUpdateAdapter.update(
        dayRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDayRecord(DayRecordEntity dayRecord) async {
    await _dayRecordEntityDeletionAdapter.delete(dayRecord);
  }
}

class _$MealDao extends MealDao {
  _$MealDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mealEntityInsertionAdapter = InsertionAdapter(
            database,
            'Meal',
            (MealEntity item) => <String, Object?>{
                  'id': item.id,
                  'dayRecordId': item.dayRecordId,
                  'name': item.name,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'photoPath': item.photoPath,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'confidence': item.confidence,
                  'barcode': item.barcode,
                  'inputSource': item.inputSource,
                  'aiProvider': item.aiProvider,
                  'aiModel': item.aiModel,
                  'aiOriginalName': item.aiOriginalName,
                  'aiOriginalCalories': item.aiOriginalCalories,
                  'aiOriginalProteins': item.aiOriginalProteins,
                  'aiOriginalCarbs': item.aiOriginalCarbs,
                  'aiOriginalFats': item.aiOriginalFats,
                  'aiOriginalConfidence': item.aiOriginalConfidence,
                  'wasEditedByUser': item.wasEditedByUser ? 1 : 0,
                  'editedAtMs': item.editedAtMs,
                  'deletedAtMs': item.deletedAtMs
                }),
        _mealEntityUpdateAdapter = UpdateAdapter(
            database,
            'Meal',
            ['id'],
            (MealEntity item) => <String, Object?>{
                  'id': item.id,
                  'dayRecordId': item.dayRecordId,
                  'name': item.name,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'photoPath': item.photoPath,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'confidence': item.confidence,
                  'barcode': item.barcode,
                  'inputSource': item.inputSource,
                  'aiProvider': item.aiProvider,
                  'aiModel': item.aiModel,
                  'aiOriginalName': item.aiOriginalName,
                  'aiOriginalCalories': item.aiOriginalCalories,
                  'aiOriginalProteins': item.aiOriginalProteins,
                  'aiOriginalCarbs': item.aiOriginalCarbs,
                  'aiOriginalFats': item.aiOriginalFats,
                  'aiOriginalConfidence': item.aiOriginalConfidence,
                  'wasEditedByUser': item.wasEditedByUser ? 1 : 0,
                  'editedAtMs': item.editedAtMs,
                  'deletedAtMs': item.deletedAtMs
                }),
        _mealEntityDeletionAdapter = DeletionAdapter(
            database,
            'Meal',
            ['id'],
            (MealEntity item) => <String, Object?>{
                  'id': item.id,
                  'dayRecordId': item.dayRecordId,
                  'name': item.name,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'photoPath': item.photoPath,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'confidence': item.confidence,
                  'barcode': item.barcode,
                  'inputSource': item.inputSource,
                  'aiProvider': item.aiProvider,
                  'aiModel': item.aiModel,
                  'aiOriginalName': item.aiOriginalName,
                  'aiOriginalCalories': item.aiOriginalCalories,
                  'aiOriginalProteins': item.aiOriginalProteins,
                  'aiOriginalCarbs': item.aiOriginalCarbs,
                  'aiOriginalFats': item.aiOriginalFats,
                  'aiOriginalConfidence': item.aiOriginalConfidence,
                  'wasEditedByUser': item.wasEditedByUser ? 1 : 0,
                  'editedAtMs': item.editedAtMs,
                  'deletedAtMs': item.deletedAtMs
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MealEntity> _mealEntityInsertionAdapter;

  final UpdateAdapter<MealEntity> _mealEntityUpdateAdapter;

  final DeletionAdapter<MealEntity> _mealEntityDeletionAdapter;

  @override
  Future<List<MealEntity>> findMealsForDayRecord(int dayRecordId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Meal WHERE dayRecordId = ?1 AND deletedAtMs IS NULL',
        mapper: (Map<String, Object?> row) => MealEntity(
            id: row['id'] as int?,
            dayRecordId: row['dayRecordId'] as int,
            name: row['name'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int),
            photoPath: row['photoPath'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            confidence: row['confidence'] as double?,
            barcode: row['barcode'] as String?,
            inputSource: row['inputSource'] as String?,
            aiProvider: row['aiProvider'] as String?,
            aiModel: row['aiModel'] as String?,
            aiOriginalName: row['aiOriginalName'] as String?,
            aiOriginalCalories: row['aiOriginalCalories'] as double?,
            aiOriginalProteins: row['aiOriginalProteins'] as double?,
            aiOriginalCarbs: row['aiOriginalCarbs'] as double?,
            aiOriginalFats: row['aiOriginalFats'] as double?,
            aiOriginalConfidence: row['aiOriginalConfidence'] as double?,
            wasEditedByUser: (row['wasEditedByUser'] as int) != 0,
            editedAtMs: row['editedAtMs'] as int?,
            deletedAtMs: row['deletedAtMs'] as int?),
        arguments: [dayRecordId]);
  }

  @override
  Future<List<MealEntity>> findAllMealsForDayRecordIncludingDeleted(
      int dayRecordId) async {
    return _queryAdapter.queryList('SELECT * FROM Meal WHERE dayRecordId = ?1',
        mapper: (Map<String, Object?> row) => MealEntity(
            id: row['id'] as int?,
            dayRecordId: row['dayRecordId'] as int,
            name: row['name'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int),
            photoPath: row['photoPath'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            confidence: row['confidence'] as double?,
            barcode: row['barcode'] as String?,
            inputSource: row['inputSource'] as String?,
            aiProvider: row['aiProvider'] as String?,
            aiModel: row['aiModel'] as String?,
            aiOriginalName: row['aiOriginalName'] as String?,
            aiOriginalCalories: row['aiOriginalCalories'] as double?,
            aiOriginalProteins: row['aiOriginalProteins'] as double?,
            aiOriginalCarbs: row['aiOriginalCarbs'] as double?,
            aiOriginalFats: row['aiOriginalFats'] as double?,
            aiOriginalConfidence: row['aiOriginalConfidence'] as double?,
            wasEditedByUser: (row['wasEditedByUser'] as int) != 0,
            editedAtMs: row['editedAtMs'] as int?,
            deletedAtMs: row['deletedAtMs'] as int?),
        arguments: [dayRecordId]);
  }

  @override
  Future<MealEntity?> findMealById(int id) async {
    return _queryAdapter.query('SELECT * FROM Meal WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MealEntity(
            id: row['id'] as int?,
            dayRecordId: row['dayRecordId'] as int,
            name: row['name'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int),
            photoPath: row['photoPath'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            confidence: row['confidence'] as double?,
            barcode: row['barcode'] as String?,
            inputSource: row['inputSource'] as String?,
            aiProvider: row['aiProvider'] as String?,
            aiModel: row['aiModel'] as String?,
            aiOriginalName: row['aiOriginalName'] as String?,
            aiOriginalCalories: row['aiOriginalCalories'] as double?,
            aiOriginalProteins: row['aiOriginalProteins'] as double?,
            aiOriginalCarbs: row['aiOriginalCarbs'] as double?,
            aiOriginalFats: row['aiOriginalFats'] as double?,
            aiOriginalConfidence: row['aiOriginalConfidence'] as double?,
            wasEditedByUser: (row['wasEditedByUser'] as int) != 0,
            editedAtMs: row['editedAtMs'] as int?,
            deletedAtMs: row['deletedAtMs'] as int?),
        arguments: [id]);
  }

  @override
  Future<void> deleteMealById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Meal WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteMealsForDayRecord(int dayRecordId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Meal WHERE dayRecordId = ?1',
        arguments: [dayRecordId]);
  }

  @override
  Future<void> softDeleteMealById(
    int id,
    int deletedAtMs,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Meal SET deletedAtMs = ?2 WHERE id = ?1',
        arguments: [id, deletedAtMs]);
  }

  @override
  Future<int> insertMeal(MealEntity meal) {
    return _mealEntityInsertionAdapter.insertAndReturnId(
        meal, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertMeals(List<MealEntity> meals) {
    return _mealEntityInsertionAdapter.insertListAndReturnIds(
        meals, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMeal(MealEntity meal) async {
    await _mealEntityUpdateAdapter.update(meal, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMeal(MealEntity meal) async {
    await _mealEntityDeletionAdapter.delete(meal);
  }
}

class _$IngredientDao extends IngredientDao {
  _$IngredientDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _ingredientEntityInsertionAdapter = InsertionAdapter(
            database,
            'Ingredient',
            (IngredientEntity item) => <String, Object?>{
                  'id': item.id,
                  'mealId': item.mealId,
                  'name': item.name,
                  'weight': item.weight,
                  'amount': item.amount,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats,
                  'confidence': item.confidence,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'aiOriginalName': item.aiOriginalName,
                  'aiOriginalWeight': item.aiOriginalWeight,
                  'aiOriginalAmount': item.aiOriginalAmount,
                  'aiOriginalCalories': item.aiOriginalCalories,
                  'aiOriginalProteins': item.aiOriginalProteins,
                  'aiOriginalCarbs': item.aiOriginalCarbs,
                  'aiOriginalFats': item.aiOriginalFats,
                  'aiOriginalConfidence': item.aiOriginalConfidence,
                  'wasEditedByUser': item.wasEditedByUser ? 1 : 0,
                  'deletedAtMs': item.deletedAtMs
                }),
        _ingredientEntityUpdateAdapter = UpdateAdapter(
            database,
            'Ingredient',
            ['id'],
            (IngredientEntity item) => <String, Object?>{
                  'id': item.id,
                  'mealId': item.mealId,
                  'name': item.name,
                  'weight': item.weight,
                  'amount': item.amount,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats,
                  'confidence': item.confidence,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'aiOriginalName': item.aiOriginalName,
                  'aiOriginalWeight': item.aiOriginalWeight,
                  'aiOriginalAmount': item.aiOriginalAmount,
                  'aiOriginalCalories': item.aiOriginalCalories,
                  'aiOriginalProteins': item.aiOriginalProteins,
                  'aiOriginalCarbs': item.aiOriginalCarbs,
                  'aiOriginalFats': item.aiOriginalFats,
                  'aiOriginalConfidence': item.aiOriginalConfidence,
                  'wasEditedByUser': item.wasEditedByUser ? 1 : 0,
                  'deletedAtMs': item.deletedAtMs
                }),
        _ingredientEntityDeletionAdapter = DeletionAdapter(
            database,
            'Ingredient',
            ['id'],
            (IngredientEntity item) => <String, Object?>{
                  'id': item.id,
                  'mealId': item.mealId,
                  'name': item.name,
                  'weight': item.weight,
                  'amount': item.amount,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats,
                  'confidence': item.confidence,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'aiOriginalName': item.aiOriginalName,
                  'aiOriginalWeight': item.aiOriginalWeight,
                  'aiOriginalAmount': item.aiOriginalAmount,
                  'aiOriginalCalories': item.aiOriginalCalories,
                  'aiOriginalProteins': item.aiOriginalProteins,
                  'aiOriginalCarbs': item.aiOriginalCarbs,
                  'aiOriginalFats': item.aiOriginalFats,
                  'aiOriginalConfidence': item.aiOriginalConfidence,
                  'wasEditedByUser': item.wasEditedByUser ? 1 : 0,
                  'deletedAtMs': item.deletedAtMs
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<IngredientEntity> _ingredientEntityInsertionAdapter;

  final UpdateAdapter<IngredientEntity> _ingredientEntityUpdateAdapter;

  final DeletionAdapter<IngredientEntity> _ingredientEntityDeletionAdapter;

  @override
  Future<List<IngredientEntity>> findIngredientsForMeal(int mealId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Ingredient WHERE mealId = ?1 AND deletedAtMs IS NULL',
        mapper: (Map<String, Object?> row) => IngredientEntity(
            id: row['id'] as int?,
            mealId: row['mealId'] as int,
            name: row['name'] as String,
            weight: row['weight'] as double,
            amount: row['amount'] as double?,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double,
            confidence: row['confidence'] as double?,
            isFavorite: (row['isFavorite'] as int) != 0,
            aiOriginalName: row['aiOriginalName'] as String?,
            aiOriginalWeight: row['aiOriginalWeight'] as double?,
            aiOriginalAmount: row['aiOriginalAmount'] as double?,
            aiOriginalCalories: row['aiOriginalCalories'] as double?,
            aiOriginalProteins: row['aiOriginalProteins'] as double?,
            aiOriginalCarbs: row['aiOriginalCarbs'] as double?,
            aiOriginalFats: row['aiOriginalFats'] as double?,
            aiOriginalConfidence: row['aiOriginalConfidence'] as double?,
            wasEditedByUser: (row['wasEditedByUser'] as int) != 0,
            deletedAtMs: row['deletedAtMs'] as int?),
        arguments: [mealId]);
  }

  @override
  Future<List<IngredientEntity>> findAllIngredientsForMealIncludingDeleted(
      int mealId) async {
    return _queryAdapter.queryList('SELECT * FROM Ingredient WHERE mealId = ?1',
        mapper: (Map<String, Object?> row) => IngredientEntity(
            id: row['id'] as int?,
            mealId: row['mealId'] as int,
            name: row['name'] as String,
            weight: row['weight'] as double,
            amount: row['amount'] as double?,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double,
            confidence: row['confidence'] as double?,
            isFavorite: (row['isFavorite'] as int) != 0,
            aiOriginalName: row['aiOriginalName'] as String?,
            aiOriginalWeight: row['aiOriginalWeight'] as double?,
            aiOriginalAmount: row['aiOriginalAmount'] as double?,
            aiOriginalCalories: row['aiOriginalCalories'] as double?,
            aiOriginalProteins: row['aiOriginalProteins'] as double?,
            aiOriginalCarbs: row['aiOriginalCarbs'] as double?,
            aiOriginalFats: row['aiOriginalFats'] as double?,
            aiOriginalConfidence: row['aiOriginalConfidence'] as double?,
            wasEditedByUser: (row['wasEditedByUser'] as int) != 0,
            deletedAtMs: row['deletedAtMs'] as int?),
        arguments: [mealId]);
  }

  @override
  Future<void> deleteIngredientsForMeal(int mealId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM Ingredient WHERE mealId = ?1',
        arguments: [mealId]);
  }

  @override
  Future<void> softDeleteIngredientsForMeal(
    int mealId,
    int deletedAtMs,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE Ingredient SET deletedAtMs = ?2 WHERE mealId = ?1 AND deletedAtMs IS NULL',
        arguments: [mealId, deletedAtMs]);
  }

  @override
  Future<int> insertIngredient(IngredientEntity ingredient) {
    return _ingredientEntityInsertionAdapter.insertAndReturnId(
        ingredient, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertIngredients(List<IngredientEntity> ingredients) {
    return _ingredientEntityInsertionAdapter.insertListAndReturnIds(
        ingredients, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateIngredient(IngredientEntity ingredient) async {
    await _ingredientEntityUpdateAdapter.update(
        ingredient, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteIngredient(IngredientEntity ingredient) async {
    await _ingredientEntityDeletionAdapter.delete(ingredient);
  }
}

class _$WeightEntryDao extends WeightEntryDao {
  _$WeightEntryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _weightEntryEntityInsertionAdapter = InsertionAdapter(
            database,
            'WeightEntry',
            (WeightEntryEntity item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'weight': item.weight,
                  'photoPath': item.photoPath
                },
            changeListener),
        _weightEntryEntityUpdateAdapter = UpdateAdapter(
            database,
            'WeightEntry',
            ['id'],
            (WeightEntryEntity item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'weight': item.weight,
                  'photoPath': item.photoPath
                },
            changeListener),
        _weightEntryEntityDeletionAdapter = DeletionAdapter(
            database,
            'WeightEntry',
            ['id'],
            (WeightEntryEntity item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'weight': item.weight,
                  'photoPath': item.photoPath
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WeightEntryEntity> _weightEntryEntityInsertionAdapter;

  final UpdateAdapter<WeightEntryEntity> _weightEntryEntityUpdateAdapter;

  final DeletionAdapter<WeightEntryEntity> _weightEntryEntityDeletionAdapter;

  @override
  Future<List<WeightEntryEntity>> getAllEntries() async {
    return _queryAdapter.queryList(
        'SELECT * FROM WeightEntry ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => WeightEntryEntity(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            weight: row['weight'] as double,
            photoPath: row['photoPath'] as String?));
  }

  @override
  Stream<List<WeightEntryEntity>> watchEntries() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM WeightEntry ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => WeightEntryEntity(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            weight: row['weight'] as double,
            photoPath: row['photoPath'] as String?),
        queryableName: 'WeightEntry',
        isView: false);
  }

  @override
  Future<void> deleteEntryById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM WeightEntry WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertEntry(WeightEntryEntity entry) {
    return _weightEntryEntityInsertionAdapter.insertAndReturnId(
        entry, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateEntry(WeightEntryEntity entry) async {
    await _weightEntryEntityUpdateAdapter.update(
        entry, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteEntry(WeightEntryEntity entry) async {
    await _weightEntryEntityDeletionAdapter.delete(entry);
  }
}

class _$ExerciseDao extends ExerciseDao {
  _$ExerciseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _exerciseEntityInsertionAdapter = InsertionAdapter(
            database,
            'Exercise',
            (ExerciseEntity item) => <String, Object?>{
                  'id': item.id,
                  'dayRecordId': item.dayRecordId,
                  'name': item.name,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'durationMinutes': item.durationMinutes,
                  'caloriesBurned': item.caloriesBurned,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'source': item.source,
                  'confidence': item.confidence
                }),
        _exerciseEntityUpdateAdapter = UpdateAdapter(
            database,
            'Exercise',
            ['id'],
            (ExerciseEntity item) => <String, Object?>{
                  'id': item.id,
                  'dayRecordId': item.dayRecordId,
                  'name': item.name,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'durationMinutes': item.durationMinutes,
                  'caloriesBurned': item.caloriesBurned,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'source': item.source,
                  'confidence': item.confidence
                }),
        _exerciseEntityDeletionAdapter = DeletionAdapter(
            database,
            'Exercise',
            ['id'],
            (ExerciseEntity item) => <String, Object?>{
                  'id': item.id,
                  'dayRecordId': item.dayRecordId,
                  'name': item.name,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'durationMinutes': item.durationMinutes,
                  'caloriesBurned': item.caloriesBurned,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'source': item.source,
                  'confidence': item.confidence
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExerciseEntity> _exerciseEntityInsertionAdapter;

  final UpdateAdapter<ExerciseEntity> _exerciseEntityUpdateAdapter;

  final DeletionAdapter<ExerciseEntity> _exerciseEntityDeletionAdapter;

  @override
  Future<List<ExerciseEntity>> findExercisesForDayRecord(
      int dayRecordId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Exercise WHERE dayRecordId = ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => ExerciseEntity(
            id: row['id'] as int?,
            dayRecordId: row['dayRecordId'] as int,
            name: row['name'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int),
            durationMinutes: row['durationMinutes'] as int?,
            caloriesBurned: row['caloriesBurned'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            source: row['source'] as String?,
            confidence: row['confidence'] as double?),
        arguments: [dayRecordId]);
  }

  @override
  Future<ExerciseEntity?> findExerciseByDayRecordAndSource(
    int dayRecordId,
    String source,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM Exercise WHERE dayRecordId = ?1 AND source = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => ExerciseEntity(
            id: row['id'] as int?,
            dayRecordId: row['dayRecordId'] as int,
            name: row['name'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int),
            durationMinutes: row['durationMinutes'] as int?,
            caloriesBurned: row['caloriesBurned'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            source: row['source'] as String?,
            confidence: row['confidence'] as double?),
        arguments: [dayRecordId, source]);
  }

  @override
  Future<void> deleteExerciseById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Exercise WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int> insertExercise(ExerciseEntity exercise) {
    return _exerciseEntityInsertionAdapter.insertAndReturnId(
        exercise, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateExercise(ExerciseEntity exercise) async {
    await _exerciseEntityUpdateAdapter.update(
        exercise, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteExercise(ExerciseEntity exercise) async {
    await _exerciseEntityDeletionAdapter.delete(exercise);
  }
}

class _$MealTemplateDao extends MealTemplateDao {
  _$MealTemplateDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mealTemplateEntityInsertionAdapter = InsertionAdapter(
            database,
            'MealTemplate',
            (MealTemplateEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'normalizedName': item.normalizedName,
                  'photoPath': item.photoPath,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'lastUsedAt': _dateTimeConverter.encode(item.lastUsedAt),
                  'usageCount': item.usageCount
                }),
        _mealTemplateEntityUpdateAdapter = UpdateAdapter(
            database,
            'MealTemplate',
            ['id'],
            (MealTemplateEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'normalizedName': item.normalizedName,
                  'photoPath': item.photoPath,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'lastUsedAt': _dateTimeConverter.encode(item.lastUsedAt),
                  'usageCount': item.usageCount
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MealTemplateEntity>
      _mealTemplateEntityInsertionAdapter;

  final UpdateAdapter<MealTemplateEntity> _mealTemplateEntityUpdateAdapter;

  @override
  Future<List<MealTemplateEntity>> getAllTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MealTemplate ORDER BY lastUsedAt DESC',
        mapper: (Map<String, Object?> row) => MealTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            photoPath: row['photoPath'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int));
  }

  @override
  Future<MealTemplateEntity?> findByNormalizedName(
      String normalizedName) async {
    return _queryAdapter.query(
        'SELECT * FROM MealTemplate WHERE normalizedName = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => MealTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            photoPath: row['photoPath'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int),
        arguments: [normalizedName]);
  }

  @override
  Future<List<MealTemplateEntity>> getFavoriteTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM MealTemplate WHERE isFavorite = 1 ORDER BY lastUsedAt DESC',
        mapper: (Map<String, Object?> row) => MealTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            photoPath: row['photoPath'] as String?,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int));
  }

  @override
  Future<void> deleteTemplateById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM MealTemplate WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertTemplate(MealTemplateEntity template) {
    return _mealTemplateEntityInsertionAdapter.insertAndReturnId(
        template, OnConflictStrategy.ignore);
  }

  @override
  Future<void> updateTemplate(MealTemplateEntity template) async {
    await _mealTemplateEntityUpdateAdapter.update(
        template, OnConflictStrategy.abort);
  }
}

class _$MealTemplateIngredientDao extends MealTemplateIngredientDao {
  _$MealTemplateIngredientDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mealTemplateIngredientEntityInsertionAdapter = InsertionAdapter(
            database,
            'MealTemplateIngredient',
            (MealTemplateIngredientEntity item) => <String, Object?>{
                  'id': item.id,
                  'templateId': item.templateId,
                  'name': item.name,
                  'weight': item.weight,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MealTemplateIngredientEntity>
      _mealTemplateIngredientEntityInsertionAdapter;

  @override
  Future<List<MealTemplateIngredientEntity>> findForTemplate(
      int templateId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM MealTemplateIngredient WHERE templateId = ?1',
        mapper: (Map<String, Object?> row) => MealTemplateIngredientEntity(
            id: row['id'] as int?,
            templateId: row['templateId'] as int,
            name: row['name'] as String,
            weight: row['weight'] as double,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double),
        arguments: [templateId]);
  }

  @override
  Future<void> deleteForTemplate(int templateId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM MealTemplateIngredient WHERE templateId = ?1',
        arguments: [templateId]);
  }

  @override
  Future<List<int>> insertIngredients(
      List<MealTemplateIngredientEntity> ingredients) {
    return _mealTemplateIngredientEntityInsertionAdapter.insertListAndReturnIds(
        ingredients, OnConflictStrategy.replace);
  }
}

class _$ExerciseTemplateDao extends ExerciseTemplateDao {
  _$ExerciseTemplateDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _exerciseTemplateEntityInsertionAdapter = InsertionAdapter(
            database,
            'ExerciseTemplate',
            (ExerciseTemplateEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'normalizedName': item.normalizedName,
                  'durationMinutes': item.durationMinutes,
                  'caloriesBurned': item.caloriesBurned,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'lastUsedAt': _dateTimeConverter.encode(item.lastUsedAt),
                  'usageCount': item.usageCount
                }),
        _exerciseTemplateEntityUpdateAdapter = UpdateAdapter(
            database,
            'ExerciseTemplate',
            ['id'],
            (ExerciseTemplateEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'normalizedName': item.normalizedName,
                  'durationMinutes': item.durationMinutes,
                  'caloriesBurned': item.caloriesBurned,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'lastUsedAt': _dateTimeConverter.encode(item.lastUsedAt),
                  'usageCount': item.usageCount
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExerciseTemplateEntity>
      _exerciseTemplateEntityInsertionAdapter;

  final UpdateAdapter<ExerciseTemplateEntity>
      _exerciseTemplateEntityUpdateAdapter;

  @override
  Future<List<ExerciseTemplateEntity>> getAllTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ExerciseTemplate ORDER BY lastUsedAt DESC',
        mapper: (Map<String, Object?> row) => ExerciseTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            durationMinutes: row['durationMinutes'] as int?,
            caloriesBurned: row['caloriesBurned'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int));
  }

  @override
  Future<ExerciseTemplateEntity?> findByNormalizedName(
      String normalizedName) async {
    return _queryAdapter.query(
        'SELECT * FROM ExerciseTemplate WHERE normalizedName = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => ExerciseTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            durationMinutes: row['durationMinutes'] as int?,
            caloriesBurned: row['caloriesBurned'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int),
        arguments: [normalizedName]);
  }

  @override
  Future<List<ExerciseTemplateEntity>> getFavoriteTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ExerciseTemplate WHERE isFavorite = 1 ORDER BY lastUsedAt DESC',
        mapper: (Map<String, Object?> row) => ExerciseTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            durationMinutes: row['durationMinutes'] as int?,
            caloriesBurned: row['caloriesBurned'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int));
  }

  @override
  Future<void> deleteTemplateById(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ExerciseTemplate WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertTemplate(ExerciseTemplateEntity template) {
    return _exerciseTemplateEntityInsertionAdapter.insertAndReturnId(
        template, OnConflictStrategy.ignore);
  }

  @override
  Future<void> updateTemplate(ExerciseTemplateEntity template) async {
    await _exerciseTemplateEntityUpdateAdapter.update(
        template, OnConflictStrategy.abort);
  }
}

class _$IngredientTemplateDao extends IngredientTemplateDao {
  _$IngredientTemplateDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _ingredientTemplateEntityInsertionAdapter = InsertionAdapter(
            database,
            'IngredientTemplate',
            (IngredientTemplateEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'normalizedName': item.normalizedName,
                  'weight': item.weight,
                  'amount': item.amount,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'lastUsedAt': _dateTimeConverter.encode(item.lastUsedAt),
                  'usageCount': item.usageCount
                }),
        _ingredientTemplateEntityUpdateAdapter = UpdateAdapter(
            database,
            'IngredientTemplate',
            ['id'],
            (IngredientTemplateEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'normalizedName': item.normalizedName,
                  'weight': item.weight,
                  'amount': item.amount,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats,
                  'isFavorite': item.isFavorite ? 1 : 0,
                  'lastUsedAt': _dateTimeConverter.encode(item.lastUsedAt),
                  'usageCount': item.usageCount
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<IngredientTemplateEntity>
      _ingredientTemplateEntityInsertionAdapter;

  final UpdateAdapter<IngredientTemplateEntity>
      _ingredientTemplateEntityUpdateAdapter;

  @override
  Future<List<IngredientTemplateEntity>> getAllTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM IngredientTemplate ORDER BY lastUsedAt DESC',
        mapper: (Map<String, Object?> row) => IngredientTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            weight: row['weight'] as double,
            amount: row['amount'] as double,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int));
  }

  @override
  Future<IngredientTemplateEntity?> findByNormalizedName(
      String normalizedName) async {
    return _queryAdapter.query(
        'SELECT * FROM IngredientTemplate WHERE normalizedName = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => IngredientTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            weight: row['weight'] as double,
            amount: row['amount'] as double,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int),
        arguments: [normalizedName]);
  }

  @override
  Future<List<IngredientTemplateEntity>> getFavoriteTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM IngredientTemplate WHERE isFavorite = 1 ORDER BY lastUsedAt DESC',
        mapper: (Map<String, Object?> row) => IngredientTemplateEntity(
            id: row['id'] as int?,
            name: row['name'] as String,
            normalizedName: row['normalizedName'] as String,
            weight: row['weight'] as double,
            amount: row['amount'] as double,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double,
            isFavorite: (row['isFavorite'] as int) != 0,
            lastUsedAt: _dateTimeConverter.decode(row['lastUsedAt'] as int),
            usageCount: row['usageCount'] as int));
  }

  @override
  Future<void> deleteTemplateById(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM IngredientTemplate WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertTemplate(IngredientTemplateEntity template) {
    return _ingredientTemplateEntityInsertionAdapter.insertAndReturnId(
        template, OnConflictStrategy.ignore);
  }

  @override
  Future<void> updateTemplate(IngredientTemplateEntity template) async {
    await _ingredientTemplateEntityUpdateAdapter.update(
        template, OnConflictStrategy.abort);
  }
}

class _$AiAttemptDao extends AiAttemptDao {
  _$AiAttemptDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _aiAttemptEntityInsertionAdapter = InsertionAdapter(
            database,
            'AiAttempt',
            (AiAttemptEntity item) => <String, Object?>{
                  'id': item.id,
                  'timestampMs': item.timestampMs,
                  'kind': item.kind,
                  'modality': item.modality,
                  'provider': item.provider,
                  'model': item.model,
                  'status': item.status,
                  'confidence': item.confidence,
                  'errorMessage': item.errorMessage
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AiAttemptEntity> _aiAttemptEntityInsertionAdapter;

  @override
  Future<List<AiAttemptEntity>> findAllAttempts() async {
    return _queryAdapter.queryList(
        'SELECT * FROM AiAttempt ORDER BY timestampMs ASC',
        mapper: (Map<String, Object?> row) => AiAttemptEntity(
            id: row['id'] as int?,
            timestampMs: row['timestampMs'] as int,
            kind: row['kind'] as String,
            modality: row['modality'] as String?,
            provider: row['provider'] as String?,
            model: row['model'] as String?,
            status: row['status'] as String,
            confidence: row['confidence'] as double?,
            errorMessage: row['errorMessage'] as String?));
  }

  @override
  Future<List<AiAttemptEntity>> findAttemptsInRange(
    int startMs,
    int endMs,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AiAttempt WHERE timestampMs >= ?1 AND timestampMs < ?2 ORDER BY timestampMs ASC',
        mapper: (Map<String, Object?> row) => AiAttemptEntity(id: row['id'] as int?, timestampMs: row['timestampMs'] as int, kind: row['kind'] as String, modality: row['modality'] as String?, provider: row['provider'] as String?, model: row['model'] as String?, status: row['status'] as String, confidence: row['confidence'] as double?, errorMessage: row['errorMessage'] as String?),
        arguments: [startMs, endMs]);
  }

  @override
  Future<int> insertAttempt(AiAttemptEntity attempt) {
    return _aiAttemptEntityInsertionAdapter.insertAndReturnId(
        attempt, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
