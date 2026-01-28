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
            'CREATE TABLE IF NOT EXISTS `DayRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `date` INTEGER NOT NULL, `meals` TEXT NOT NULL, `calorieGoal` REAL NOT NULL, `proteinGoal` REAL NOT NULL, `carbsGoal` REAL NOT NULL, `fatGoal` REAL NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Meal` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `ingredients` TEXT NOT NULL, `timestamp` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Ingredient` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `weight` REAL NOT NULL, `calories` REAL NOT NULL, `proteins` REAL NOT NULL, `carbs` REAL NOT NULL, `fats` REAL NOT NULL)');

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
}

class _$DayRecordDao extends DayRecordDao {
  _$DayRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _dayRecordInsertionAdapter = InsertionAdapter(
            database,
            'DayRecord',
            (DayRecord item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'meals': _mealListConverter.encode(item.meals),
                  'calorieGoal': item.calorieGoal,
                  'proteinGoal': item.proteinGoal,
                  'carbsGoal': item.carbsGoal,
                  'fatGoal': item.fatGoal
                },
            changeListener),
        _dayRecordUpdateAdapter = UpdateAdapter(
            database,
            'DayRecord',
            ['id'],
            (DayRecord item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'meals': _mealListConverter.encode(item.meals),
                  'calorieGoal': item.calorieGoal,
                  'proteinGoal': item.proteinGoal,
                  'carbsGoal': item.carbsGoal,
                  'fatGoal': item.fatGoal
                },
            changeListener),
        _dayRecordDeletionAdapter = DeletionAdapter(
            database,
            'DayRecord',
            ['id'],
            (DayRecord item) => <String, Object?>{
                  'id': item.id,
                  'date': _dateTimeConverter.encode(item.date),
                  'meals': _mealListConverter.encode(item.meals),
                  'calorieGoal': item.calorieGoal,
                  'proteinGoal': item.proteinGoal,
                  'carbsGoal': item.carbsGoal,
                  'fatGoal': item.fatGoal
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DayRecord> _dayRecordInsertionAdapter;

  final UpdateAdapter<DayRecord> _dayRecordUpdateAdapter;

  final DeletionAdapter<DayRecord> _dayRecordDeletionAdapter;

  @override
  Stream<List<DayRecord>> watchDayRecords() {
    return _queryAdapter.queryListStream('SELECT * FROM DayRecord',
        mapper: (Map<String, Object?> row) => DayRecord(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            meals: _mealListConverter.decode(row['meals'] as String),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double),
        queryableName: 'DayRecord',
        isView: false);
  }

  @override
  Future<DayRecord?> findDayRecordByDate(int date) async {
    return _queryAdapter.query('SELECT * FROM DayRecord WHERE date = ?1',
        mapper: (Map<String, Object?> row) => DayRecord(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            meals: _mealListConverter.decode(row['meals'] as String),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double),
        arguments: [date]);
  }

  @override
  Future<List<DayRecord>> getAllDayRecords() async {
    return _queryAdapter.queryList('SELECT * FROM DayRecord ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => DayRecord(
            id: row['id'] as int?,
            date: _dateTimeConverter.decode(row['date'] as int),
            meals: _mealListConverter.decode(row['meals'] as String),
            calorieGoal: row['calorieGoal'] as double,
            proteinGoal: row['proteinGoal'] as double,
            carbsGoal: row['carbsGoal'] as double,
            fatGoal: row['fatGoal'] as double));
  }

  @override
  Future<int> insertDayRecord(DayRecord dayRecord) {
    return _dayRecordInsertionAdapter.insertAndReturnId(
        dayRecord, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateDayRecord(DayRecord dayRecord) async {
    await _dayRecordUpdateAdapter.update(dayRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDayRecord(DayRecord dayRecord) async {
    await _dayRecordDeletionAdapter.delete(dayRecord);
  }
}

class _$MealDao extends MealDao {
  _$MealDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mealInsertionAdapter = InsertionAdapter(
            database,
            'Meal',
            (Meal item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'ingredients':
                      _ingredientListConverter.encode(item.ingredients),
                  'timestamp': _dateTimeConverter.encode(item.timestamp)
                }),
        _mealUpdateAdapter = UpdateAdapter(
            database,
            'Meal',
            ['id'],
            (Meal item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'ingredients':
                      _ingredientListConverter.encode(item.ingredients),
                  'timestamp': _dateTimeConverter.encode(item.timestamp)
                }),
        _mealDeletionAdapter = DeletionAdapter(
            database,
            'Meal',
            ['id'],
            (Meal item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'ingredients':
                      _ingredientListConverter.encode(item.ingredients),
                  'timestamp': _dateTimeConverter.encode(item.timestamp)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Meal> _mealInsertionAdapter;

  final UpdateAdapter<Meal> _mealUpdateAdapter;

  final DeletionAdapter<Meal> _mealDeletionAdapter;

  @override
  Future<List<Meal>> findMealsForDayRecord(int dayRecordId) async {
    return _queryAdapter.queryList('SELECT * FROM Meal WHERE dayRecordId = ?1',
        mapper: (Map<String, Object?> row) => Meal(
            id: row['id'] as int?,
            name: row['name'] as String,
            ingredients:
                _ingredientListConverter.decode(row['ingredients'] as String),
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int)),
        arguments: [dayRecordId]);
  }

  @override
  Future<int> insertMeal(Meal meal) {
    return _mealInsertionAdapter.insertAndReturnId(
        meal, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertMeals(List<Meal> meals) {
    return _mealInsertionAdapter.insertListAndReturnIds(
        meals, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    await _mealUpdateAdapter.update(meal, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMeal(Meal meal) async {
    await _mealDeletionAdapter.delete(meal);
  }
}

class _$IngredientDao extends IngredientDao {
  _$IngredientDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _ingredientInsertionAdapter = InsertionAdapter(
            database,
            'Ingredient',
            (Ingredient item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'weight': item.weight,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats
                }),
        _ingredientUpdateAdapter = UpdateAdapter(
            database,
            'Ingredient',
            ['id'],
            (Ingredient item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'weight': item.weight,
                  'calories': item.calories,
                  'proteins': item.proteins,
                  'carbs': item.carbs,
                  'fats': item.fats
                }),
        _ingredientDeletionAdapter = DeletionAdapter(
            database,
            'Ingredient',
            ['id'],
            (Ingredient item) => <String, Object?>{
                  'id': item.id,
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

  final InsertionAdapter<Ingredient> _ingredientInsertionAdapter;

  final UpdateAdapter<Ingredient> _ingredientUpdateAdapter;

  final DeletionAdapter<Ingredient> _ingredientDeletionAdapter;

  @override
  Future<List<Ingredient>> findIngredientsForMeal(int mealId) async {
    return _queryAdapter.queryList('SELECT * FROM Ingredient WHERE mealId = ?1',
        mapper: (Map<String, Object?> row) => Ingredient(
            id: row['id'] as int?,
            name: row['name'] as String,
            weight: row['weight'] as double,
            calories: row['calories'] as double,
            proteins: row['proteins'] as double,
            carbs: row['carbs'] as double,
            fats: row['fats'] as double),
        arguments: [mealId]);
  }

  @override
  Future<int> insertIngredient(Ingredient ingredient) {
    return _ingredientInsertionAdapter.insertAndReturnId(
        ingredient, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    return _ingredientInsertionAdapter.insertListAndReturnIds(
        ingredients, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    await _ingredientUpdateAdapter.update(ingredient, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteIngredient(Ingredient ingredient) async {
    await _ingredientDeletionAdapter.delete(ingredient);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _mealListConverter = MealListConverter();
final _ingredientListConverter = IngredientListConverter();
