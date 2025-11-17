import 'package:intl/intl.dart';

class ParseTime {
  ParseTime._();

  static bool _isSingular(int count) {
    return count % 10 == 1 && count != 11;
  }

  static String unixTimeToPassTime(int unixTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    unixTime = unixTime ~/ 1000;

    if (now - unixTime < 60) {
      return '${now - unixTime} sec ago';
    } else if (now - unixTime < 3600) {
      return '${(now - unixTime) ~/ 60} min ago';
    } else if (now - unixTime < 86400) {
      final count = (now - unixTime) ~/ 3600;
      return '$count ${_isSingular(count) ? 'hour' : 'hours'} ago';
    } else if (now - unixTime < 86400 * 7) {
      final count = (now - unixTime) ~/ 86400;
      return '$count ${_isSingular(count) ? 'day' : 'days'} ago';
    } else {
      return DateFormat(
        'MMM dd, y',
      ).format(DateTime.fromMillisecondsSinceEpoch(unixTime * 1000));
    }
  }

  static String unixTimeToPassTimeSlim(int unixTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    unixTime = unixTime ~/ 1000;

    if (now - unixTime < 10) {
      return 'now';
    } else if (now - unixTime < 60) {
      return '${now - unixTime} s';
    } else if (now - unixTime < 3600) {
      return '${(now - unixTime) ~/ 60} m';
    } else if (now - unixTime < 86400) {
      return '${(now - unixTime) ~/ 3600} h';
    } else if (now - unixTime < 86400 * 7) {
      return '${(now - unixTime) ~/ 86400} d';
    } else if (now - unixTime < 86400 * 30) {
      return '${(now - unixTime) ~/ (86400 * 7)} w';
    } else if (DateTime.fromMillisecondsSinceEpoch(unixTime).year ==
        DateTime.now().year) {
      return DateFormat(
        'MMM dd',
      ).format(DateTime.fromMillisecondsSinceEpoch(unixTime * 1000));
    } else {
      return DateFormat(
        'MM/dd/yy',
      ).format(DateTime.fromMillisecondsSinceEpoch(unixTime * 1000));
    }
  }

  static String unixTimeToPreciseDate(int unixTime) {
    final now = DateTime.fromMillisecondsSinceEpoch(unixTime);
    final date = DateFormat('MMM dd, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    return '$date at $time';
  }

  static String unixTimeToTime(int unixTime) {
    final date = DateTime.fromMillisecondsSinceEpoch(unixTime);

    return DateFormat.Hm().format(date);
  }
}
