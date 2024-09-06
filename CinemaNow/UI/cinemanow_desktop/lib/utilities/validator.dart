class Validator {
  static String? validateName(String text) {
    final nameRegExp = RegExp(r'^[A-Z][a-zA-Z]*$');
    return nameRegExp.hasMatch(text)
        ? null
        : 'Name must start with a capital letter and contain only letters.';
  }

  static String? validateSurname(String text) {
    final surnameRegExp = RegExp(r'^[A-Z][a-zA-Z]*$');
    return surnameRegExp.hasMatch(text)
        ? null
        : 'Surname must start with a capital letter and contain only letters.';
  }

  static String? validateEmail(String text) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegExp.hasMatch(text)
        ? null
        : 'Please enter a valid email address.';
  }

  static String? validateUsername(String text) {
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,}$');
    return usernameRegExp.hasMatch(text)
        ? null
        : 'Username must be at least 3 characters long and contain only letters, numbers, or underscores.';
  }

  static String? validatePassword(String text) {
    final passwordRegExp =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(text)
        ? null
        : 'Password must be at least 8 characters long and include at least one letter, one number, and one special character.';
  }

  static String? validatePasswordConfirmation(
      String password, String confirmPassword) {
    return password == confirmPassword ? null : 'Passwords do not match.';
  }
}
