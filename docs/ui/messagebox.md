# MessageBox

## Description

A message box to display messages, warnings and information to the user.

This is a wrapper around Gtk.MessageDialog. The instance user pointer is a Gtk.MessageDialog.

```
    local msgbox = ui.MessageBox(window, ui.MessageType.ERROR);
    msgbox.set_text("Hello!");
    msgbox.set_secondary_text("secondary text");
    msgbox.add_response("OK", 1);
    msgbox.add_response("Cancel", 2);
    local response = msgbox.run();

    print(response.tostring());
    print("\n");
```

### Functions

* [constructor(ui.Window parent, ui.MessageType type)](#constructor)
* [set_text(string text)](#set_text)
* [set_secondary_Text(string text)](#set_secondary_text)
* [add_reponse(string btntext, int responseid)](#add_response)
* [run()](#run)

## constructor

Constructs a new message box dialog.

### Definition

`ui.MessageBox(ui.Window parent, ui.MessageType type)`

### Parameters

`parent`
:   Type: *ui.Window*
    The parent window that owns the message box. 

`type`
:   Type: *ui.MessageType*
    The type of message to display. This can be 

    
    * ui.MessageType.INFO
    * ui.MessageType.WARNING
    * ui.MessageType.QUESTION
    * ui.MessageType.ERROR
    * ui.MessageType.OTHER


### Returns 

A shiny new message box.


## set_text

Sets the primary text to display in the message box.

### Definition

`ui.MessageBox.set_text(string text)`

### Parameters

`text`
:   Type: *string*
    The primary message to display in the message box.

### Returns 

No return value

## set_secondary_text

Sets the secondary text to display. 

### Definition

`ui.MessageBox.set_secondary_text(string text)`

### Parameters

`text`
:   Type: *string*
    The secondary message to display.

### Returns 

No return value

## add_response

Adds a response button to the message box along with a response code. The response code is used to determine which button the user pressed and is returned by the [run()](#run) function.

### Definition

`ui.MessageBox.add_response(string msg, int response_code)`

### Parameters

`msg`
:   Type: *string*
    The text to display on the response button

`response_code`
:   Type: *int*
    A number to associate with the response, to be returned by [run()](#run) when the user clicks on the button.

### Returns

No return value

## run

Displays the message box and returns the response code.

### Definition

`ui.MessageBox.run()`

### Parameters

None

### Returns

The response code of the button that the user clicked on.

