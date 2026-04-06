import '../utils/logger.dart';

/// Result of form validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.valid() => ValidationResult(isValid: true);
  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}

/// Service for form data validation
class FormValidationService {
  static final FormValidationService _instance =
      FormValidationService._internal();

  factory FormValidationService() {
    return _instance;
  }

  FormValidationService._internal();

  // Validation patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10,15}$';
  static const String urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&/=]*)$';
  static const String numericPattern = r'^[0-9]+$';

  // Validation rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  /// Validate email
  ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult.invalid('Email is required');
    }

    final regex = RegExp(emailPattern);
    if (!regex.hasMatch(email)) {
      return ValidationResult.invalid('Please enter a valid email address');
    }

    return ValidationResult.valid();
  }

  /// Validate password
  ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (password.length < minPasswordLength) {
      return ValidationResult.invalid(
          'Password must be at least $minPasswordLength characters');
    }

    if (password.length > maxPasswordLength) {
      return ValidationResult.invalid(
          'Password must not exceed $maxPasswordLength characters');
    }

    if (!RegExp(r'^(?=.*[a-z])').hasMatch(password)) {
      return ValidationResult.invalid(
          'Password must contain lowercase letters');
    }

    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password)) {
      return ValidationResult.invalid(
          'Password must contain uppercase letters');
    }

    if (!RegExp(r'^(?=.*[0-9])').hasMatch(password)) {
      return ValidationResult.invalid('Password must contain numbers');
    }

    return ValidationResult.valid();
  }

  /// Validate username
  ValidationResult validateUsername(String username) {
    if (username.isEmpty) {
      return ValidationResult.invalid('Username is required');
    }

    if (username.length < minUsernameLength) {
      return ValidationResult.invalid(
          'Username must be at least $minUsernameLength characters');
    }

    if (username.length > maxUsernameLength) {
      return ValidationResult.invalid(
          'Username must not exceed $maxUsernameLength characters');
    }

    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
      return ValidationResult.invalid(
          'Username can only contain letters, numbers, underscores, and hyphens');
    }

    return ValidationResult.valid();
  }

  /// Validate phone number
  ValidationResult validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return ValidationResult.invalid('Phone number is required');
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final regex = RegExp(phonePattern);

    if (!regex.hasMatch(cleanPhone)) {
      return ValidationResult.invalid('Please enter a valid phone number');
    }

    return ValidationResult.valid();
  }

  /// Validate URL
  ValidationResult validateUrl(String url) {
    if (url.isEmpty) {
      return ValidationResult.invalid('URL is required');
    }

    final regex = RegExp(urlPattern);
    if (!regex.hasMatch(url)) {
      return ValidationResult.invalid('Please enter a valid URL');
    }

    return ValidationResult.valid();
  }

  /// Validate text field (non-empty)
  ValidationResult validateTextField(String value,
      {String fieldName = 'Field'}) {
    if (value.trim().isEmpty) {
      return ValidationResult.invalid('$fieldName is required');
    }

    return ValidationResult.valid();
  }

  /// Validate text field with min length
  ValidationResult validateTextFieldWithMinLength(
    String value, {
    required int minLength,
    String fieldName = 'Field',
  }) {
    final result = validateTextField(value, fieldName: fieldName);
    if (!result.isValid) {
      return result;
    }

    if (value.length < minLength) {
      return ValidationResult.invalid(
          '$fieldName must be at least $minLength characters');
    }

    return ValidationResult.valid();
  }

  /// Validate text field with max length
  ValidationResult validateTextFieldWithMaxLength(
    String value, {
    required int maxLength,
    String fieldName = 'Field',
  }) {
    final result = validateTextField(value, fieldName: fieldName);
    if (!result.isValid) {
      return result;
    }

    if (value.length > maxLength) {
      return ValidationResult.invalid(
          '$fieldName must not exceed $maxLength characters');
    }

    return ValidationResult.valid();
  }

  /// Validate numeric field
  ValidationResult validateNumericField(String value,
      {String fieldName = 'Field'}) {
    final result = validateTextField(value, fieldName: fieldName);
    if (!result.isValid) {
      return result;
    }

    final regex = RegExp(numericPattern);
    if (!regex.hasMatch(value)) {
      return ValidationResult.invalid('$fieldName must contain only numbers');
    }

    return ValidationResult.valid();
  }

  /// Validate number range
  ValidationResult validateNumberRange(
    num value, {
    required num minValue,
    required num maxValue,
    String fieldName = 'Value',
  }) {
    if (value < minValue || value > maxValue) {
      return ValidationResult.invalid(
          '$fieldName must be between $minValue and $maxValue');
    }

    return ValidationResult.valid();
  }

  /// Validate confirm password match
  ValidationResult validatePasswordMatch(
      String password, String confirmPassword) {
    if (password != confirmPassword) {
      return ValidationResult.invalid('Passwords do not match');
    }

    return ValidationResult.valid();
  }

  /// Validate file size
  ValidationResult validateFileSize(int fileSizeBytes,
      {required int maxSizeMB, String fileName = 'File'}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (fileSizeBytes > maxSizeBytes) {
      return ValidationResult.invalid(
          '$fileName must be less than $maxSizeMB MB');
    }

    return ValidationResult.valid();
  }

  /// Validate date
  ValidationResult validateDate(DateTime? date) {
    if (date == null) {
      return ValidationResult.invalid('Date is required');
    }

    return ValidationResult.valid();
  }

  /// Validate date in past
  ValidationResult validateDateInPast(DateTime date) {
    if (date.isAfter(DateTime.now())) {
      return ValidationResult.invalid('Date must be in the past');
    }

    return ValidationResult.valid();
  }

  /// Validate date in future
  ValidationResult validateDateInFuture(DateTime date) {
    if (date.isBefore(DateTime.now())) {
      return ValidationResult.invalid('Date must be in the future');
    }

    return ValidationResult.valid();
  }

  /// Validate if value is one of allowed values
  ValidationResult validateAllowedValues(
    String value,
    List<String> allowedValues, {
    String fieldName = 'Field',
  }) {
    if (!allowedValues.contains(value)) {
      return ValidationResult.invalid('Invalid $fieldName selected');
    }

    return ValidationResult.valid();
  }

  /// Log validation result
  void logValidationResult(String fieldName, ValidationResult result) {
    if (result.isValid) {
      AppLogger.debug('Validation passed: $fieldName');
    } else {
      AppLogger.warning(
          'Validation failed: $fieldName - ${result.errorMessage}');
    }
  }
}
