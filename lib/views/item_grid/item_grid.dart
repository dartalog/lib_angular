import 'dart:async';
import 'dart:html';
import 'package:angular_router/angular_router.dart';
import 'package:logging/logging.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:lib_angular/views/views.dart';
import 'item_grid_item.dart';
export 'item_grid_item.dart';

@Component(
    selector: 'item-grid',
    providers: const [materialProviders],
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      ROUTER_DIRECTIVES,
    ],
    styleUrls: const ["package:lib_angular/shared.css", "item_grid.css"],
    template: '''
<div class="itemThumbnails">
<div *ngFor="let i of items" class="item" (drop)="droppedOnItem(\$event, i.id)" (dragover)="allowDrop(\$event)">
    <a [routerLink]="i.route" id="link_{{i.id}}">
        <img src="{{i.thumbnail}}" />
    </a>
    <div class="item-menu">
        <material-checkbox [(checked)]="i.selected" (checkedChange)="itemSelectChanged(\$event, i.id)" class="item-select-check" data-id="{{i.id}}"></material-checkbox>
        <span style="float: right;">
            <a href="{{i.downloadLink}}" target="_blank" download="{{i.id}}"><glyph icon="file_download"></glyph></a>
            <a href="{{i.newWindowLink}}" target="_blank" id="original_link_{{i.id}}"><glyph icon="open_in_new"></glyph></a>
        </span>
    </div>
</div>
</div>
    ''')
class ItemGrid extends ASimpleErrorView implements OnDestroy {
  static final Logger _log = new Logger("ItemGrid");

  final StreamController<ItemGridItem> _itemClickedStreamController = new StreamController<ItemGridItem>();

  @Output()
  Stream<ItemGridItem> get itemClicked => _itemClickedStreamController.stream;

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnDestroy() {
    _keyboardSubscription.cancel();
    _itemDroppedOnStreamController.close();
    _selectedItemsChangedStreamController.close();
  }

  @Input()
  List<ItemGridItem> items = <ItemGridItem>[];

  final StreamController<ItemGridDropEventArgs> _itemDroppedOnStreamController =
      new StreamController<ItemGridDropEventArgs>();

  final StreamController<int> _selectedItemsChangedStreamController =
      new StreamController<int>();

  @Output()
  Stream<int> get selectedItemsChanged =>
      _selectedItemsChangedStreamController.stream;

  List<dynamic> get selectedItems =>
      items.where((dynamic item) => item.selected).toList();

  @Output()
  Stream<ItemGridDropEventArgs> get itemDroppedOn =>
      _itemDroppedOnStreamController.stream;

  StreamSubscription<KeyboardEvent> _keyboardSubscription;

  ItemGrid() : super() {
    _keyboardSubscription = window.onKeyUp.listen(onKeyboardEvent);
  }

  void itemSelectChanged(bool checked, String id) {
    _selectedItemsChangedStreamController.add(selectedItems.length);
  }

  Future<Null> droppedOnItem(MouseEvent event, String id) async {
    event.preventDefault();
    final ItemGridDropEventArgs e = new ItemGridDropEventArgs();
    e.id = id;
    e.mouseEvent = event;
    _itemDroppedOnStreamController.add(e);
  }

  void allowDrop(Event ev) {
    ev.preventDefault();
  }

  void onKeyboardEvent(KeyboardEvent e) {
    if (e.keyCode == KeyCode.A && e.ctrlKey) {
      for (dynamic item in items) {
        item.selected = true;
      }
    }
  }
}

class ItemGridDropEventArgs {
  String id;
  MouseEvent mouseEvent;
}
