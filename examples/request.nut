
function getpage() {
    local result = web.request_thread("http://www.google.com");
    print(result);
    ui.main_quit();
}

local coro = ::newthread(getpage);
coro.call();

ui.main();
