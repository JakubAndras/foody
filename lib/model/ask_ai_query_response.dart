import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

class AskAiQueryResponse {
  final String responseText;
  final String insightType;
  final int summaryValue;
  final String summaryLabel;
  final List<AskAiAffectedDay> affectedDays;
  final String periodLabel;

  const AskAiQueryResponse({
    required this.responseText,
    required this.insightType,
    required this.summaryValue,
    required this.summaryLabel,
    required this.affectedDays,
    required this.periodLabel,
  });

  factory AskAiQueryResponse.fromJson(Map<String, dynamic> json) {
    final rawDays = json['affected_days'] as List<dynamic>? ?? [];
    final days = rawDays.map((d) {
      if (d is Map<String, dynamic>) {
        return AskAiAffectedDay(
          year: (d['year'] as num).toInt(),
          month: (d['month'] as num).toInt(),
          day: (d['day'] as num).toInt(),
        );
      }
      return null;
    }).whereType<AskAiAffectedDay>().toList();

    return AskAiQueryResponse(
      responseText: json['response_text'] as String? ?? '',
      insightType: json['insight_type'] as String? ?? 'tracked',
      summaryValue: (json['summary_value'] as num?)?.toInt() ?? 0,
      summaryLabel: json['summary_label'] as String? ?? '',
      affectedDays: days,
      periodLabel: json['period_label'] as String? ?? '',
    );
  }

  IconData get summaryIcon {
    switch (insightType) {
      case 'violations':
        return Icons.report_gmailerrorred_outlined;
      case 'achieved':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  LinearGradient get summaryGradient {
    switch (insightType) {
      case 'violations':
        return AppGradients.askAiDanger;
      case 'achieved':
        return AppGradients.askAiSuccess;
      default:
        return AppGradients.askAiWarning;
    }
  }

  LinearGradient get summarySurfaceGradient {
    switch (insightType) {
      case 'violations':
        return AppGradients.askAiDangerSurface;
      case 'achieved':
        return AppGradients.askAiSuccessSurface;
      default:
        return AppGradients.askAiWarningSurface;
    }
  }

  /// Groups affected days by year-month and returns day numbers per month.
  /// Returns the first month found (for calendar display).
  int get primaryMonth => affectedDays.isNotEmpty ? affectedDays.first.month : DateTime.now().month;
  int get primaryYear => affectedDays.isNotEmpty ? affectedDays.first.year : DateTime.now().year;

  List<int> get primaryMonthDays {
    final m = primaryMonth;
    final y = primaryYear;
    return affectedDays.where((d) => d.year == y && d.month == m).map((d) => d.day).toList();
  }
}

class AskAiAffectedDay {
  final int year;
  final int month;
  final int day;

  const AskAiAffectedDay({required this.year, required this.month, required this.day});
}
