import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:lib_angular/views/a_simple_error_view.dart';
import 'package:tools/tools.dart';
import 'package:lib_angular/angular.dart';

@Component(
    selector: 'login-form',
    styleUrls: const ["package:lib_angular/shared.css"],
    directives: const [CORE_DIRECTIVES, formDirectives, materialDirectives],
    providers: const [materialProviders],
    template: '''<modal [visible]="visible">
      <material-dialog class="basic-dialog">
          <h3 header>Login</h3>
            <form (ngSubmit)="onSubmit()" #loginForm="ngForm">
            <p>
              <material-input [(ngModel)]="userName" ngControl="userName" floatingLabel required  autoFocus label="User"></material-input><br/>
              <material-input [(ngModel)]="password" ngControl="password" floatingLabel required  label="Password" type="password"></material-input><br/>
              <input type="submit" style="position: absolute; left: -9999px; width: 1px; height: 1px;"/>
              <error-output [error]="errorMessage"></error-output>
          </p>
            </form>
          <div footer style="text-align: right">
            <material-yes-no-buttons yesHighlighted
            yesText="Login" (yes)="onSubmit()"
            noText="Cancel" (no)="visible = false"
            [pending]="processing" [yesDisabled]="!loginForm.valid">
            </material-yes-no-buttons>
          </div>
      </material-dialog>
    </modal>''')
class LoginFormComponent extends ASimpleErrorView {
  static final Logger _log = new Logger("LoginFormComponent");

  String userName = "";

  String password = "";
  bool _visible = false;

  @Output()
  EventEmitter<bool> visibleChange = new EventEmitter<bool>();

  final Router _router;
  final AAuthenticationService _auth;

  bool processing = false;

  LoginFormComponent(this._auth, this._router);

  bool get hasErrorMessage => isNotNullOrWhitespace(errorMessage);

  @override
  Logger get loggerImpl => _log;

  bool get visible => _visible;

  @Input()
  set visible(bool value) {
    reset();
    if (value) {
      processing = false;
    }
    _visible = value;
    visibleChange.emit(_visible);
  }

  Future<Null> onSubmit() async {
    errorMessage = "";
    processing = true;
    try {
      await _auth.authenticate(userName, password);
      visible = false;
    } on Exception catch (e, st) {
      setErrorMessage(e, st);
    } catch (e, st) {
      _log.severe(e, st);
      final HttpRequest request = e.target;
      if (request != null) {
        String message;
        switch (request.status) {
          case 401:
            message = "Login incorrect";
            break;
          case httpStatusServerNeedsSetup:
            await _router.navigate([setupRouteName]);
            break;
          default:
            message = "${request.status} - ${request.statusText} - ${request
                .responseText}";
            break;
        }
        errorMessage = message;
      } else {
        errorMessage = "Unknown error while authenticating";
      }
    } finally {
      processing = false;
    }
  }

  void reset() {
    userName = "";
    password = "";
    errorMessage = "";
  }
}
