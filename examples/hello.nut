local window = ui.Window();
window.show_all();
window.set_title("Hello World");
window.connect("destroy", ui.main_quit);

local box = ui.Box(ui.Orientation.VERTICAL, 5);
local lbl = ui.Label("Hello world!");
lbl.set_xalign(0.0);

box.pack_start(lbl);
box.pack_start(ui.Label("testing"));
local btn = ui.Button("Click me!");
local entry = ui.Entry("Enter your name");

btn.connect("clicked", function() {
    print(entry.get_text());
    print("\n");
});

box.pack_start(entry);
box.pack_start(btn);

local table = ui.Table(["Col 1", "Col 2", "Col 3"]);
for(local i = 0; i < 10; i++)
{
    table.add_row(["1", "2", "3"]);
}

print(table.get_n_rows());
print("\n");

local row = table.get_row(4);
foreach (i in row)
{
    print(i);
    print(" ");
}
print("\n");

box.pack_start(table);

window.add(box);

window.show_all();

ui.main();
