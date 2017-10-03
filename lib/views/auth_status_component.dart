import 'dart:async';
import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:lib_angular/angular.dart';
import 'package:tools/tools.dart';

@Component(
    directives: CORE_DIRECTIVES,
    selector: 'auth-status',
    styleUrls: const ['package:lib_angular/shared.css'],
    template:
        '<div *ngIf="showMessage&&!authorized" class="no-items">Access Denied</div>')
class AuthStatusComponent implements OnInit, OnDestroy {
  static final Logger _log = new Logger("AuthStatusComponent");

  @Input()
  bool showMessage = false;

  @Input()
  String required = APrivilegeSet.authenticated;

  @Output()
  EventEmitter<bool> authorizedChanged = new EventEmitter<bool>();

  final AAuthenticationService _auth;

  StreamSubscription<bool> _subscription;

  AuthStatusComponent(this._auth) {
    _subscription = _auth.authStatusChanged.listen(onAuthStatusChange);
  }

  void onAuthStatusChange(bool status) {
    authorizedChanged.emit(authorized);
  }

  bool get authorized {
    if (!_auth.isAuthenticated) return false;
    return _auth.hasPrivilege(required);
  }

  @override
  void ngOnInit() {
    authorizedChanged.emit(authorized);
  }

  @override
  void ngOnDestroy() {
    _subscription.cancel();
  }
}
