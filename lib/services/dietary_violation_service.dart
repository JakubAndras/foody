import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/dietary_violation.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DietaryViolationService {
  DietaryViolationService(this._ref);

  final Ref _ref;

  static const Map<String, String> _meatKeywords = {
    // EN
    'chicken': 'violation_contains_meat',
    'beef': 'violation_contains_meat',
    'pork': 'violation_contains_meat',
    'lamb': 'violation_contains_meat',
    'turkey': 'violation_contains_meat',
    'duck': 'violation_contains_meat',
    'veal': 'violation_contains_meat',
    'bacon': 'violation_contains_meat',
    'ham': 'violation_contains_meat',
    'sausage': 'violation_contains_meat',
    'salami': 'violation_contains_meat',
    'steak': 'violation_contains_meat',
    'meatball': 'violation_contains_meat',
    'pepperoni': 'violation_contains_meat',
    'prosciutto': 'violation_contains_meat',
    'venison': 'violation_contains_meat',
    'rabbit': 'violation_contains_meat',
    'goose': 'violation_contains_meat',
    // CS
    'kuře': 'violation_contains_meat',
    'kuřecí': 'violation_contains_meat',
    'hovězí': 'violation_contains_meat',
    'vepřové': 'violation_contains_meat',
    'vepřový': 'violation_contains_meat',
    'jehněčí': 'violation_contains_meat',
    'krůtí': 'violation_contains_meat',
    'kachní': 'violation_contains_meat',
    'telecí': 'violation_contains_meat',
    'slanina': 'violation_contains_meat',
    'šunka': 'violation_contains_meat',
    'klobása': 'violation_contains_meat',
    'párek': 'violation_contains_meat',
    'salám': 'violation_contains_meat',
    'řízek': 'violation_contains_meat',
    'králík': 'violation_contains_meat',
    'husa': 'violation_contains_meat',
    'husí': 'violation_contains_meat',
    'maso': 'violation_contains_meat',
  };

  static const Map<String, String> _fishKeywords = {
    // EN
    'fish': 'violation_contains_fish',
    'salmon': 'violation_contains_fish',
    'tuna': 'violation_contains_fish',
    'shrimp': 'violation_contains_fish',
    'prawn': 'violation_contains_fish',
    'lobster': 'violation_contains_fish',
    'crab': 'violation_contains_fish',
    'cod': 'violation_contains_fish',
    'sardine': 'violation_contains_fish',
    'anchovy': 'violation_contains_fish',
    'mackerel': 'violation_contains_fish',
    'trout': 'violation_contains_fish',
    'squid': 'violation_contains_fish',
    'oyster': 'violation_contains_fish',
    'mussel': 'violation_contains_fish',
    'clam': 'violation_contains_fish',
    'seafood': 'violation_contains_fish',
    'sushi': 'violation_contains_fish',
    // CS
    'ryba': 'violation_contains_fish',
    'losos': 'violation_contains_fish',
    'tuňák': 'violation_contains_fish',
    'kreveta': 'violation_contains_fish',
    'krevety': 'violation_contains_fish',
    'humr': 'violation_contains_fish',
    'krab': 'violation_contains_fish',
    'treska': 'violation_contains_fish',
    'sardinka': 'violation_contains_fish',
    'makrela': 'violation_contains_fish',
    'pstruh': 'violation_contains_fish',
    'kalamár': 'violation_contains_fish',
    'ústřice': 'violation_contains_fish',
    'slávka': 'violation_contains_fish',
    'mořské plody': 'violation_contains_fish',
    'rybí': 'violation_contains_fish',
  };

  static const Map<String, String> _dairyKeywords = {
    // EN
    'milk': 'violation_contains_dairy',
    'cheese': 'violation_contains_dairy',
    'butter': 'violation_contains_dairy',
    'cream': 'violation_contains_dairy',
    'yogurt': 'violation_contains_dairy',
    'yoghurt': 'violation_contains_dairy',
    'whey': 'violation_contains_dairy',
    'casein': 'violation_contains_dairy',
    'ghee': 'violation_contains_dairy',
    'ricotta': 'violation_contains_dairy',
    'mozzarella': 'violation_contains_dairy',
    'parmesan': 'violation_contains_dairy',
    'cheddar': 'violation_contains_dairy',
    'brie': 'violation_contains_dairy',
    'cottage cheese': 'violation_contains_dairy',
    // CS
    'mléko': 'violation_contains_dairy',
    'sýr': 'violation_contains_dairy',
    'máslo': 'violation_contains_dairy',
    'smetana': 'violation_contains_dairy',
    'jogurt': 'violation_contains_dairy',
    'tvaroh': 'violation_contains_dairy',
    'mléčný': 'violation_contains_dairy',
    'mléčné': 'violation_contains_dairy',
    'sýrový': 'violation_contains_dairy',
  };

  static const Map<String, String> _eggKeywords = {
    // EN
    'egg': 'violation_contains_eggs',
    'eggs': 'violation_contains_eggs',
    'omelette': 'violation_contains_eggs',
    'omelet': 'violation_contains_eggs',
    'meringue': 'violation_contains_eggs',
    'mayonnaise': 'violation_contains_eggs',
    // CS
    'vejce': 'violation_contains_eggs',
    'vajíčko': 'violation_contains_eggs',
    'vajíčka': 'violation_contains_eggs',
    'omeleta': 'violation_contains_eggs',
    'vaječný': 'violation_contains_eggs',
    'vaječné': 'violation_contains_eggs',
    'majonéza': 'violation_contains_eggs',
  };

  static const Map<String, String> _honeyKeywords = {
    // EN
    'honey': 'violation_contains_honey',
    // CS
    'med': 'violation_contains_honey',
    'medový': 'violation_contains_honey',
    'medové': 'violation_contains_honey',
  };

  Map<String, String> _getRestrictionKeywords(ProfileDietType dietType, String? customPrefs) {
    switch (dietType) {
      case ProfileDietType.classic:
        return {};
      case ProfileDietType.vegetarian:
        return {..._meatKeywords, ..._fishKeywords};
      case ProfileDietType.vegan:
        return {..._meatKeywords, ..._fishKeywords, ..._dairyKeywords, ..._eggKeywords, ..._honeyKeywords};
      case ProfileDietType.custom:
        if (customPrefs == null || customPrefs.trim().isEmpty) return {};
        final keywords = <String, String>{};
        final parts = customPrefs.split(RegExp(r'[,;]+'));
        for (final part in parts) {
          final keyword = part.trim().toLowerCase();
          if (keyword.isNotEmpty) {
            keywords[keyword] = 'violation_custom_restriction';
          }
        }
        return keywords;
    }
  }

  // Returns the violation reason for a single ingredient or null.
  // Resolution order: (1) AI flag persisted on the ingredient, (2) legacy keyword match against name
  // (covers pre-migration data and manually-entered ingredients that never went through AI).
  String? checkIngredient(Ingredient ingredient) {
    final aiFlag = ingredient.dietaryViolation;
    if (aiFlag != null && aiFlag.trim().isNotEmpty) return aiFlag;
    return _legacyKeywordReason(ingredient.name);
  }

  // Unique violation reasons across a meal's ingredients (preserves order of first occurrence).
  List<String> mealViolations(Meal meal) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final ingredient in meal.ingredients) {
      final reason = checkIngredient(ingredient);
      if (reason != null && seen.add(reason)) ordered.add(reason);
    }
    return ordered;
  }

  // Legacy keyword fallback: same logic as before, but translated reason returned instead of key.
  String? _legacyKeywordReason(String ingredientName) {
    final dietType = _ref.read(sessionProvider).dietType;
    if (dietType == null || dietType == ProfileDietType.classic) return null;
    final keywords = _getRestrictionKeywords(dietType, _ref.read(sessionProvider).customDietPreferences);
    if (keywords.isEmpty) return null;
    final nameLower = ingredientName.toLowerCase();
    for (final entry in keywords.entries) {
      if (nameLower.contains(entry.key)) return tr(entry.value);
    }
    return null;
  }

  bool hasDietaryViolations(DayRecord dayRecord) {
    for (final meal in dayRecord.meals) {
      for (final ingredient in meal.ingredients) {
        if (checkIngredient(ingredient) != null) return true;
      }
    }
    return false;
  }

  List<DietaryViolation> checkDayRecord(DayRecord dayRecord) {
    final violations = <DietaryViolation>[];
    for (final meal in dayRecord.meals) {
      for (final ingredient in meal.ingredients) {
        final reason = checkIngredient(ingredient);
        if (reason != null) {
          violations.add(DietaryViolation(
            mealName: meal.name,
            ingredientName: ingredient.name,
            reason: reason,
          ));
        }
      }
    }
    return violations;
  }
}

final dietaryViolationServiceProvider = Provider<DietaryViolationService>((ref) => DietaryViolationService(ref));
