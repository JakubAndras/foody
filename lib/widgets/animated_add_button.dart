import 'package:diplomka/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum AddButtonPhase { idle, loading, done }

/// Global notifiers so animation survives parent rebuilds.
final _addButtonNotifiers = <String, ValueNotifier<AddButtonPhase>>{};

ValueNotifier<AddButtonPhase> _getNotifier(String key) {
  return _addButtonNotifiers.putIfAbsent(key, () => ValueNotifier(AddButtonPhase.idle));
}

void _triggerAnimation(String key, VoidCallback onAdd) {
  final notifier = _getNotifier(key);
  if (notifier.value != AddButtonPhase.idle) return;
  HapticFeedback.mediumImpact();
  onAdd();
  notifier.value = AddButtonPhase.loading;
  Future.delayed(const Duration(milliseconds: 200), () {
    notifier.value = AddButtonPhase.done;
    Future.delayed(const Duration(milliseconds: 2200), () {
      notifier.value = AddButtonPhase.idle;
    });
  });
}

class AnimatedAddButton extends StatelessWidget {
  final String itemKey;
  final VoidCallback onAdd;
  final double size;

  const AnimatedAddButton({super.key, required this.itemKey, required this.onAdd, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AddButtonPhase>(
      valueListenable: _getNotifier(itemKey),
      builder: (context, phase, _) {
        final Widget child;
        switch (phase) {
          case AddButtonPhase.idle:
            child = GestureDetector(
              key: const ValueKey('add'),
              onTap: () => _triggerAnimation(itemKey, onAdd),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Icon(CupertinoIcons.add, color: AppColors.onPrimary, size: AppSizes.iconMd),
              ),
            );
          case AddButtonPhase.loading:
            child = SizedBox(
              key: const ValueKey('loading'),
              width: size,
              height: size,
              child: Padding(
                padding: EdgeInsets.all(size * 0.1875),
                child: CupertinoActivityIndicator(radius: size * 0.3125, color: AppColors.primary),
              ),
            );
          case AddButtonPhase.done:
            child = SizedBox(
              key: const ValueKey('done'),
              width: size,
              height: size,
              child: Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.success, size: size),
            );
        }
        return AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: child);
      },
    );
  }
}
