class HomeWidgetQuickAction {
  const HomeWidgetQuickAction({
    required this.id,
    required this.label,
    required this.uri,
  });

  final String id;
  final String label;
  final String uri;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'uri': uri,
    };
  }
}

class HomeWidgetPayload {
  const HomeWidgetPayload({
    required this.schemaVersion,
    required this.caloriesToday,
    required this.caloriesGoal,
    required this.proteinToday,
    required this.proteinGoal,
    required this.carbsToday,
    required this.carbsGoal,
    required this.fatToday,
    required this.fatGoal,
    required this.progress,
    required this.lastUpdatedAtMillis,
    required this.quickActions,
  });

  final int schemaVersion;
  final double caloriesToday;
  final double caloriesGoal;
  final double proteinToday;
  final double proteinGoal;
  final double carbsToday;
  final double carbsGoal;
  final double fatToday;
  final double fatGoal;
  final double progress;
  final int lastUpdatedAtMillis;
  final List<HomeWidgetQuickAction> quickActions;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'caloriesToday': caloriesToday,
      'caloriesGoal': caloriesGoal,
      'proteinToday': proteinToday,
      'proteinGoal': proteinGoal,
      'carbsToday': carbsToday,
      'carbsGoal': carbsGoal,
      'fatToday': fatToday,
      'fatGoal': fatGoal,
      'progress': progress,
      'lastUpdatedAtMillis': lastUpdatedAtMillis,
      'quickActions': quickActions.map((action) => action.toJson()).toList(),
    };
  }
}
