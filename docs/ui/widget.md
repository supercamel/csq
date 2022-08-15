# Widget

## Description

A widget is not an instantiable class, it is merely a collection of functions and signals that are inherited by Widget type classes. 


### Functions

* [set_expand(bool expand)](#set_expand)
* [set_hexpand(bool hexpand)](#set_hexpand)
* [set_vexpand(bool vexpand)](#set_vexpand)


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


