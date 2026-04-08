import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum MotivationalSummaryType {
  daily,
  weekly,
  monthly,
}

extension MotivationalSummaryTypeX on MotivationalSummaryType {
  String get code {
    switch (this) {
      case MotivationalSummaryType.daily:
        return 'daily';
      case MotivationalSummaryType.weekly:
        return 'weekly';
      case MotivationalSummaryType.monthly:
        return 'monthly';
    }
  }

  int get notificationId {
    switch (this) {
      case MotivationalSummaryType.daily:
        return 3001;
      case MotivationalSummaryType.weekly:
        return 3002;
      case MotivationalSummaryType.monthly:
        return 3003;
    }
  }

  String get titleKey {
    switch (this) {
      case MotivationalSummaryType.daily:
        return 'motivational_summary_type_daily';
      case MotivationalSummaryType.weekly:
        return 'motivational_summary_type_weekly';
      case MotivationalSummaryType.monthly:
        return 'motivational_summary_type_monthly';
    }
  }

  String get notificationBodyKey {
    switch (this) {
      case MotivationalSummaryType.daily:
        return 'motivational_summary_body_daily';
      case MotivationalSummaryType.weekly:
        return 'motivational_summary_body_weekly';
      case MotivationalSummaryType.monthly:
        return 'motivational_summary_body_monthly';
    }
  }

  int get defaultHour {
    switch (this) {
      case MotivationalSummaryType.daily:
        return 20;
      case MotivationalSummaryType.weekly:
        return 10;
      case MotivationalSummaryType.monthly:
        return 10;
    }
  }

  int get defaultMinute => 0;

  bool get defaultEnabled => this == MotivationalSummaryType.weekly;

  DateTimeComponents get dateTimeComponents {
    switch (this) {
      case MotivationalSummaryType.daily:
        return DateTimeComponents.time;
      case MotivationalSummaryType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case MotivationalSummaryType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
    }
  }
}

class MotivationalSummarySetting {
  const MotivationalSummarySetting({
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final MotivationalSummaryType type;
  final bool enabled;
  final int hour;
  final int minute;

  MotivationalSummarySetting copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return MotivationalSummarySetting(
      type: type,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  static MotivationalSummarySetting defaults(MotivationalSummaryType type) {
    return MotivationalSummarySetting(
      type: type,
      enabled: type.defaultEnabled,
      hour: type.defaultHour,
      minute: type.defaultMinute,
    );
  }
}
