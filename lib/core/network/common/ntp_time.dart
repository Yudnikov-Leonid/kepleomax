import 'package:ntp/ntp.dart';

class NTPTime {
  NTPTime._();

  static int? offset;

  static Future<DateTime> now() async {
    offset ??= await NTP.getNtpOffset();
    return DateTime.now().add(Duration(milliseconds: offset!));
  }
}
