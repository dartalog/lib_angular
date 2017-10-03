import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
    selector: 'confirm-button',
    styles: const [''],
    styleUrls: const ['package:lib_angular/shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[CORE_DIRECTIVES, materialDirectives],
    template: '''<div>
    <material-button *ngIf="!showConfirmation" icon (trigger)="showConfirmation=true"><glyph icon="{{icon}}"></glyph></material-button> 
    <material-button *ngIf="showConfirmation" icon (trigger)="showConfirmation=false"><glyph icon="cancel"></glyph></material-button>
    <br *ngIf="orientation=='vertical'"/> 
    <material-button *ngIf="showConfirmation" icon (trigger)="triggerInternal()"><glyph icon="{{icon}}"></glyph></material-button> 
    </div>''')
class ConfirmButtonComponent implements OnDestroy {
  @Input()
  String icon;

  bool showConfirmation = false;

  @Input()
  String orientation = "vertical";

  final StreamController<Null> _triggerStreamController =
      new StreamController<Null>.broadcast();

  @Output()
  Stream<Null> get trigger => _triggerStreamController.stream;

  void triggerInternal() {
    _triggerStreamController.add(null);
    showConfirmation = false;
  }

  @override
  void ngOnDestroy() {
    _triggerStreamController.close();
  }
}
