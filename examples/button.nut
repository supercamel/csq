local window = ui.Window();
window.connect("destroy", ui.main_quit);

window.set_title("Button Demo");

local button = ui.Button("click me");

local coro_count = 0;

function sleepy_coro() {
    coro_count++;
    while(true) {
        print(coro_count);
        print("\n");
        sleep_thread(1000);
    }
}


button.connect("clicked", function() {
    print("clicked\n");
    ::coro <- ::newthread(sleepy_coro);
    ::coro.call();
});
window.add(button);
window.show_all();
ui.main();
