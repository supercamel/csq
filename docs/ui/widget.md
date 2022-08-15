# Widget

## Description

A widget is not an instantiable class, it is merely a collection of functions and signals that are inherited by Widget type classes. 


### Functions

* [set_expand(bool expand)](#set_expand)
* [set_hexpand(bool hexpand)](#set_hexpand)
* [set_vexpand(bool vexpand)](#set_vexpand)
* [set_opacity(float opacity)](#set_opacity)
* [set_size_request(int width, int height)](#set_size_request)


## set_expand

Sets whether to expand in both directions. This overwrites both vexpand and hexpand.

### Definition

`ui.Widget.set_expand(expand)`

### Parameters

`expand`
:   Type: *bool*
    If true, the widget will expand in both directions

### Returns

No return value


## set_hexpand

Sets whether a widget should expand horizontally

### Definition

`ui.Widget.set_hexpand(hexpand)`

### Parameters

`hexpand`
:   Type: *bool*
    If true, the widget will expand horizontally

### Returns

No return value

## set_vexpand

Sets whether a widget should expand vertically

### Definition

`ui.Widget.set_vexpand(vexpand)`

### Parameters

`vexpand`
:   Type: *bool*
    If true, the widget will expand vertically

### Returns

No return value


## set_opacity

Sets the opacity (transparency) of the widget with 0 being fully transparent and 1 being fully opaque.

### Definition

`ui.Widget.set_opacity(float opacity)`

### Parameters

`opacity`
:   Type: *float*
    The opacity of the widget. This is clamped to the range 0-1.0 where 0 is transparent and 1.0 is opaque.

### Returns

No return value

## set_size_request

Sets the minimum size of a widget.

### Definition

`ui.Widget.set_size_request(int width, int height)`

### Parameters

`width`
:   Type: *int*
    The minimum width requested

`height`
:   Type: *int*
    The minimum height requested

### Returns

No return value

