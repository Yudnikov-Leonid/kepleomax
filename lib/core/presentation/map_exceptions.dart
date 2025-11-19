import 'package:dio/dio.dart';

class MapExceptions {
  MapExceptions._();

  static String dioExceptionToString(DioException error) => switch ((
    error.response?.statusCode,
    error.type,
  )) {
    (400, _) => 'Bad request',
    (401, _) => 'Unauthorized',
    (403, _) => 'Forbidden',
    (404, _) => 'Not found',
    (408, _) => 'Request timeout',
    (409, _) => 'Conflict',
    (422, _) => 'Unprocessable entity',
    (429, _) => 'Too many requests, please try again later',
    (500, _) => 'Internal server error',
    (502, _) => 'Bad gateway',
    (503, _) => 'Service unavailable',
    (504, _) => 'Gateway timeout',
    (_, DioExceptionType.connectionTimeout) => 'Connection timeout',
    (_, DioExceptionType.sendTimeout) => 'Send timeout',
    (_, DioExceptionType.receiveTimeout) => 'Receive timeout',
    (_, DioExceptionType.badCertificate) => 'Bad certificate',
    (_, DioExceptionType.badResponse) => 'Bad response',
    (_, DioExceptionType.cancel) => 'Request cancelled',
    (_, DioExceptionType.connectionError) => 'Connection error',
    //: '${error.message ?? error.error ?? 'Connection error'}',
    (_, DioExceptionType.unknown) => error.message ?? 'An unknown error occurred',
  };
}
