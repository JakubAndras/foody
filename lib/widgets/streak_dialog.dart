import 'package:diplomka/model/streak_info.dart';
import 'package:diplomka/controller/streak_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';

// Displays streak information in a dialog.
class StreakDialog extends StatelessWidget {
  const StreakDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      contentPadding: const EdgeInsets.all(24.0),
      content: FutureBuilder<StreakInfo>(
        future: StreakController.to.getStreakInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(tr(LocaleKeys.streak_error_loading, namedArgs: {'error': snapshot.error.toString()}), textAlign: TextAlign.center),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final streakInfo = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.local_fire_department, size: 80, color: Colors.orange), // Large flame icon
                const SizedBox(height: 16),
                Text(
                  tr(LocaleKeys.streak_title, namedArgs: {'count': streakInfo.currentStreak.toString()}),
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    bool isActive = streakInfo.activeDaysThisWeek[index];
                    return Column(
                      children: [
                        Text(
                          dayLetters[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isActive ? Colors.orange : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.orange.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                            border: Border.all(
                              color: isActive ? Colors.orange : Colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: isActive
                              ? const Icon(Icons.check, size: 14, color: Colors.orange)
                              : null,
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(
                  tr(LocaleKeys.streak_motivational),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr(LocaleKeys.streak_continue)),
                ),
              ],
            );
          } else {
            return Center(
              child: Text(tr(LocaleKeys.streak_no_data)),
            );
          }
        },
      ),
    );
  }
}
