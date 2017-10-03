import 'dart:html' as html;
import 'package:angular_router/angular_router.dart';
import 'a_api_view.dart';
import 'package:lib_angular/angular.dart';
import 'package:tools/tools.dart';

abstract class APage<T> extends AApiView {
  final PageControlService pageControl;

  APage(T api, AAuthenticationService auth, Router router, this.pageControl)
      : super(api, router, auth);

  bool popupUnhandledErrors = true;
  @override
  set errorMessage(String message) {
    super.errorMessage = message;
    if (popupUnhandledErrors && isNotNullOrWhitespace(message))
      pageControl.sendMessage("Error", message);
  }

  String getViewWidthString([int offset = 0]) {
    return "${html.window.innerWidth+offset}px";
  }

  String getViewHeightString([int offset = 0]) {
    // The top toolbar is currently permanent, so this height calculation automatically subtracts its height
    return "${html.window.innerHeight+offset-64}px";
  }
}
