enum TrackingReminderType {
  breakfast,
  lunch,
  snack,
  dinner,
  endOfDay,
}

extension TrackingReminderTypeX on TrackingReminderType {
  String get code {
    switch (this) {
      case TrackingReminderType.breakfast:
        return 'breakfast';
      case TrackingReminderType.lunch:
        return 'lunch';
      case TrackingReminderType.snack:
        return 'snack';
      case TrackingReminderType.dinner:
        return 'dinner';
      case TrackingReminderType.endOfDay:
        return 'end_of_day';
    }
  }

  int get notificationId {
    switch (this) {
      case TrackingReminderType.breakfast:
        return 2001;
      case TrackingReminderType.lunch:
        return 2002;
      case TrackingReminderType.snack:
        return 2003;
      case TrackingReminderType.dinner:
        return 2004;
      case TrackingReminderType.endOfDay:
        return 2005;
    }
  }

  String get titleKey {
    switch (this) {
      case TrackingReminderType.breakfast:
        return 'tracking_reminders.type.breakfast';
      case TrackingReminderType.lunch:
        return 'tracking_reminders.type.lunch';
      case TrackingReminderType.snack:
        return 'tracking_reminders.type.snack';
      case TrackingReminderType.dinner:
        return 'tracking_reminders.type.dinner';
      case TrackingReminderType.endOfDay:
        return 'tracking_reminders.type.end_of_day';
    }
  }

  String get notificationBodyKey {
    switch (this) {
      case TrackingReminderType.breakfast:
        return 'tracking_reminders.notification_body.breakfast';
      case TrackingReminderType.lunch:
        return 'tracking_reminders.notification_body.lunch';
      case TrackingReminderType.snack:
        return 'tracking_reminders.notification_body.snack';
      case TrackingReminderType.dinner:
        return 'tracking_reminders.notification_body.dinner';
      case TrackingReminderType.endOfDay:
        return 'tracking_reminders.notification_body.end_of_day';
    }
  }

  int get defaultHour {
    switch (this) {
      case TrackingReminderType.breakfast:
        return 8;
      case TrackingReminderType.lunch:
        return 11;
      case TrackingReminderType.snack:
        return 16;
      case TrackingReminderType.dinner:
        return 18;
      case TrackingReminderType.endOfDay:
        return 21;
    }
  }

  int get defaultMinute {
    switch (this) {
      case TrackingReminderType.breakfast:
        return 30;
      case TrackingReminderType.lunch:
        return 30;
      case TrackingReminderType.snack:
        return 0;
      case TrackingReminderType.dinner:
        return 0;
      case TrackingReminderType.endOfDay:
        return 0;
    }
  }

  bool get defaultEnabled {
    switch (this) {
      case TrackingReminderType.breakfast:
        return true;
      case TrackingReminderType.lunch:
        return true;
      case TrackingReminderType.snack:
        return false;
      case TrackingReminderType.dinner:
        return true;
      case TrackingReminderType.endOfDay:
        return false;
    }
  }
}

class TrackingReminderSetting {
  const TrackingReminderSetting({
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final TrackingReminderType type;
  final bool enabled;
  final int hour;
  final int minute;

  TrackingReminderSetting copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return TrackingReminderSetting(
      type: type,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  static TrackingReminderSetting defaults(TrackingReminderType type) {
    return TrackingReminderSetting(
      type: type,
      enabled: type.defaultEnabled,
      hour: type.defaultHour,
      minute: type.defaultMinute,
    );
  }
}
