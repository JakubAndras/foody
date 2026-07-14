import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Konfigurace backendového AI proxy.
///
/// Čte `BACKEND_BASE_URL` a `BACKEND_APP_TOKEN` z `.env`. Dokud je base URL
/// prázdné, [isConfigured] vrací `false` a volající kód drží původní přímé
/// volání OpenAI (fallback). Jakmile se base URL vyplní, requesty jdou přes
/// proxy s hlavičkami `Authorization: Bearer <appToken>` a `X-Device-Id`.
class BackendConfig {
  /// Pro produkci se hodnoty berou z `.env`. Explicitní argumenty slouží
  /// hlavně testům, aby nemusely nahrávat dotenv.
  BackendConfig({String? baseUrl, String? appToken})
      : _rawBaseUrl = baseUrl ?? dotenv.env['BACKEND_BASE_URL'] ?? '',
        _rawAppToken = appToken ?? dotenv.env['BACKEND_APP_TOKEN'] ?? '';

  final String _rawBaseUrl;
  final String _rawAppToken;

  /// Base URL bez koncového lomítka.
  String get baseUrl {
    final trimmed = _rawBaseUrl.trim();
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  String get appToken => _rawAppToken.trim();

  /// `true` = requesty jdou přes backend proxy; `false` = přímé volání OpenAI.
  bool get isConfigured => baseUrl.isNotEmpty;
}

/// Co-located provider. Čte hodnoty z `.env` (načteno v `main()` přes dotenv).
final backendConfigProvider = Provider<BackendConfig>((ref) => BackendConfig());
