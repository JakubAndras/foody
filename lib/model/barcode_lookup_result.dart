class BarcodeNutriments {
  const BarcodeNutriments({
    this.caloriesPer100g,
    this.proteinsPer100g,
    this.carbsPer100g,
    this.fatsPer100g,
  });

  final double? caloriesPer100g;
  final double? proteinsPer100g;
  final double? carbsPer100g;
  final double? fatsPer100g;

  bool get hasAnyValue => caloriesPer100g != null || proteinsPer100g != null || carbsPer100g != null || fatsPer100g != null;
}

class BarcodeLookupResult {
  const BarcodeLookupResult({
    required this.barcode,
    required this.productName,
    this.brand,
    this.quantity,
    this.imageUrl,
    required this.nutriments,
    required this.hasCompleteNutrientsForDirectUse,
  });

  final String barcode;
  final String productName;
  final String? brand;
  final String? quantity;
  final String? imageUrl;
  final BarcodeNutriments nutriments;
  final bool hasCompleteNutrientsForDirectUse;
}
