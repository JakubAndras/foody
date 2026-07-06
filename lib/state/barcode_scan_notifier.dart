import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BarcodeScanState {
  idle,
  scanning,
  lookupLoading,
  lookupSuccess,
  lookupNotFound,
  lookupError,
}

class BarcodeScanOutcome {
  const BarcodeScanOutcome._({
    required this.state,
    this.result,
    this.failureType,
    this.barcode,
    this.message,
  });

  final BarcodeScanState state;
  final BarcodeLookupResult? result;
  final BarcodeLookupFailureType? failureType;
  final String? barcode;
  final String? message;

  factory BarcodeScanOutcome.success(BarcodeLookupResult result) {
    return BarcodeScanOutcome._(
      state: BarcodeScanState.lookupSuccess,
      result: result,
      barcode: result.barcode,
    );
  }

  factory BarcodeScanOutcome.notFound(String barcode) {
    return BarcodeScanOutcome._(
      state: BarcodeScanState.lookupNotFound,
      barcode: barcode,
      failureType: BarcodeLookupFailureType.notFound,
      message: tr(LocaleKeys.error_barcode_product_not_found),
    );
  }

  factory BarcodeScanOutcome.error({
    required BarcodeLookupFailureType failureType,
    required String? message,
    required String? barcode,
  }) {
    return BarcodeScanOutcome._(
      state: BarcodeScanState.lookupError,
      failureType: failureType,
      message: message,
      barcode: barcode,
    );
  }
}

/// Immutable stav skenování čárového kódu.
///
/// Pole [scanState] nese enum [BarcodeScanState]. Kvůli kolizi s vlastním polem
/// `state` Notifieru (které drží tuto celou třídu) je záměrně pojmenováno `scanState`.
@immutable
class BarcodeScanUiState {
  const BarcodeScanUiState({
    this.scanState = BarcodeScanState.idle,
    this.latestResult,
    this.activeBarcode = '',
    this.latestMessage = '',
    this.latestFailureType,
  });

  final BarcodeScanState scanState;
  final BarcodeLookupResult? latestResult;
  final String activeBarcode;
  final String latestMessage;
  final BarcodeLookupFailureType? latestFailureType;

  /// Zpracování probíhá, dokud běží dotaz na produkt (stav `lookupLoading`).
  /// Slouží zároveň jako reentrancy guard v [BarcodeScanNotifier.processDetectedBarcode].
  bool get isProcessing => scanState == BarcodeScanState.lookupLoading;

  BarcodeScanUiState copyWith({
    BarcodeScanState? scanState,
    Object? latestResult = _undefined,
    String? activeBarcode,
    String? latestMessage,
    Object? latestFailureType = _undefined,
  }) {
    return BarcodeScanUiState(
      scanState: scanState ?? this.scanState,
      latestResult: latestResult == _undefined ? this.latestResult : latestResult as BarcodeLookupResult?,
      activeBarcode: activeBarcode ?? this.activeBarcode,
      latestMessage: latestMessage ?? this.latestMessage,
      latestFailureType: latestFailureType == _undefined ? this.latestFailureType : latestFailureType as BarcodeLookupFailureType?,
    );
  }
}

/// Sentinel pro `copyWith`, aby šlo nullovatelná pole explicitně nastavit na `null`.
const Object _undefined = Object();

class BarcodeScanNotifier extends Notifier<BarcodeScanUiState> {
  BarcodeLookupService get _lookupService => ref.read(barcodeLookupServiceProvider);

  static const Duration _duplicateCooldown = Duration(seconds: 3);
  DateTime? _lastProcessedAt;
  String? _lastProcessedBarcode;

  @override
  BarcodeScanUiState build() => const BarcodeScanUiState();

  void resetForScanning() {
    state = state.copyWith(
      scanState: BarcodeScanState.scanning,
      activeBarcode: '',
      latestMessage: '',
      latestFailureType: null,
    );
  }

  Future<BarcodeScanOutcome?> processDetectedBarcode(String rawBarcode) async {
    if (state.isProcessing) return null;
    final normalized = _lookupService.normalizeBarcode(rawBarcode);
    if (normalized == null) return null;
    if (_isDuplicateWithinCooldown(normalized)) return null;

    state = state.copyWith(
      scanState: BarcodeScanState.lookupLoading,
      activeBarcode: normalized,
      latestMessage: '',
      latestFailureType: null,
    );
    _lastProcessedBarcode = normalized;
    _lastProcessedAt = DateTime.now();

    try {
      final result = await _lookupService.lookupProductByBarcode(normalized);
      state = state.copyWith(
        latestResult: result,
        scanState: BarcodeScanState.lookupSuccess,
      );
      return BarcodeScanOutcome.success(result);
    } on BarcodeLookupException catch (e) {
      final message = e.message ?? _fallbackMessage(e.type);
      if (e.type == BarcodeLookupFailureType.notFound) {
        state = state.copyWith(
          latestFailureType: e.type,
          latestMessage: message,
          scanState: BarcodeScanState.lookupNotFound,
        );
        return BarcodeScanOutcome.notFound(normalized);
      }
      state = state.copyWith(
        latestFailureType: e.type,
        latestMessage: message,
        scanState: BarcodeScanState.lookupError,
      );
      return BarcodeScanOutcome.error(
        failureType: e.type,
        message: message,
        barcode: normalized,
      );
    }
  }

  bool _isDuplicateWithinCooldown(String barcode) {
    if (_lastProcessedBarcode != barcode) return false;
    final lastProcessedAt = _lastProcessedAt;
    if (lastProcessedAt == null) return false;
    return DateTime.now().difference(lastProcessedAt) <= _duplicateCooldown;
  }

  String _fallbackMessage(BarcodeLookupFailureType type) {
    switch (type) {
      case BarcodeLookupFailureType.invalidBarcode:
        return tr(LocaleKeys.error_barcode_unsupported);
      case BarcodeLookupFailureType.notFound:
        return tr(LocaleKeys.error_barcode_not_found);
      case BarcodeLookupFailureType.timeout:
        return tr(LocaleKeys.error_barcode_timeout);
      case BarcodeLookupFailureType.networkUnavailable:
        return tr(LocaleKeys.error_barcode_no_internet);
      case BarcodeLookupFailureType.apiError:
        return tr(LocaleKeys.error_barcode_service_unavailable);
      case BarcodeLookupFailureType.parseError:
        return tr(LocaleKeys.error_barcode_parse_failed);
    }
  }
}

final barcodeScanProvider = NotifierProvider<BarcodeScanNotifier, BarcodeScanUiState>(BarcodeScanNotifier.new);
