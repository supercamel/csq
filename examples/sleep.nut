function blinky_loop() {
    ::print("hello\n");
    ::sleep(1000);
    ::print("Hello world!\n");
}

local window = ui.Window();




local button = ui.Button("click me");
button.connect("clicked", function() {
    local coro = ::newthread(blinky_loop);
    local susparam = coro.call(); //starts the coroutine
});

window.add(button);

window.show_all();
window.connect("destroy", ui.main_quit);

ui.main();
