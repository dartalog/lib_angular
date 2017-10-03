import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';

@Component(
    selector: 'error-output',
    styles: const ['.error_output li { font-size:smaller; }'],
    styleUrls: const ['package:lib_angular/shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[CORE_DIRECTIVES, materialDirectives],
    template: '''<span class="error_output" *ngIf="hasError">
        <glyph icon="error_outline"  tooltipTarget   #ref="tooltipTarget"></glyph>
      {{message}}
      <material-tooltip-card [for]="ref">
      <ul *ngIf="hasDetails">
        <li *ngFor="let e of error.errors">{{e.location}} - {{e.message}}</li>
      </ul>
      </material-tooltip-card>
    </span>''')
class ErrorOutputComponent {
  @Input()
  DetailedApiRequestError error;

  bool get hasError => error != null;

  String get message => error?.message ?? '';

  bool get hasDetails => (error?.errors?.length ?? 0) > 0;
}
