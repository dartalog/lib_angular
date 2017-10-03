import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'dart:async';
import 'package:angular/core.dart';
import 'package:angular_components/angular_components.dart';
import 'package:lib_angular/angular.dart';

@Component(
    selector: 'button-toolbar',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      ROUTER_DIRECTIVES,
    ],
    providers: const [
      materialProviders,
    ],
    template: '''
    <nav class="material-navigation">
        <material-input *ngIf="showSearch" [(ngModel)]="query" style="color:white;" label="Search" leadingGlyph="search" (keyup)="searchKeyup(\$event)" ></material-input>
    </nav>
    <material-button *ngFor="let a of availableActions" icon (trigger)="pageActionTriggered(a)"><glyph icon="{{a.icon}}"></glyph></material-button>
    <modal [visible]="confirmDeleteVisible">
    <material-dialog class="basic-dialog">
        <h3 header>Delete</h3>
        <p>
            Are you sure you wish to delete?
        </p>
        <div footer style="text-align: right">
            <material-yes-no-buttons yesHighlighted
                                     yesText="Delete" (yes)="confirmDelete()"
                                     noText="Cancel" (no)="confirmDeleteVisible = false">
            </material-yes-no-buttons>
        </div>
    </material-dialog>
    </modal>
    ''')
class ButtonToolbarComponent implements OnInit, OnDestroy {
  bool get showSearch => availableActions.contains(PageAction.search);

  final List<PageAction> availableActions = <PageAction>[];

  final PageControlService _pageControl;

  void onPageActionsSet(List<PageAction> actions) {
    this.availableActions.clear();
    this.availableActions.addAll(actions);
  }

  StreamSubscription<List> _pageActionsSubscription;

  ButtonToolbarComponent(this._pageControl);

  @override
  void ngOnDestroy() {
    _pageActionsSubscription.cancel();
  }

  @override
  Future<Null> ngOnInit() async {
    _pageActionsSubscription =
        _pageControl.availablePageActionsSet.listen(onPageActionsSet);
  }

  void confirmDelete() {
    confirmDeleteVisible = false;
    _pageControl.requestPageAction(PageAction.delete);
  }

  bool confirmDeleteVisible = false;

  void pageActionTriggered(PageAction action) {
    switch (action) {
      case PageAction.delete:
        confirmDeleteVisible = true;
        break;
      default:
        _pageControl.requestPageAction(action);
        break;
    }
  }
}
