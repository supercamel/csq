# Async Functions

Squirrel does not support asynchronous functions of the type that Javascript and Python coders would be familiar with. Instead, it supports cooperative threads. 

When an async function is called, CSQ will suspend the current thread while the async functions runs in the background. CSQ will resume thread execution once the result is ready. This gives the appearance of blocking behaviour, however the main loop is never blocked by an async function call. Other events can be triggered by the main loop while an async call has been blocked. 

As the main thread cannot be suspended, async functions can *only* be called inside a thread. Calling an async function in the main thread will cause an error. 

The main loop must also be running for an async function to work properly. 


```
function my_thread() {
    print("thread starting\n");

    // sleep_async halts this thread for 1000ms 
    // but it does not block the main loop
    sleep_async(1000); 
    
    print("end thread\n");
}

local coro = ::newthread(my_thread);
coro.call();

add_timeout(500, function() {
    print("first timeout\n");
    return true;
});

add_timeout(1500, function() {
    ui.main_quit();
    return true;
});

ui.main();

```

