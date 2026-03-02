import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/barcode_lookup_result.dart';
import 'package:diplomka/services/barcode_lookup_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

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

class BarcodeScanController extends GetxController {
  static BarcodeScanController get to => Get.find();

  BarcodeScanController({
    required BarcodeLookupService lookupService,
  }) : _lookupService = lookupService;

  final BarcodeLookupService _lookupService;

  final Rx<BarcodeScanState> state = BarcodeScanState.idle.obs;
  final Rxn<BarcodeLookupResult> latestResult = Rxn<BarcodeLookupResult>();
  final RxString activeBarcode = ''.obs;
  final RxString latestMessage = ''.obs;
  final Rxn<BarcodeLookupFailureType> latestFailureType = Rxn<BarcodeLookupFailureType>();

  static const Duration _duplicateCooldown = Duration(seconds: 3);
  DateTime? _lastProcessedAt;
  String? _lastProcessedBarcode;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void resetForScanning() {
    state.value = BarcodeScanState.scanning;
    activeBarcode.value = '';
    latestMessage.value = '';
    latestFailureType.value = null;
  }

  Future<BarcodeScanOutcome?> processDetectedBarcode(String rawBarcode) async {
    if (_isProcessing) return null;
    final normalized = _lookupService.normalizeBarcode(rawBarcode);
    if (normalized == null) return null;
    if (_isDuplicateWithinCooldown(normalized)) return null;

    _isProcessing = true;
    state.value = BarcodeScanState.lookupLoading;
    activeBarcode.value = normalized;
    latestMessage.value = '';
    latestFailureType.value = null;
    _lastProcessedBarcode = normalized;
    _lastProcessedAt = DateTime.now();

    try {
      final result = await _lookupService.lookupProductByBarcode(normalized);
      latestResult.value = result;
      state.value = BarcodeScanState.lookupSuccess;
      return BarcodeScanOutcome.success(result);
    } on BarcodeLookupException catch (e) {
      latestFailureType.value = e.type;
      latestMessage.value = e.message ?? _fallbackMessage(e.type);
      if (e.type == BarcodeLookupFailureType.notFound) {
        state.value = BarcodeScanState.lookupNotFound;
        return BarcodeScanOutcome.notFound(normalized);
      }
      state.value = BarcodeScanState.lookupError;
      return BarcodeScanOutcome.error(
        failureType: e.type,
        message: latestMessage.value,
        barcode: normalized,
      );
    } finally {
      _isProcessing = false;
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
