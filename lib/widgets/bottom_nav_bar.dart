import 'package:flutter/material.dart';

// Custom Bottom Navigation Bar widget
class BottomNavBar extends StatelessWidget {
  final int? currentIndex; // Make nullable or provide a default
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Helper method to build individual navigation items
  Widget _buildNavItem({
    required IconData icon,
    String? label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16), // Optional: for ink ripple effect
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 24),
              const SizedBox(height: 4),
              label != null
                  ? Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? activeColor : inactiveColor,
                        fontSize: 10, // Reduced font size for a cleaner look
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color activeColor = theme.colorScheme.primary;
    final Color inactiveColor = isDark ? Colors.grey[600]! : Colors.grey[700]!;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      // Space for the FAB
      color: isDark ? Colors.grey[850] : Colors.white,
      // Darker for dark theme, white for light
      elevation: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(icon: Icons.home, index: 0, activeColor: activeColor, inactiveColor: inactiveColor),
          const Expanded(child: SizedBox()),
          _buildNavItem(icon: Icons.restaurant_menu_rounded, index: 1, activeColor: activeColor, inactiveColor: inactiveColor),
        ],
      ),
    );
  }
}
