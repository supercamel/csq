local window = ui.Window();
window.connect("destroy", ui.main_quit);

window.set_title("Button Demo");

local button = ui.Button("click me");
button.connect("clicked", function() {
    print("clicked\n");
    while(true) {
        sleep(1);
    }
});
window.add(button);
window.show_all();
ui.main();