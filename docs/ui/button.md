# Button

## Description

A button widget, useful for clicking on. This is a wrapper around Gtk.Button. 

### Inherits

[Widget](widget.md)


### Functions

* [constructor](#constructor)
* [connect(string signal, function callback)](#connect)
* [set_label(string label)](#set_label)

## signals

`clicked`
:   No parameters
    This signal is emitted when the user clicks the button


## constructor

Constructs a shiny new button

### Definition

`ui.Button(string label)`

### Params

`label`
:   Type: *string*
    *optional*
    The label to give to the button

### Returns 

A shiny new button


## connect

Used to connect signals emitted by the button to callback functions, such as button clicks, etc

### Definition

`ui.Button.connect(string signal_name, function callback)`

### Params

`signal_name`
:   Type: *string*
    The signal name to connect the callback to

`callback`
:   Type: *function*
    The callback function

### Returns

No return value

## set_label

Sets the button text

### Definition

`ui.Button.set_label(string text)`

### Params

`text`
:   Type: *string*
    The text to put on the button

### Returns

No return value


