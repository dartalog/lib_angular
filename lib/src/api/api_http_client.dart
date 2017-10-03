import 'dart:async';

import 'package:tools/tools.dart';
import 'package:lib_angular/angular.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

class ApiHttpClient extends BrowserClient {
  final SettingsService _settings;

  ApiHttpClient(this._settings);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final String authKey =
        (await _settings.getCachedAuthKey()).getOrDefault("");
    if (!isNullOrWhitespace(authKey))
      request.headers.putIfAbsent(HttpHeader.AUTHORIZATION, () => authKey);

    request.headers.remove(HttpHeader.USER_AGENT);
    request.headers.remove(HttpHeader.CONTENT_LENGTH);

    final StreamedResponse response = await super.send(request);

    // Check for changed auth header
    final String auth = response.headers[HttpHeader.AUTHORIZATION];
    if (!isNullOrWhitespace(auth)) {
      if (auth != authKey) {
        await _settings.cacheAuthKey(auth);
      }
    }

    return response;
  }
}
