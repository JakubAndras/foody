import 'package:diplomka/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PickerColumn extends StatefulWidget {
  const PickerColumn({
    super.key,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    this.height,
    this.itemExtent,
    this.showSelectionHighlight = true,
    this.selectionHighlightColor,
    this.selectionHighlightBorderRadius = 10,
    this.textStyle,
    this.selectedTextStyle,
    this.squeeze = 1.5,
    this.diameterRatio = 1.1,
    this.useDistanceOpacity = true,
  });

  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double? height;
  final double? itemExtent;
  final bool showSelectionHighlight;
  final Color? selectionHighlightColor;
  final double selectionHighlightBorderRadius;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;
  final double squeeze;
  final double diameterRatio;
  final bool useDistanceOpacity;

  @override
  State<PickerColumn> createState() => _PickerColumnState();
}

class _PickerColumnState extends State<PickerColumn> {
  int _selectedIndex = 0;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex.clamp(0, widget.values.length - 1);
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void didUpdateWidget(covariant PickerColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int nextSelected = widget.selectedIndex.clamp(0, widget.values.length - 1);
    if (nextSelected == _selectedIndex) return;
    _selectedIndex = nextSelected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.hasClients) {
        _controller.jumpToItem(nextSelected);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityForDistance(int distance) {
    switch (distance) {
      case 0:
        return 1.0;
      case 1:
        return 0.55;
      case 2:
        return 0.35;
      case 3:
        return 0.2;
      default:
        return 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double itemExtent = widget.itemExtent ?? AppSizes.pickerItemHeight;

    final picker = Stack(
      alignment: Alignment.center,
      children: [
        if (widget.showSelectionHighlight)
          Container(
            height: itemExtent,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: widget.selectionHighlightColor ?? AppColors.greyLight3,
              borderRadius: BorderRadius.circular(widget.selectionHighlightBorderRadius),
            ),
          ),
        CupertinoPicker(
          scrollController: _controller,
          backgroundColor: Colors.transparent,
          itemExtent: itemExtent,
          squeeze: widget.squeeze,
          useMagnifier: true,
          magnification: 1,
          diameterRatio: widget.diameterRatio,
          selectionOverlay: const SizedBox.shrink(),
          onSelectedItemChanged: (index) {
            setState(() => _selectedIndex = index);
            widget.onSelected(index);
          },
          children: List.generate(widget.values.length, (index) {
            final int distance = (index - _selectedIndex).abs();
            final bool isSelected = index == _selectedIndex;

            final TextStyle baseStyle = widget.textStyle ??
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                );

            final TextStyle selectedStyle = widget.selectedTextStyle ?? baseStyle.copyWith(fontWeight: FontWeight.w500);

            TextStyle style;
            if (isSelected) {
              style = selectedStyle;
            } else if (widget.useDistanceOpacity) {
              final double opacity = _opacityForDistance(distance);
              style = baseStyle.copyWith(
                color: (baseStyle.color ?? AppColors.textPrimary).withValues(alpha: opacity),
              );
            } else {
              style = baseStyle;
            }

            return Center(child: Text(widget.values[index], style: style));
          }),
        ),
      ],
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: picker);
    }
    return picker;
  }
}
