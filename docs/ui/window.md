# Window

## Description

ui.Window is a wrapper for Gtk.Window. It's the main container element of a UI application. 


```
local window = ui.Window();
window.connect("destroy", ui.main_quit);
window.set_title("My Window");
window.add(ui.Label("Hello world!"));
window.show_all();
ui.main();
```

### Functions

* [constructor()](#constructor)
* [connect(string signal, function callback)](#connect)
* [close()](#close)
* [set_title(string title)](#set_title)
* [fullscreen()](#fullscreen)
* [unfullscreen()](#unfullscreen)
* [set_default_size(int x, int y)](#set_default_size)
* [get_default_size()](#get_default_size)
* [set_decorated(bool decorated)](#set_decorated)
* [get_decorated()](#get_decorated)
* [set_resizeable(bool resizeable)](#set_resizeable)
* [set_icon(string path)](#set_icon)
* [set_transient_for(ui.Window parent)](#set_transient_for)
* [add(ui.Widget widget)](#add)
* [get_size()](#get_size)
* [maximize()](#maximize)
* [unmaximize()](#unmaximize)


### Signals

`destroy`
:   No parameters

    This signal is emitted when the window is closed.

## Constructor

Creates a window class instance.

### Definition

`ui.Window()`

### Parameters

None


## connect

Connects a window event to a callback function.

### Definition

`ui.Window.connect(string signal_name, function callback)`

### Parameters

`signal_name`
:   Type: *string*
    The name of the signal to connect

`callback`
:   Type: *function*
    The function to execute when the signal is emitted. 

### Returns 

None


## close

Closes the window

### Definition

`ui.Window.close()`

### Parameters 

None

### Returns 

No return value


## set_title

Sets the title text of the window

### Definition

`ui.Window.set_title(string title)`

### Parameters

`title`
:   Type: *string*
    The text to set as the window title

### Returns

No return value


## show_all

Shows the window and all of its child widgets

### Definition

`ui.Window.show_all()`

### Parameters

None

### Returns

No return value


## fullscreen

Makes the window go into fullscreen mode

### Definition

`ui.Window.fullscreen()`

### Parameters

None

### Returns

No return value

## unfullscreen

Makes the window leave fullscreen mode

### Definition

`ui.Window.unfullscreen()`

### Parameters

None

### Returns 

No return value


## set_default_size 

Sets the default size of the window. This is the size of the window after it has opened. It may be resized to be larger or smaller than this by the user. 

### Definition 

`ui.Window.set_default_size(int width, int height)`

### Parameters

`width`
:   Type: *int*
    The default width of the window

`height`
:   Type: *int*
    The default height of the window

### Returns

No return value

## get_default_size

Gets the default size of the window. If the default size isn't set, this will return -1

### Definition

`ui.Window.get_default_size()`

### Parameters

None

### Returns 

An array of 2 integers. These are the default width and height values, which may be -1 if the default size isn't set.

## set_decorated 

By default windows are decorated with a titlebar, buttons to minimize and close, etc. This function can remove that and is used to create a borderless window. 

This should be used before ui.Window.show() is called.

### Definition

`ui.Window.set_decorated(bool decorated)`

### Parameters

`decorated`
:   Type: *bool*
    If set to false, the titlebar and buttons are removed to create a borderless window

### Returns

None

## get_decorated

Returns whether the window is decorated or not. See [set_decorated](#set_decorated) 

### Definition

`ui.Window.get_decorated()`

### Parameters 

None

### Returns

True if the window is decorated, false if not

## set_resizeable

Sets whether the window can be resized or not

### Definition

`ui.Window.set_resizeable(bool resizeable)`

### Parameters

`resizeable`
:   Type: *bool*
    If the, the window can be resized by the user

### Returns

No return value


## set_icon

Loads an image from a file and sets it as the window icon.

### Definition

`ui.Window.set_icon(string path)`

### Parameters

`path`
:   Type: *string*
    The image file to use as the window icon

### Returns

No return value. May throw an exception if the file cannot be loaded.

## set_transient_for

If the window is a 'sub' window of another window, use this function to set the parent window.

### Definition

`ui.Window.set_transient_for(ui.Window parent)`

### Parameters

`parent`
:   Type: *ui.Window*
    The parent window to set this as transient for

### Returns

No return value

## add

Adds a child widget to the window

### Definition

`ui.Window.add(ui.Widget widget)`

### Parameters

`widget`
:   Type: *ui.Widget*
    A widget to add to the window

### Returns

No return value

## get_size

Gets the size of the window

### Definition

`ui.Window.get_size()`

### Parameters

None

### Returns

An array of 2 ints that represent the width and height of the window.

## maximize

Asks the window manager to maximise the window

### Definition

`ui.Window.maximize()`

### Parameters

None

### Returns

No return value

## unmaxmimize

Asks the window manager to unmaximize the window.

### Definition

`ui.Window.unmaximize()`

### Parameters

None

### Returns

No return value



