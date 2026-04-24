import 'package:dio/dio.dart' as dio_package;
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OffProductDto {
  const OffProductDto({
    required this.code,
    this.productName,
    this.productNameCs,
    this.productNameEn,
    this.brands,
    this.quantity,
    this.imageFrontUrl,
    this.imageUrl,
    this.nutriments,
  });

  final String code;
  final String? productName;
  final String? productNameCs;
  final String? productNameEn;
  final String? brands;
  final String? quantity;
  final String? imageFrontUrl;
  final String? imageUrl;
  final Map<String, dynamic>? nutriments;

  factory OffProductDto.fromJson({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    return OffProductDto(
      code: _readString(json['code']) ?? barcode,
      productName: _readString(json['product_name']),
      productNameCs: _readString(json['product_name_cs']),
      productNameEn: _readString(json['product_name_en']),
      brands: _readString(json['brands']),
      quantity: _readString(json['quantity']),
      imageFrontUrl: _readString(json['image_front_url']),
      imageUrl: _readString(json['image_url']),
      nutriments: json['nutriments'] is Map<String, dynamic> ? json['nutriments'] as Map<String, dynamic> : null,
    );
  }

  static String? _readString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }
}

class OffLookupResponse {
  const OffLookupResponse({
    required this.found,
    this.product,
  });

  final bool found;
  final OffProductDto? product;
}

class OpenFoodFactsClient extends GetxService {
  static OpenFoodFactsClient get to => Get.find();

  static const String _contactEmail = 'jakub.s.andras@gmail.com';
  bool _hasUserAgentHeader = false;

  final dio_package.Dio _dio = dio_package.Dio(
    dio_package.BaseOptions(
      baseUrl: 'https://world.openfoodfacts.org',
      connectTimeout: 20000,
      receiveTimeout: 20000,
      sendTimeout: 20000,
    ),
  );

  Future<OffLookupResponse> fetchProductByBarcode(String barcode, {String? locale}) async {
    try {
      await _ensureUserAgentHeader();

      final response = await _dio.get(
        '/api/v2/product/$barcode.json',
        queryParameters: <String, dynamic>{
          'fields': 'code,product_name,product_name_cs,product_name_en,brands,quantity,image_front_url,image_url,nutriments,status',
          if (locale != null) 'lc': locale,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const OffLookupResponse(found: false);
      }

      final int status = _readInt(data['status']) ?? 0;
      final Map<String, dynamic>? productJson = data['product'] is Map<String, dynamic> ? data['product'] as Map<String, dynamic> : null;
      if (status != 1 || productJson == null) {
        return const OffLookupResponse(found: false);
      }

      return OffLookupResponse(
        found: true,
        product: OffProductDto.fromJson(
          barcode: barcode,
          json: productJson,
        ),
      );
    } on dio_package.DioError {
      rethrow;
    } catch (e) {
      throw OpenFoodFactsClientException(
        'Failed to process Open Food Facts response.',
        cause: e,
      );
    }
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> _ensureUserAgentHeader() async {
    if (_hasUserAgentHeader) return;

    String version = 'unknown';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.trim().isNotEmpty) {
        version = packageInfo.version.trim();
      }
    } catch (_) {}

    _dio.options.headers['User-Agent'] = 'Diplomka/$version ($_contactEmail)';
    _hasUserAgentHeader = true;
  }
}

class OpenFoodFactsClientException implements Exception {
  OpenFoodFactsClientException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return message;
    return '$message Cause: $cause';
  }
}
