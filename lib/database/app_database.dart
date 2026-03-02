import 'dart:async';
import 'package:floor/floor.dart';
import "package:sqflite/sqflite.dart" as sqflite;

import 'package:diplomka/model/type_converters.dart';
import 'package:diplomka/database/dao/day_record_dao.dart';
import 'package:diplomka/database/dao/exercise_dao.dart';
import 'package:diplomka/database/dao/ingredient_dao.dart';
import 'package:diplomka/database/dao/weight_entry_dao.dart';
import 'package:diplomka/database/entities/day_record_entity.dart';
import 'package:diplomka/database/entities/exercise_entity.dart';
import 'package:diplomka/database/entities/ingredient_entity.dart';
import 'package:diplomka/database/entities/meal_entity.dart';
import 'package:diplomka/database/entities/weight_entry_entity.dart';

import 'dao/meal_dao.dart';

part 'app_database.g.dart';

const _databaseVersion = 7;

@TypeConverters([DateTimeConverter])
@Database(version: _databaseVersion, entities: [DayRecordEntity, MealEntity, IngredientEntity, WeightEntryEntity, ExerciseEntity])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "app_database.db";

  DayRecordDao get dayRecordDao;
  MealDao get mealDao;
  IngredientDao get ingredientDao;
  WeightEntryDao get weightEntryDao;
  ExerciseDao get exerciseDao;
}
