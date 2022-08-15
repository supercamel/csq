local window = ui.Window();
window.show_all();
window.set_title("Hello World");
window.connect("destroy", ui.main_quit);

local btn = ui.Button("Click Me!");
btn.connect("clicked", function() {
    local msgbox = ui.MessageBox(window, ui.MessageType.ERROR);
    msgbox.set_text("Hello!");
    msgbox.set_secondary_text("secondary text");
    msgbox.add_response("OK", 1);
    msgbox.add_response("Cancel", 2);
    local response = msgbox.run();

    print(response.tostring());
    print("\n");
});

window.add(btn);

window.show_all();

ui.main();
