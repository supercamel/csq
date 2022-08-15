# Box

ui.Box is a wrapper of Gtk.Box. It's a container widget for configuring the layout of the application. Boxes can be horizontal or vertical and widgets can added to the box using the pack_start and pack_end functions. 

```
local window = ui.Window();
window.connect("destroy", ui.main_quit);
window.set_title("Box Demo");
local box = ui.Box(ui.Orientation.HORIZONTAL, 5);

// add some labels to the box
for(local i = 0; i < 5; i++) { 
    local lbl = ui.Label(i.tostring());
    box.pack_start(lbl);
}
window.add(box);
window.show_all();
ui.main();

```

### Inherits

Widget


### Functions 

* constructor(ui.Orientation, int spacing)
* pack_start(widget, (optional) bool expand, (optional) bool fill, (optional) int spacing)
* pack_end(widget, (optional) bool expand, (optional) bool fill, (optional) int spacing)
* set_homogeneous(bool homogeneous)
* set_spacing(bool spacing)

### Signals

None


## Constructor

The constructor requires an orientation and spacing. The orientation determines if child widgets are to be packed vertically or horizontally. The spacing sets the gap between child widgets. 

The orientation can be either

* ui.Orientation.HORIZONTAL
* ui.Orientation.VERTICAL

## pack_start

Adds a widget to the box and inserts it at the start.

### Parameters

`widget` 

:   Type: == a widget instance ==
    an instance of a widget to add to the box

`expand`

:   Type: == boolean ==
    if true, the child widget is given extra space to use available space

`fill`

:   Type: == boolean ==
    if true, the child widget will fill the extra space. if false, the extra space is used as padding. has no effect if expand is false.

`spacing`

:   Type: == number ==
    extra space in pixels to put between this child and its neighbours

