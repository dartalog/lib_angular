import 'dart:async';
import 'dart:html';
import 'dart:io' as io;
import 'package:logging/logging.dart';
import 'package:option/option.dart';
import 'package:tools/tools.dart';
import 'package:lib_angular/tools.dart';
import 'settings_service.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import '../data/a_user.dart';
import 'package:meta/meta.dart';

abstract class AAuthenticationService<T extends AUser> {
  static final Logger _log = new Logger("AAuthenticationService");

  Option<T> get user => _user;

  final SettingsService _settings;
  Option<T> _user = new None<T>();

  final StreamController<bool> _authStatusController =
      new StreamController<bool>.broadcast();

  final StreamController<Null> _promptController =
      new StreamController<Null>.broadcast();

  final APrivilegeSet _privilegeSet;

  AAuthenticationService(this._settings, this._privilegeSet);

  Stream<bool> get authStatusChanged => _authStatusController.stream;

  bool get isAdmin => hasPrivilege(APrivilegeSet.admin);
  bool get isAuthenticated => _user.isNotEmpty;

  Stream<Null> get loginPrompted => _promptController.stream;

  Future<Null> authenticate(String user, String password) async {
    final String url = "${getServerRoot()}login/";
    final Map<String, String> values = {"username": user, "password": password};

    final HttpRequest request = await HttpRequest.postFormData(url, values);
    if (!request.responseHeaders.containsKey(io.HttpHeaders.AUTHORIZATION))
      throw new Exception("Response did not include Authorization header");

    final String auth = request.responseHeaders[io.HttpHeaders.AUTHORIZATION];
    if (isNullOrWhitespace(auth))
      throw new Exception("Auth request did not return a key");

    await _settings.cacheAuthKey(auth);

    await evaluateAuthentication();
  }

  Future<Null> clear() async {
    if (this._user.isNotEmpty) {
      this._user = new None<T>();
      _authStatusController.add(false);
    }
    await _settings.clearAuthCache();
  }

  @protected
  Future<T> get currentUser;

  Future<Null> evaluateAuthentication() async {
    try {
      final T apiUser = await currentUser;
      this._user = new Some<T>(apiUser);
      _authStatusController.add(true);
    } on DetailedApiRequestError catch (e, st) {
      if (e.status >= 400 && e.status < 500) {
        // Not authenticated, nothing to see here
        await clear();
      } else {
        _log.severe("evaluateAuthentication", e, st);
        rethrow;
      }
    }
  }

  bool hasPrivilege(String needed) {
    return this._user.any((T user) {
      return _privilegeSet.evaluate(needed, user.privilege);
    });
  }

  void promptForAuthentication() {
    _promptController.add(null);
  }
}
