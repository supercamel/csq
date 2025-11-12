
function my_thread()
{
    print("thread starting\n");
    sleep_async(1000);
    print("end thread\n");
//    ui.main_quit();
}

local coro = ::newthread(my_thread);
coro.call();

add_timeout(1500, function() {
    print("timed out\n");
    ui.main_quit();
    return true;
});

ui.main();

