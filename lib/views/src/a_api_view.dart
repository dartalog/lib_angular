import 'dart:async';
import 'package:angular_router/angular_router.dart';
import 'package:meta/meta.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:lib_angular/views/a_simple_error_view.dart';
import 'package:lib_angular/angular.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import '../../src/data/a_user.dart';
import 'package:tools/tools.dart';

abstract class AApiView<T> extends ASimpleErrorView {
  DetailedApiRequestError apiError;
  final Router _router;

  bool processing = false;

  bool userAuthorized = false;

  T api;

  @protected
  final AAuthenticationService<AUser> auth;

  AApiView(this.api, this._router, this.auth);

  void handleException(dynamic e, dynamic st) {
    loggerImpl.severe("handleException", e, st);
    errorMessage = e.toString();
  }

  Future<dynamic> performApiCall(Future<Null> toAwait(),
      {NgForm form: null, Future<Null> after(): null}) async {
    try {
      errorMessage = "";
      processing = true;
      return await toAwait();
    } on DetailedApiRequestError catch (e, st) {
      loggerImpl.severe(e, st);
      await _handleApiError(e, st, form);
    } catch (e, st) {
      setErrorMessage(e, st);
    } finally {
      if (after != null) await after();
      processing = false;
    }
  }

  Future<Null> _handleApiError(DetailedApiRequestError error, dynamic st,
      [NgForm form = null]) async {
    apiError = error;
    try {
//      clearValidation();
      if (error.status == 400) {
        _handleErrorDetails(error.errors, form);
        errorMessage = error.message;
      } else if (error.status == 401) {
        await this.auth.clear();
        this.auth.promptForAuthentication();
      } else if (error.status == 413) {
        errorMessage =
            "The submitted data was too large, please submit smaller images";
      } else if (error.status == httpStatusServerNeedsSetup) {
        loggerImpl.warning("Server replied that setup is required", error, st);
        await _router.navigate([setupRouteName]);
      } else {
        errorMessage = "Server error: ${error.message} (${error.status})";
      }
    } catch (e, st) {
      loggerImpl.severe(e, st);
      this.handleException(e, st);
    }
  }

  void _handleErrorDetail(ApiRequestErrorDetail detail, [NgForm form = null]) {
    if (detail.locationType == "field" && form != null) {
      _setFieldMessage(form, detail.location, detail.message);
    } else {
      errorMessage = detail.message;
    }
  }

  void _handleErrorDetails(List<ApiRequestErrorDetail> fieldErrors,
      [NgForm form = null]) {
    for (ApiRequestErrorDetail detail in fieldErrors) {
      if (detail.message == null || detail.message.length == 0) continue;
      _handleErrorDetail(detail, form);
    }
  }

  void _setFieldMessage(NgForm form, String field, String message) {
    if (form.controls.containsKey(field)) {
      final AbstractControl control = form.controls[field];
      control.setErrors({field: message});
    } else {
      //throw new NotFoundException("Can't find field for $field");
      //form.errors[field] = message;
      //errorMessage = message;
    }
  }
}
