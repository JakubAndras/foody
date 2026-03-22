import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A scaffold that shows Revert / Save buttons above the keyboard when any
/// tracked [FocusNode] has focus. The area behind the keyboard is white;
/// the main content area uses [AppColors.background].
///
/// Usage:
/// 1. Create [FocusNode]s for your text fields.
/// 2. Pass them to [focusNodes] so the bar appears when any field is focused.
/// 3. Provide [onRevert] and [onSave] callbacks.
class KeyboardActionScaffold extends StatefulWidget {
  const KeyboardActionScaffold({
    super.key,
    required this.focusNodes,
    required this.onRevert,
    required this.onSave,
    required this.child,
    this.saveLabel,
    this.revertLabel,
    this.actionsEnabled = true,
    this.bottomBar,
  });

  final List<FocusNode> focusNodes;
  final VoidCallback onRevert;
  final VoidCallback? onSave;
  final Widget child;
  final String? saveLabel;
  final String? revertLabel;
  final bool actionsEnabled;

  /// Optional widget shown at the bottom when keyboard is hidden.
  final Widget? bottomBar;

  @override
  State<KeyboardActionScaffold> createState() => _KeyboardActionScaffoldState();
}

class _KeyboardActionScaffoldState extends State<KeyboardActionScaffold> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    for (final node in widget.focusNodes) {
      node.addListener(_onFocusChanged);
    }
  }

  @override
  void didUpdateWidget(covariant KeyboardActionScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNodes != widget.focusNodes) {
      for (final node in oldWidget.focusNodes) {
        node.removeListener(_onFocusChanged);
      }
      for (final node in widget.focusNodes) {
        node.addListener(_onFocusChanged);
      }
      _onFocusChanged();
    }
  }

  @override
  void dispose() {
    for (final node in widget.focusNodes) {
      node.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onFocusChanged() {
    final anyFocused = widget.focusNodes.any((n) => n.hasFocus);
    if (anyFocused != _hasFocus) {
      setState(() => _hasFocus = anyFocused);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: widget.child),
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 200),
                heightFactor: _hasFocus ? 1.0 : 0.0,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.s, AppSpacing.screen, AppSpacing.s),
                  child: Row(
                    children: [
                      Expanded(
                        child: FoodySecondaryButton(
                          label: widget.revertLabel ?? tr(LocaleKeys.common_revert),
                          onTap: widget.actionsEnabled ? widget.onRevert : null,
                          height: AppSizes.buttonHeight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: FoodyPrimaryButton(
                          label: widget.saveLabel ?? tr(LocaleKeys.common_save),
                          onTap: widget.actionsEnabled ? widget.onSave : null,
                          height: AppSizes.buttonHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: SizedBox(width: double.infinity, height: keyboardHeight),
            ),
            if (!_hasFocus && keyboardHeight == 0 && widget.bottomBar != null) widget.bottomBar!,
          ],
        ),
      ),
    );
  }
}
