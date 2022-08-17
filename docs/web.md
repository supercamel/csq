# Web 

## Description

The web module contains some basic HTTP query functions.

## get

get will perform a http GET operation to retrieve a resource. 

### Definition

`web.get(string url)`

### Params

`url`
:   Type: *string*
    The URL to get

### Returns

A response table

## get_async

An async version of [get](#get). This can only be used in a thread or else an error will be thrown. Async functions will put the current thread to sleep so that the main thread is not blocked. 

### Definition

`web.get_async(string url)`

### Params

`url`
:   Type: *string*
    The URL to get

### Returns

A response table


## post

post will perform a HTTP post operation

### Definition

`web.post(string url, string payload)`

### Params

`url`
:   Type: *string*
    The URL to post the payload to
`payload`
:   Type: *string*
    The payload to send via HTTP post

### Returns

A response table

## post_async

An async version of [post](#post). This can only be used in a thread or else an error will be thrown. Async functions will put the current thread to sleep so that the main loop is not blocked. 

### Definition

`web.post_async(string url, string payload)`

### Params

`url`
:   Type: *string*
    The URL to post the payload to
`payload`
:   Type: *string*
    The payload to post
