# Label

A simple text label widget.

### Inherits 

[Widget](widget.md)


### Functions

* [constructor](#constructor)
* [set_text(string text)](#set_text)
* [get_text()](#get_text)
* [set_use_markup(bool markup)](#set_use_markup)
* [set_xalign(float xalign)](#set_xalign)
* [set_yalign(float yalign)](#set_yalign)

### Signals

None

## constructor

Constructs a new label with some text to display.

### Definition

`ui.Label(string text)`

### Parameters

`text`
:   Type: *string*
    The text to display in the label

### Returns 

A new label widget

## set_text

Sets the text to display in the label

### Definition

`ui.Label.set_text(string text)`

### Parameters

`text`
:   Type: *string*
    The text to display in the label

### Returns

No return value

## get_text

Gets the text that is shown by the label

### Definition

`ui.Label.get_text()`

### Parameters

None

### Returns

A string containing the label text

## set_use_markup

If set to true, the label text will be displayed using Pango markup format.

[Pango Markup Reference](https://docs.gtk.org/Pango/pango_markup.html)

### Definition

`ui.Label.set_use_markup(bool markup)`

### Parameters

`markup`
:   Type: *bool*
    If true, the label text will be displayed as Pango markup

### Returns 

No return value


## set_xalign

Sets the xalign attribute of the text. The alignment is constrained to 0 - 1.0, where 0 is full left aligned and 1.0 is full right aligned. 

### Definition

`ui.Label.set_xalign(float xalign)`

### Parameters

`xalign`
:   Type: *float*
    A value between 0 and 1.0 where 0 will make the text full left aligned, 0.5 centered and 1.0 full right aligned.

### Returns

No return value

## set_yalign

Same as [set_xalign](#set_xalign) only it affects the vertical alignment of the text.

### Definition

`ui.Label.set_yalign(float yalign)`

### Parameters

`yalign`
:   Type: *float*
    A value between 0 and 1.0 where 0 brings the text to the top of the label and 1.0 moves it to the bottom.

