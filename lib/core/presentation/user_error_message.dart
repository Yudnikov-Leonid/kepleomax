import 'package:dio/dio.dart';
import 'package:kepleomax/main.dart';

extension UserErrorMessage on Object {
  String get userErrorMessage {
    if (this is DioException) {
      return (this as DioException).userErrorMessage;
    } else if (flavor.isDevelop) {
      return toString();
    } else {
      return 'Something went wrong';
    }
  }
}

extension DioErrorExtension on DioException {
  String get userErrorMessage {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Время подключения истекло';
      case DioExceptionType.sendTimeout:
        return 'Время отправки запроса истекло';
      case DioExceptionType.receiveTimeout:
        return 'Время получения ответа истекло';
      case DioExceptionType.badCertificate:
        return 'Неверный сертификат';
      case DioExceptionType.badResponse:
        return 'Некорректный ответ от сервера';
      case DioExceptionType.cancel:
        return 'Запрос был отменен';
      case DioExceptionType.connectionError:
        return 'Ошибка подключения';
      case DioExceptionType.unknown:
        return 'Неизвестная ошибка. Проверьте интернет соединение';
    }
  }
}