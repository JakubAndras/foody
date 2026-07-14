import 'package:diplomka/utils/ai_model_constants.dart';

class _Pricing {
  final double inputPerM;
  final double cachedInputPerM;
  final double outputPerM;
  const _Pricing(this.inputPerM, this.cachedInputPerM, this.outputPerM);
}

class AiCostCalculator {
  static const Map<String, _Pricing> _table = {
    aiModelMain: _Pricing(2.50, 0.25, 15.00),
    aiModelPreScreen: _Pricing(0.75, 0.075, 4.50),
    aiModelFlagship: _Pricing(5.00, 0.50, 30.00),
  };

  static double? calculateCostUsd({
    required String model,
    required int promptTokens,
    required int completionTokens,
    int cachedTokens = 0,
  }) {
    final p = _table[model];
    if (p == null) return null;
    final nonCached = (promptTokens - cachedTokens).clamp(0, 1 << 30);
    return (nonCached / 1e6) * p.inputPerM + (cachedTokens / 1e6) * p.cachedInputPerM + (completionTokens / 1e6) * p.outputPerM;
  }
}
