// dart format off
import 'package:kepleomax/core/flavor.dart';

abstract class AppConstants {
  static _AppConstantsType get _constants =>
      flavor.isTesting ? const _AppConstantsTesting() : const _AppConstatsRelease();

  static final int sendActivityDelayInSeconds = _constants.sendActivityDelayInSeconds;
  static final int markAsOfflineAfterInactivityInSeconds = _constants
      .markAsOfflineAfterInactivityInSeconds;
  static final int showTypingAfterActivityForSeconds = _constants
      .showTypingAfterActivityForSeconds;

  static final int msgPagingLimit = _constants.msgPagingLimit;
  static final int postsPagingLimit = _constants.postsPagingLimit;
  static final int peoplePagingLimit = _constants.peoplePagingLimit;
}

abstract class _AppConstantsType {
  const _AppConstantsType();

  int get sendActivityDelayInSeconds => 30;

  int get markAsOfflineAfterInactivityInSeconds => 60;

  int get showTypingAfterActivityForSeconds => 3;

  int get msgPagingLimit => 15;

  int get postsPagingLimit => 5;

  int get peoplePagingLimit => 12;
}

class _AppConstatsRelease extends _AppConstantsType {
  const _AppConstatsRelease() : super();
// no overrides
}

class _AppConstantsTesting extends _AppConstantsType {
  const _AppConstantsTesting() : super();
// no overrides
// you can override any constant for testing here
}
