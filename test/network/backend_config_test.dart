import 'package:diplomka/network/backend_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendConfig.isConfigured', () {
    test('is false for empty baseUrl (fallback = direct OpenAI)', () {
      final config = BackendConfig(baseUrl: '', appToken: 'token');
      expect(config.isConfigured, isFalse);
    });

    test('is false for whitespace-only baseUrl', () {
      final config = BackendConfig(baseUrl: '   ', appToken: 'token');
      expect(config.isConfigured, isFalse);
    });

    test('is true for a non-empty baseUrl', () {
      final config = BackendConfig(baseUrl: 'https://api.example.com', appToken: 'token');
      expect(config.isConfigured, isTrue);
    });
  });

  group('BackendConfig.baseUrl', () {
    test('trims a single trailing slash', () {
      final config = BackendConfig(baseUrl: 'https://api.example.com/', appToken: 'token');
      expect(config.baseUrl, 'https://api.example.com');
    });

    test('leaves a URL without a trailing slash unchanged', () {
      final config = BackendConfig(baseUrl: 'https://api.example.com', appToken: 'token');
      expect(config.baseUrl, 'https://api.example.com');
    });

    test('trims surrounding whitespace', () {
      final config = BackendConfig(baseUrl: '  https://api.example.com/  ', appToken: 'token');
      expect(config.baseUrl, 'https://api.example.com');
    });
  });

  test('appToken is trimmed', () {
    final config = BackendConfig(baseUrl: 'https://api.example.com', appToken: '  secret  ');
    expect(config.appToken, 'secret');
  });
}
