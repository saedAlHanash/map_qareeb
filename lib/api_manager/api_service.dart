import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:qareeb_models/extensions.dart';

import 'api_url.dart';

var loggerObject = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    // number of method calls to be displayed
    errorMethodCount: 0,
    // number of method calls if stacktrace is provided
    lineLength: 300,
    // width of the output
    colors: true,
    // Colorful log messages
    printEmojis: false,
    // Print an emoji for each log message
    printTime: false,
  ),
);

DateTime? _serverDate;

DateTime get getServerDate => _serverDate ?? DateTime.now();

DateTime getDateTimeFromHeaders(http.Response response) {
  final headers = response.headers;

  if (headers.containsKey('date')) {
    final dateString = headers['date']!;

    final dateTime = parseGMTDate(dateString);
    return dateTime.addFromNow();
  } else {
    return DateTime.now();
  }
}

DateTime parseGMTDate(String dateString) {
  final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
  return formatter.parseUTC(dateString);
}

class APIService {
  static APIService _singleton = APIService._internal();

  factory APIService() => _singleton;

  factory APIService.reInitial() {
    _singleton = APIService._internal();
    return _singleton;
  }

  final innerHeader = {
    'Content-Type': 'application/json',
    'X-Frame-Options': 'SAMEORIGIN',
    'origin': 'x-requested-with',
    'x-cors-api-key': 'temp_799a1d2ffd29044df4096f5eeda48646',
  };

  APIService._internal();

  Future<DateTime> getServerTime() async {
    if (_serverDate != null) return _serverDate!;
    var uri = Uri.https(baseUrl);

    final response = await http.get(uri, headers: innerHeader).timeout(
          const Duration(seconds: 40),
          onTimeout: () => http.Response('connectionTimeOut', 481),
        );

    _serverDate = getDateTimeFromHeaders(response);

    return _serverDate!;
  }

  Future<http.Response> getApi({
    required String url,
    Map<String, dynamic>? query,
    Map<String, String>? header,
    String? path,
    String? host,
  }) async {
    if (query != null) query.removeWhere((key, value) => value == null);

    innerHeader.addAll(header ?? {});

    if (path != null) url = '$url/$path';

    if (query != null) {
      query.removeWhere((key, value) => value == null);
      query.forEach((key, value) => query[key] = value.toString());
    }

    logRequest(url, query);

    final uri = Uri.https(host ?? baseUrl, url, query);
    try {
      final response = await http.get(uri, headers: innerHeader).timeout(
            const Duration(seconds: 400),
            onTimeout: () => http.Response('connectionTimeOut', 481),
          );

      _serverDate = getDateTimeFromHeaders(response);
      logResponse(url, response);
      return response;
    } catch (error) {
      return http.Response('connectionTimeOut', 481);
    }
  }

  Uri getUri({
    required String url,
    Map<String, dynamic>? query,
    Map<String, String>? header,
    String? path,
    String? hostName,
  }) {
    if (query != null) query.removeWhere((key, value) => value == null);

    innerHeader.addAll(header ?? {});

    if (path != null) url = '$url/$path';

    if (query != null) {
      query.removeWhere((key, value) => value == null);
      query.forEach((key, value) => query[key] = value.toString());
    }

    logRequest('${hostName ?? ''}$url', query);

    final uri = Uri.https(hostName ?? baseUrl, url, query);

    return uri;
  }

  Future<http.Response> postApi({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    Map<String, String>? header,
  }) async {
    if (body != null) body.removeWhere((key, value) => value == null);

    if (query != null) {
      query.removeWhere((key, value) => value == null);
      query.forEach((key, value) => query[key] = value.toString());
    }

    innerHeader.addAll(header ?? {});

    final uri = Uri.https(baseUrl, url, query);

    logRequest(url, (body ?? {})..addAll(query ?? {}));

    try {
      final response =
          await http.post(uri, body: jsonEncode(body), headers: innerHeader).timeout(
                const Duration(seconds: 400),
                onTimeout: () => http.Response('connectionTimeOut', 481),
              );

      logResponse(url, response);

      _serverDate = getDateTimeFromHeaders(response);
      return response;
    } catch (error) {
      return http.Response('connectionTimeOut', 481);
    }
  }

  Future<http.Response> puttApi({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    Map<String, String>? header,
  }) async {
    if (body != null) body.removeWhere((key, value) => value == null);
    if (query != null) query.removeWhere((key, value) => value == null);

    innerHeader.addAll(header ?? {});

    if (query != null) {
      query.removeWhere((key, value) => value == null);
      query.forEach((key, value) => query[key] = value.toString());
    }

    final uri = Uri.https(baseUrl, url, query);

    logRequest(url, body);

    try {
      final response =
          await http.put(uri, body: jsonEncode(body), headers: innerHeader).timeout(
                const Duration(seconds: 400),
                onTimeout: () => http.Response('connectionTimeOut', 481),
              );

      logResponse(url, response);

      _serverDate = getDateTimeFromHeaders(response);
      return response;
    } catch (error) {
      return http.Response('connectionTimeOut', 481);
    }
  }

  Future<http.Response> deleteApi({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    Map<String, String>? header,
  }) async {
    if (body != null) body.removeWhere((key, value) => value == null);

    if (query != null) {
      query.removeWhere((key, value) => value == null);
      query.forEach((key, value) => query[key] = value.toString());
    }

    innerHeader.addAll(header ?? {});

    final uri = Uri.https(baseUrl, url, query);

    logRequest(url, body);

    try {
      final response =
          await http.delete(uri, body: jsonEncode(body), headers: innerHeader).timeout(
                const Duration(seconds: 400),
                onTimeout: () => http.Response('connectionTimeOut', 481),
              );

      logResponse(url, response);

      _serverDate = getDateTimeFromHeaders(response);
      return response;
    } catch (error) {
      return http.Response('connectionTimeOut', 481);
    }
  }


  Future<http.Response> patchApi({
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    Map<String, String>? header,
  }) async {
    if (body != null) body.removeWhere((key, value) => value == null);
    if (query != null) query.removeWhere((key, value) => value == null);

    innerHeader.addAll(header ?? {});

    if (query != null) {
      query.removeWhere((key, value) => value == null);
      query.forEach((key, value) => query[key] = value.toString());
    }

    final uri = Uri.https(baseUrl, url, query);

    logRequest(url, body);

    try {
      final response =
          await http.patch(uri, body: jsonEncode(body), headers: innerHeader).timeout(
                const Duration(seconds: 40),
                onTimeout: () => http.Response('connectionTimeOut', 481),
              );

      logResponse(url, response);

      _serverDate = getDateTimeFromHeaders(response);
      return response;
    } catch (error) {
      return http.Response('connectionTimeOut', 481);
    }
  }
}

void logRequest(String url, Map<String, dynamic>? q, {String? additional}) {
  if (url.contains('ExecuteRequest')) return;
  loggerObject.i('$url \n ${jsonEncode(q)}${additional == null ? '' : '\n$additional'}');
}

void logResponse(String url, http.Response response) {
  if (url.contains('ExecuteRequest')) return;
  var r = [];
  var res = '';
  if (response.body.length > 800) {
    r = response.body.splitByLength1(800);
    for (var e in r) {
      res += '$e\n';
    }
  } else {
    res = response.body;
  }

  loggerObject.v('${response.statusCode} \n $res');
}

// extension on String {
//   List<String> splitByLength(int length) => [substring(0, length), substring(length)];
// }

// var uri = Uri.https(baseUrlProxy, hostName ?? '$baseUrl$url', query);
// final uri = Uri.https(baseUrlProxy, '$baseUrl$url', query);
// final uri = Uri.https(baseUrlProxy, '$baseUrl$url', query);
// final uri = Uri.https(baseUrlProxy, '$baseUrl$url', query);
// final uri = Uri.https(baseUrlProxy, '$baseUrl$url', query);
// final uri = Uri.https(baseUrlProxy, '$baseUrl$url/${path ?? ''}');
