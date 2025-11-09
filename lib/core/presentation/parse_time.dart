import 'package:intl/intl.dart';

class ParseTime {
  ParseTime._();

  static unixTimeToDate(int unixTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    unixTime = unixTime ~/ 1000;

    if (now - unixTime < 60) {
      return '${now - unixTime} sec ago';
    } else if (now - unixTime < 3600) {
      return '${(now - unixTime) ~/ 60} min ago';
    } else if (now - unixTime < 86400) {
      return '${(now - unixTime) ~/ 3600} hours ago';
    } else if (now - unixTime < 86400 * 7) {
      return '${(now - unixTime) ~/ 86400} days ago';
    } else {
      return DateFormat(
        'MMM dd, y',
      ).format(DateTime.fromMillisecondsSinceEpoch(unixTime * 1000));
    }
  }

  static unixTimeToPreciseDate(int unixTime) {
    final now = DateTime.fromMillisecondsSinceEpoch(unixTime);
    final date = DateFormat('MMM dd, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    return '$date at $time';
  }
}
