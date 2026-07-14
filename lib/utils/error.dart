import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:html_character_entities/html_character_entities.dart';

import 'package:diplomka/generated/locale_keys.g.dart';

/// DTO class that parses and holds data about server errors.
class Error {
  /// HTTP error code.
  int? code;

  /// HTTP error code.
  int? serverCode;

  /// Required error message.
  String? message;

  /// Optional error description.
  String? description;

  ErrorType? errorType;

  Error(this.errorType, {this.code, this.serverCode, this.message, this.description});

  bool get shouldShowTryAgainButton {
    switch (errorType) {
      case ErrorType.timeout:
      case ErrorType.noInternetConnection:
      case ErrorType.serverError:
        return true;
      default:
        return false;
    }
  }

  Error.generic({int? statusCode, this.serverCode, String? message, String? description}) {
    code = statusCode;
    errorType = ErrorType.generic;
    this.message = message ?? tr(LocaleKeys.error_generic);
    this.description = description ?? tr(LocaleKeys.error_generic_message);
  }

  Error.serverError() {
    errorType = ErrorType.serverError;
    message = tr(LocaleKeys.error_generic);
    description = tr(LocaleKeys.error_generic_message);
  }

  Error.timeout() {
    errorType = ErrorType.timeout;
    message = tr(LocaleKeys.error_timeout);
    description = tr(LocaleKeys.error_timeout_message);
  }

  Error.noInternetConnection() {
    errorType = ErrorType.noInternetConnection;
    message = tr(LocaleKeys.error_no_internet);
    description = tr(LocaleKeys.error_no_internet_message);
  }

  /// Constructor that creates an [Error] by parsing the [DioError] returned inside HTTP response.
  factory Error.fromDioError(DioError dioError) {
    final int? statusCode = dioError.response?.statusCode;

    dynamic map;
    if (dioError.response?.data is Map) {
      map = dioError.response?.data;
    } else if (dioError.response?.data is List && (dioError.response?.data as List).isNotEmpty) {
      map = dioError.response?.data[0];
    } else if (dioError.response?.data is String) {
      try {
        map = jsonDecode(dioError.response?.data);
      } catch (_) {
        map = {
          "error": {"message": dioError.response?.data}
        };
      }
    }
    String? message, description;
    int? serverCode;
    if (map != null && map is Map<String, dynamic>) {
      if (map["error"] is Map<String, dynamic>) {
        final Map<String, dynamic>? errorJson = map["error"] as Map<String, dynamic>?;
        if (errorJson != null) {
          message = errorJson["message"] as String?;
          description = errorJson["details"] as String?;

          if (errorJson["code"] is int?) {
            serverCode = errorJson["code"] as int?;
          } else {
            if (kDebugMode) {
              debugPrint('error.dart fromDioError: ${errorJson["code"]}');
              // todo Logger class
            }
          }
        }
      }
    }

    if (statusCode != null && statusCode > 500) {
      return Error.generic(statusCode: statusCode, serverCode: serverCode, message: message, description: description);
    }
    if (dioError.type == DioErrorType.other) {
      if (dioError.error != null && dioError.error is SocketException) {
        return Error.noInternetConnection();
      }
      return Error.generic(message: message, serverCode: serverCode, description: description);
    }
    if (dioError.type == DioErrorType.cancel) {
      return Error.generic(message: message, serverCode: serverCode, description: description);
    }
    if (dioError.type == DioErrorType.connectTimeout || dioError.type == DioErrorType.receiveTimeout || dioError.type == DioErrorType.sendTimeout) {
      return Error.timeout();
    }

    final Error error = Error(ErrorType.serverError, code: statusCode, serverCode: serverCode, message: message, description: description);
    return error.decoded;
  }

  Error get decoded {
    if (message != null) {
      message = HtmlCharacterEntities.decode(message!);
    }
    if (description != null) {
      description = HtmlCharacterEntities.decode(description!);
    }
    return this;
  }

  String? get detailMessage {
    if (description?.isNotEmpty ?? false) {
      return description;
    }
    if (message?.isNotEmpty ?? false) {
      return message;
    }
    return null;
  }

  @override
  String toString() {
    if (description?.isNotEmpty ?? false) {
      return description!;
    }
    if (message?.isNotEmpty ?? false) {
      return message!;
    }
    return "Status code $code - type $errorType";
  }
}

enum ErrorType {
  generic,
  timeout,
  serverError,
  noInternetConnection,
  missingData,
}

ErrorType resolveTypeFromErrorMessage(String? message) {
  ErrorType type = ErrorType.generic;
  switch (message) {
    default:
      type = ErrorType.generic;
  }
  return type;
}
