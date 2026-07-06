import 'package:flutter_test/flutter_test.dart';
import 'package:diplomka/utils/ai_cost_calculator.dart';
import 'package:diplomka/utils/ai_model_constants.dart';

void main() {
  group('AiCostCalculator', () {
    test('gpt-5.4 baseline call without cache', () {
      final cost = AiCostCalculator.calculateCostUsd(model: aiModelMain, promptTokens: 2000, completionTokens: 600);
      expect(cost, closeTo(0.014, 1e-6));
    });

    test('gpt-5.4 call with 800 cached tokens', () {
      final cost = AiCostCalculator.calculateCostUsd(model: aiModelMain, promptTokens: 2000, completionTokens: 600, cachedTokens: 800);
      expect(cost, closeTo(0.0122, 1e-6));
    });

    test('gpt-5.4-mini pricing', () {
      final cost = AiCostCalculator.calculateCostUsd(model: aiModelPreScreen, promptTokens: 1000, completionTokens: 20);
      expect(cost, closeTo(0.00084, 1e-7));
    });

    test('gpt-5.5 pricing', () {
      final cost = AiCostCalculator.calculateCostUsd(model: aiModelFlagship, promptTokens: 2000, completionTokens: 600);
      expect(cost, closeTo(0.028, 1e-6));
    });

    test('unknown model returns null', () {
      expect(AiCostCalculator.calculateCostUsd(model: 'gpt-future', promptTokens: 100, completionTokens: 10), isNull);
    });

    test('cachedTokens greater than promptTokens does not produce negative input', () {
      final cost = AiCostCalculator.calculateCostUsd(model: aiModelMain, promptTokens: 100, completionTokens: 0, cachedTokens: 500);
      expect(cost, greaterThanOrEqualTo(0));
    });
  });
}
