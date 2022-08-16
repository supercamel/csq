

function my_thread()
{
    print("thread starting\n");
    sleep(1000);
    print("end thread\n");
    ui.main_quit();
}

local coro = ::newthread(my_thread);
coro.call();

ui.main();

