# Table

## Description

A table is a simple widget for displaying tables of information in columns and rows. 

It is a special-case wrapper of Gtk.TreeView. The user pointer of the class instance is a Gtk.TreeView.

### Inherits 

[Widget](widget.md)

### Functions

* [constructor(string[] columns)](#contructor)
* [connect(string signal_name, function callback)](#connect)
* [add_row(string[] data)](#add_row)
* [get_row(int row_n)](#get_row)
* [get_n_rows()](#get_n_rows)

### Signals

`row-clicked`
:   int row_number, string[] data
    emitted when the user selects a row. The signal passes on the row_number and row data as an array of strings. 

## constructor

The constructor takes an array of strings that will set the column names of the table.

### Definition

`ui.Table(string[] columns)`

### Parameters

`columns`
:   Type *string array*
    The length of the array sets the number of columns, and the name of the columns is set by each value.

### Returns

A shiny new table

## connect

Used to connect signals emitted by the widget to callback functions, such as button clicks, etc

### Definition

`ui.Table.connect(string signal_name, function callback)`

### Parameters

`signal_name`
:   Type: *string*
    The signal name to connect the callback to

`callback`
:   Type: *function*
    The callback function

### Returns

No return value

## add_row

Adds a row of data to the table

### Definition

`ui.Table.add_row(string[] data)`

### Parameters

`data`
:   Type: *string array*
    The data to append to the table as an array of strings

### Returns

No return value

## get_row

Gets row data from the table as an array of strings. 

### Definition

`ui.Table.get_row(int row_n)`

### Parameters

`row_n`
:   Type: *int*
    The row number to get.

### Returns

The values contained in the row as an array of strings

## get_n_rows

Gets the number of rows in the table. Useful to iterate over the table data.

### Definition

`ui.Table.get_n_rows()`

### Parameters

None

### Returns

The number of rows as an integer

