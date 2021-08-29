class PatternUtil {
  PatternUtil._();

  static bool isChinesePhone(String? phone) {
    return phone != null && RegExp(r"^1[3-9]\d{9}$").hasMatch(phone);
  }

  static bool isEmail(String? email) {
    return email != null &&
        RegExp("^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
                "\\@" +
                "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                "(" +
                "\\." +
                "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                r")+$")
            .hasMatch(email);
  }

  static bool isUserNameValid(String? name) {
    return name != null && name.length >= 3;
  }

  static bool isAccountValid(String? account) {
    if (account == null) {
      return false;
    }
    if (account.contains('@')) {
      return isEmail(account);
    } else {
      return isChinesePhone(account);
    }
  }

  static bool isPasswordValid(String? password) {
    return password != null && password.length >= 6;
  }
}
