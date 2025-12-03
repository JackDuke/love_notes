enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  weakPassword,
  undefined,
}


class AuthExceptionHandler {
  static handleException(e) {
    final AuthResultStatus status;

    switch (e.code) {
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "invalid-disabled-field":
        status = AuthResultStatus.userDisabled;
        break;
      case "too-many-requests":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "weak-password":
        status = AuthResultStatus.weakPassword;
        break;
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "email-already-in-use":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
        break;
    }
    return status;
  }

  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch(exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "Your email address appears to be invalid";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later";
        break;
      case AuthResultStatus.weakPassword:
        errorMessage = "The password is too weak";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your password is wrong";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with email and password is not enabled";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage = "The email has been registered. Please login or reset your password";
        break;
      default:
        errorMessage = "An undefined error happened";
        break;
    }
    return errorMessage;
  }
}