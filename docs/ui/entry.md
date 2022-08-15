# Entry

## Description

An entry is most useful for retrieving a single line of text as input from the user.

A thin wrapper around Gtk.Entry. 

### Inherits

[Widget](widget.md)

### Functions

* [constructor](#constructor)
* [set_text(string text)](#set_text)
* [get_text()](#get_text)
* [set_input_purpose(ui.InputPurpose purpose)](#set_input_purpose)

## constructor

Creates a shiny new Entry

### Definition

`ui.Entry()`

### Parameters

None

### Returns 

A shiny new Entry

## set_text

Sets some text into the entry

### Definition

`ui.Entry.set_text(string text)`

### Parameters

`text`
:   Type: *string*
    The text to put into the entry

### Returns

No return value

## get_text

Gets the text from the entry

### Definition

`ui.Entry.get_text()`

### Parameters

None

### Returns

The entry text as a string.

## set_input_purpose

Sets the style of the Entry. The options are 

* ui.InputPurpose.ALPHA - alphabet characters only
* ui.InputPurpose.DIGITS - numeric characters only
* ui.InputPurpose.EMAIL
* ui.InputPurpose.FREE_FORM
* ui.InputPurpose.NAME
* ui.InputPurpose.NUMBER
* ui.InputPurpose.PASSWORD
* ui.InputPurpose.PHONE
* ui.InputPurpose.PIN
* ui.InputPurpose.TERMINAL
* ui.InputPurpose.URL

Most of these should be self explanatory but as this is a wrapper around Gtk.Entry, check out the [Gtk Entry docs](https://docs.gtk.org/gtk3/enum.InputPurpose.html) for more details. 

### Definition

`ui.Entry.set_input_purpose(ui.InputPurpose purpose);`

### Parameters

`purpose`
:   Type: *ui.InputPurpose* 
    The input purpose

### Returns 

No return value
