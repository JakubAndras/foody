import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

import '../model/recipe.dart';

// Displays a single recipe card with an image placeholder and nutritional details.
class RecipeCard extends StatefulWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isExpanded = false;

  // Toggles the expanded view of the card to show/hide nutritional details.
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16.0);

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        elevation: _isExpanded ? 4.0 : 2.0, // Subtle elevation change on expand
        margin: const EdgeInsets.all(8.0),
        color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image placeholder area
            AspectRatio(
              aspectRatio: 16 / 10, // Common aspect ratio for images
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300],
                  // Future: image: DecorationImage(image: AssetImage(widget.recipe.imageUrl), fit: BoxFit.cover),
                ),
                child: _isExpanded ? _buildExpandedDetails(theme) : _buildCollapsedTitle(theme, borderRadius),
              ),
            ),
            // Recipe name shown below image if not expanded, or if more space is needed
            if (!_isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  widget.recipe.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Builds the title overlay when the card is collapsed.
  Widget _buildCollapsedTitle(ThemeData theme, BorderRadius borderRadius) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          // Bottom corners are rounded if the text below is not shown
        ),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6],
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      alignment: Alignment.bottomLeft,
      child: Text(
        widget.recipe.name,
        style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(blurRadius: 2.0, color: Colors.black54, offset: Offset(1,1)),
            ]
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Builds the nutritional details overlay when the card is expanded.
  Widget _buildExpandedDetails(ThemeData theme) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6), // Semi-transparent overlay
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: <Widget>[
          Text(
            widget.recipe.name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          _buildNutrientRow('Energy', '${widget.recipe.calories.toStringAsFixed(0)} kcal', Colors.white, theme),
          _buildNutrientRow('Protein', '${widget.recipe.protein.toStringAsFixed(0)} g', AppColors.accentColor, theme),
          _buildNutrientRow('Carbs', '${widget.recipe.carbs.toStringAsFixed(0)} g', Colors.blue.shade300, theme),
          _buildNutrientRow('Fat', '${widget.recipe.fat.toStringAsFixed(0)} g', Colors.yellow.shade600, theme),
          _buildNutrientRow('Fiber', '${widget.recipe.fiber.toStringAsFixed(0)} g', Colors.green.shade300, theme),
        ],
      ),
    );
  }

  // Helper to build a single row for nutrient information with a colored dot.
  Widget _buildNutrientRow(String label, String value, Color dotColor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Text('$label $value', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
