import 'dart:async';
import 'package:floor/floor.dart';
import "package:sqflite/sqflite.dart" as sqflite;

import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/type_converters.dart';
import 'package:diplomka/database/dao/day_record_dao.dart';
import 'package:diplomka/database/dao/ingredient_dao.dart';

import 'dao/meal_dao.dart';

part 'app_database.g.dart';

const _databaseVersion = 1;

@TypeConverters([DateTimeConverter, MealListConverter, IngredientListConverter]) // Added IngredientListConverter
@Database(version: _databaseVersion, entities: [DayRecord, Meal, Ingredient])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "app_database.db";

  DayRecordDao get dayRecordDao;
  MealDao get mealDao;
  IngredientDao get ingredientDao;
}
