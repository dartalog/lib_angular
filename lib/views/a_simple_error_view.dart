import 'package:logging/logging.dart';
import 'package:tools/tools.dart';

abstract class ASimpleErrorView {
  Logger get loggerImpl;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  bool get hasErrorMessage => isNotNullOrWhitespace(errorMessage);

  set errorMessage(String message) {
    _errorMessage = message;
    if (isNotNullOrWhitespace(message))
      loggerImpl.severe("Error message set: " + message);
  }

  void setErrorMessage(Object e, StackTrace st) {
    loggerImpl.severe(e, st);
    _errorMessage = e.toString();
  }
}
