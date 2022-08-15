# Box

## Description

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

[Widget](widget.md)


### Functions 

* [constructor(ui.Orientation, int spacing)](#constructor)
* [pack_start(widget, (optional) bool expand, (optional) bool fill, (optional) int spacing)](#pack_start)
* [pack_end(widget, (optional) bool expand, (optional) bool fill, (optional) int spacing)](#pack_end)
* [set_homogeneous(bool homogeneous)](#set_homogenous)
* [set_spacing(bool spacing)](#set_spacing)


### Signals

None


## Constructor

The constructor requires an orientation and spacing. The orientation determines if child widgets are to be packed vertically or horizontally. The spacing sets the gap between child widgets. 

### Definition

`ui.Box(orientation, spacing)`

### Parameters

`orientation`
:   Type: *ui.Orientation*

    Must be either ui.Orientation.VERTICAL or ui.Orientation.HORIZONTAL

`spacing`
:   Type: *number*

    The amount of spacing in pixels between child widgets



## pack_start

Adds a widget to the box and inserts it at the start.

### Definition

`ui.Box.pack_start(widget, expand, fill, spacing)`

### Parameters

`widget`
:   Type: *instance*

    an instance of a widget to add to the box

`expand`
:   Type: *boolean*

    (optional, default = false) 

    true, the child widget is given extra space to use available space

`fill` 
:   Type: *boolean*

    (optional, default = false) 

    if true, the child widget will fill the extra space. if false, the extra space is used as padding. has no effect if expand is false.

`spacing`
:   Type: *number*

    (optional, default = 0) 

    extra space in pixels to put between this child and its neighbours

### Returns 

No return value

## pack_end

Adds a widget to the box and inserts it at the end.

### Definition

`ui.Box.pack_end(widget, expand, fill, spacing)`

### Parameters

`widget`
:   Type: *instance*

    an instance of a widget to add to the box

`expand`
:   Type: *boolean*

    (optional, default = false) 

    true, the child widget is given extra space to use available space

`fill` 
:   Type: *boolean*

    (optional, default = false) 

    if true, the child widget will fill the extra space. if false, the extra space is used as padding. has no effect if expand is false.

`spacing`
:   Type: *number*

    (optional, default = 0) 

    extra space in pixels to put between this child and its neighbours

### Returns 

No return value

## set_homogeneous

If set to true, every child of the box will share the same amount of space.

### Definition

`ui.Box.set_homogenous(homogenous)`

### Parameters

`homogenous`
:   Type: *bool*

    if true, each child will have the same amount of space

### Returns 

No return value

## set_spacing

Sets the amount of padding between child widgets

### Definition

`ui.Box.set_spacing(spacing)`

### Parameters

`spacing`
:   Type: *int*

    the number of pixels to use as padding between child widgets

### Returns 

No return value






