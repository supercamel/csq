local window = ui.Window();
window.connect("destroy", ui.main_quit);

window.set_title("Box Demo");
local vbox = ui.Box(ui.Orientation.VERTICAL, 5);
local box = ui.Box(ui.Orientation.HORIZONTAL, 5);
for(local i = 0; i < 5; i++) {
    local lbl = ui.Label(i.tostring());
    box.pack_start(lbl);
}
vbox.pack_start(box);

box = ui.Box(ui.Orientation.HORIZONTAL, 5);
for(local i = 0; i < 5; i++) {
    local lbl = ui.Label(i.tostring());
    box.pack_end(lbl);
}
vbox.pack_start(box);

window.add(vbox);
window.show_all();
ui.main();