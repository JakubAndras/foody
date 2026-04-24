import 'dart:io';

import 'package:dio/dio.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:diplomka/network/open_food_facts_client.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

enum BarcodeLookupFailureType {
  invalidBarcode,
  notFound,
  timeout,
  networkUnavailable,
  apiError,
  parseError,
}

class BarcodeLookupException implements Exception {
  BarcodeLookupException(this.type, {this.message});

  final BarcodeLookupFailureType type;
  final String? message;

  @override
  String toString() {
    return message ?? type.name;
  }
}

class BarcodeLookupService extends GetxService {
  static BarcodeLookupService get to => Get.find();

  BarcodeLookupService({
    required OpenFoodFactsClient client,
  }) : _client = client;

  final OpenFoodFactsClient _client;

  String? normalizeBarcode(String rawBarcode) {
    final normalized = rawBarcode.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;
    return normalized;
  }

  bool isSupportedBarcode(String barcode) {
    return barcode.length == 8 || barcode.length == 12 || barcode.length == 13 || barcode.length == 14;
  }

  Future<BarcodeLookupResult> lookupProductByBarcode(String rawBarcode) async {
    final normalized = normalizeBarcode(rawBarcode);
    if (normalized == null || !isSupportedBarcode(normalized)) {
      throw BarcodeLookupException(
        BarcodeLookupFailureType.invalidBarcode,
        message: tr(LocaleKeys.error_barcode_unsupported),
      );
    }

    try {
      final appLocale = Get.locale?.languageCode ?? 'cs';
      final lookupResponse = await _client.fetchProductByBarcode(normalized, locale: appLocale);
      final product = lookupResponse.product;
      if (!lookupResponse.found || product == null) {
        throw BarcodeLookupException(
          BarcodeLookupFailureType.notFound,
          message: tr(LocaleKeys.error_barcode_not_found),
        );
      }

      final productName = _resolveProductName(product);
      if (productName.isEmpty) {
        throw BarcodeLookupException(
          BarcodeLookupFailureType.parseError,
          message: tr(LocaleKeys.error_barcode_no_name),
        );
      }

      final nutriments = BarcodeNutriments(
        caloriesPer100g: _readFirstAvailableNutriment(
          product.nutriments,
          const <String>['energy-kcal_100g', 'energy-kcal'],
        ),
        proteinsPer100g: _readFirstAvailableNutriment(
          product.nutriments,
          const <String>['proteins_100g', 'proteins'],
        ),
        carbsPer100g: _readFirstAvailableNutriment(
          product.nutriments,
          const <String>['carbohydrates_100g', 'carbohydrates'],
        ),
        fatsPer100g: _readFirstAvailableNutriment(
          product.nutriments,
          const <String>['fat_100g', 'fat'],
        ),
      );
      final bool hasCompleteNutrientsForDirectUse = nutriments.caloriesPer100g != null &&
          _readDouble(product.nutriments?['proteins_100g']) != null &&
          _readDouble(product.nutriments?['carbohydrates_100g']) != null &&
          _readDouble(product.nutriments?['fat_100g']) != null;

      return BarcodeLookupResult(
        barcode: product.code,
        productName: productName,
        brand: _cleanString(product.brands),
        quantity: _cleanString(product.quantity),
        imageUrl: _cleanString(product.imageFrontUrl) ?? _cleanString(product.imageUrl),
        nutriments: nutriments,
        hasCompleteNutrientsForDirectUse: hasCompleteNutrientsForDirectUse,
      );
    } on BarcodeLookupException {
      rethrow;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout || e.type == DioErrorType.sendTimeout || e.type == DioErrorType.receiveTimeout) {
        throw BarcodeLookupException(BarcodeLookupFailureType.timeout, message: tr(LocaleKeys.error_barcode_timeout));
      }
      if (e.type == DioErrorType.other && e.error is SocketException) {
        throw BarcodeLookupException(BarcodeLookupFailureType.networkUnavailable, message: tr(LocaleKeys.error_barcode_no_internet));
      }
      throw BarcodeLookupException(BarcodeLookupFailureType.apiError, message: tr(LocaleKeys.error_barcode_service_unavailable));
    } catch (_) {
      throw BarcodeLookupException(BarcodeLookupFailureType.parseError, message: tr(LocaleKeys.error_barcode_parse_failed));
    }
  }

  String _resolveProductName(OffProductDto product) {
    final appLocale = Get.locale?.languageCode ?? 'cs';
    if (appLocale == 'cs') {
      final czechName = _cleanString(product.productNameCs);
      if (czechName != null) return czechName;
    }
    final localizedName = _cleanString(product.productName);
    if (localizedName != null) return localizedName;
    final englishName = _cleanString(product.productNameEn);
    if (englishName != null) return englishName;
    return '';
  }

  /// Returns a country/region hint based on EAN-13 prefix (GS1 country code).
  /// Returns null for non-EAN-13 or unrecognized prefixes.
  String? getEanCountryHint(String barcode) {
    if (barcode.length != 13) return null;
    final prefix3 = int.tryParse(barcode.substring(0, 3));
    if (prefix3 == null) return null;

    if (prefix3 == 859) return 'Czech Republic';
    if (prefix3 == 858) return 'Slovakia';
    if (prefix3 == 590) return 'Poland';
    if (prefix3 >= 400 && prefix3 <= 440) return 'Germany';
    if (prefix3 >= 900 && prefix3 <= 919) return 'Austria';
    if (prefix3 == 599) return 'Hungary';
    if (prefix3 >= 300 && prefix3 <= 379) return 'France';
    if (prefix3 >= 800 && prefix3 <= 839) return 'Italy';
    if (prefix3 >= 840 && prefix3 <= 849) return 'Spain';
    if (prefix3 >= 500 && prefix3 <= 509) return 'United Kingdom';
    if (prefix3 >= 870 && prefix3 <= 879) return 'Netherlands';
    if (prefix3 >= 540 && prefix3 <= 549) return 'Belgium/Luxembourg';

    return null;
  }

  String? _cleanString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double? _readFirstAvailableNutriment(
    Map<String, dynamic>? nutriments,
    List<String> keys,
  ) {
    if (nutriments == null) return null;
    for (final key in keys) {
      final value = _readDouble(nutriments[key]);
      if (value != null) return value;
    }
    return null;
  }
}
