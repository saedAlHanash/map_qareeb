import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';


class ErrorManager {
  static String getApiError(Response response) {
    switch (response.statusCode) {
      case 401:
        return ' المستخدم الحالي لم يسجل الدخول ' '${response.statusCode}';

      case 503:
        return 'حدث تغيير في المخدم رمز الخطأ 503 ' '${response.statusCode}';
      case 481:
        return 'لا يوجد اتصال بالانترنت' '${response.statusCode}';

      case 404:
      case 500:
      default:
        try {
          final errorBody = ErrorBody.fromJson(jsonDecode(response.body));
          return errorBody.error.message;
        } on Exception {
          return 'error';
        }
    }
  }
}

class ErrorBody {
  ErrorBody({required this.error});

  final Error error;

  factory ErrorBody.fromJson(Map<String, dynamic> json) {
    return ErrorBody(
      error: json['error'] == null ? Error.fromJson({}) : Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() => {'error': error.toJson()};
}

class Error {
  Error({
    required this.code,
    required this.message,
    required this.details,
    required this.validationErrors,
  });

  final num code;
  final String message;
  final dynamic details;
  final dynamic validationErrors;

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      details: json['details'],
      validationErrors: json['validationErrors'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'details': details,
        'validationErrors': validationErrors,
      };
}
