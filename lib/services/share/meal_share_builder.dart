import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

class MealShareBuilder {
  static AppShareRequest fromMeal({
    required Meal meal,
    String? mealtimeLabel,
    bool includePhoto = true,
  }) {
    final ingredients = meal.ingredients;
    final title = _mealTitle(meal.name);

    final totalCalories = ingredients.fold<double>(0, (sum, item) => sum + item.calories);
    final totalProteins = ingredients.fold<double>(0, (sum, item) => sum + item.proteins);
    final totalCarbs = ingredients.fold<double>(0, (sum, item) => sum + item.carbs);
    final totalFats = ingredients.fold<double>(0, (sum, item) => sum + item.fats);

    final lines = <String>[
      title,
      '${tr(LocaleKeys.export_csv_date)}: ${_formatDate(meal.timestamp)}',
      'Time: ${_formatTime(meal.timestamp)}',
      if (mealtimeLabel != null && mealtimeLabel.trim().isNotEmpty) 'Meal time: ${mealtimeLabel.trim()}',
      '${tr(LocaleKeys.common_calories)}: ${totalCalories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}',
      '${tr(LocaleKeys.common_protein)} ${totalProteins.toStringAsFixed(0)}${tr(LocaleKeys.common_g)} | ${tr(LocaleKeys.common_carbs)} ${totalCarbs.toStringAsFixed(0)}${tr(LocaleKeys.common_g)} | ${tr(LocaleKeys.common_fats)} ${totalFats.toStringAsFixed(0)}${tr(LocaleKeys.common_g)}',
      '',
      '${tr(LocaleKeys.common_ingredients)}:',
      if (ingredients.isEmpty) '- ${tr(LocaleKeys.common_no_items_found)}',
      ...ingredients.map(_ingredientLine),
    ];

    return AppShareRequest(
      title: tr(LocaleKeys.meal_share_meal),
      subject: '${tr(LocaleKeys.meal_share_summary)}: $title',
      text: lines.join('\n'),
      files: _photoFiles(includePhoto: includePhoto, photoPath: meal.photoPath),
    );
  }

  static String _mealTitle(String rawName) {
    final trimmed = rawName.trim();
    return trimmed.isEmpty ? tr(LocaleKeys.meal_untitled) : trimmed;
  }

  static String _formatDate(DateTime date) {
    return '${date.day}. ${date.month}. ${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static String _ingredientLine(Ingredient ingredient) {
    final weight = _formatWeight(ingredient.weight);
    final calories = ingredient.calories.toStringAsFixed(0);
    return '- ${ingredient.name}: $weight, $calories ${tr(LocaleKeys.common_kcal)}';
  }

  static String _formatWeight(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.01) {
      return '${rounded.toStringAsFixed(0)} ${tr(LocaleKeys.common_g)}';
    }
    return '${value.toStringAsFixed(1)} ${tr(LocaleKeys.common_g)}';
  }

  static List<XFile>? _photoFiles({
    required bool includePhoto,
    required String? photoPath,
  }) {
    if (!includePhoto || photoPath == null || photoPath.isEmpty) return null;
    final photo = MediaStorage.existingMealPhotoFile(photoPath);
    if (photo == null) return null;
    return <XFile>[XFile(photo.path)];
  }
}
