require("examples/hello_world.nut");
require("native_module");

local window = Window();
window.show_all();
window.set_title("Hello World");
window.connect("destroy", Gtk.main_quit);

local box = Box(Orientation.VERTICAL, 5);
local lbl = Label("Hello world!");
lbl.set_xalign(0);

box.pack_start(lbl);
box.pack_start(Label("testing"));
local btn = Button("Click me!");
local entry = Entry("Enter your name");

btn.connect("clicked", function() {
    print(entry.get_text());
    print("\n");
});

box.pack_start(entry);
box.pack_start(btn);

local table = Table(["Col 1", "Col 2", "Col 3"]);
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

Gtk.main();
