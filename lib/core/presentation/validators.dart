import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';

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

  static String? Function(String) createConfirmPasswordValidator(
    TextEditingController passwordController,
  ) {
    String? validator(String value) {
      return confirmPasswordValidator(
        password: passwordController.text,
        confirmPassword: value,
      );
    }

    return validator;
  }

  static String? confirmPasswordValidator({
    required String password,
    required String confirmPassword,
  }) {
    final emptyCheck = emptyValidator(confirmPassword);
    if (emptyCheck != null) {
      return emptyCheck;
    }

    if (password != confirmPassword) {
      return "Passwords don't match";
    }

    final passwordCheck = passwordValidator(confirmPassword);
    if (passwordCheck != null) {
      return passwordCheck;
    }

    return null;
  }

  static String? emptyValidator(String value) {
    if (value.isEmpty) {
      return "This field can't be empty";
    }

    return null;
  }

  static String? passwordValidator(String value) {
    return createLengthValidator(6).call(value);
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
