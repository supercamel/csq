

function getpage() {
    local result = web.get_async("http://www.google.com");
    print(result.uri);
    ui.main_quit();
}

local coro = ::newthread(getpage);
coro.call();

ui.main();
