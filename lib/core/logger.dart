import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    noBoxingByDefault: true,
    methodCount: 10,
    errorMethodCount: 10,
  ),
);