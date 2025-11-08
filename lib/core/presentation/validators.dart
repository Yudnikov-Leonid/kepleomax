import 'package:email_validator/email_validator.dart';

class UiValidator {
  UiValidator._();

  static String? emailValidator(String email) {
    final emptyCheck = emptyValidator(email);
    if (emptyCheck != null) {
      return emptyCheck;
    }

    if (!EmailValidator.validate(email)) {
      return 'Incorrect email';
    }

    return null;
  }

  static String? emptyValidator(String value) {
    if (value.isEmpty) {
      return "This field can't be empty";
    }

    return null;
  }

  static String? Function(String) createLengthValidator(int length) {
    String? lengthValidator(String value) {
      if (value.length < length) {
        return 'The length must be at least $length';
      }

      return null;
    }
    return lengthValidator;
  }
}