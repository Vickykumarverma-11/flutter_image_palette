import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AppInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTime,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['start_time'] = DateTime.now();

    _logger.i(
      '┌─────────────────────────────────────────────────────\n'
      '│ REQUEST [${options.method}]\n'
      '│ URL: ${options.uri}\n'
      '│ Headers: ${_formatHeaders(options.headers)}\n'
      '${options.data != null ? '│ Data: ${options.data}\n' : ''}'
      '└─────────────────────────────────────────────────────',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '┌─────────────────────────────────────────────────────\n'
      '│ RESPONSE [${response.statusCode}]\n'
      '│ URL: ${response.requestOptions.uri}\n'
      '│ Duration: ${_calculateDuration(response)}\n'
      '│ Data: ${_formatResponseData(response.data)}\n'
      '└─────────────────────────────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '┌─────────────────────────────────────────────────────\n'
      '│ ERROR [${err.response?.statusCode ?? 'NO STATUS'}]\n'
      '│ URL: ${err.requestOptions.uri}\n'
      '│ Type: ${err.type}\n'
      '│ Message: ${err.message}\n'
      '${err.response?.data != null ? '│ Response: ${err.response?.data}\n' : ''}'
      '└─────────────────────────────────────────────────────',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return 'None';

    final formattedHeaders =
        headers.entries.map((e) => '${e.key}: ${e.value}').join(', ');

    return formattedHeaders.length > 100
        ? '${formattedHeaders.substring(0, 100)}...'
        : formattedHeaders;
  }

  String _calculateDuration(Response response) {
    final startTime = response.requestOptions.extra['start_time'] as DateTime?;
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      return '${duration.inMilliseconds}ms';
    }
    return 'N/A';
  }

  String _formatResponseData(dynamic data) {
    if (data == null) return 'null';

    final dataStr = data.toString();

    return dataStr.length > 200 ? '${dataStr.substring(0, 200)}...' : dataStr;
  }
}
