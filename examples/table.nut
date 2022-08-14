
local window = ui.Window();
window.set_title("Table Test");
window.connect("destroy", ui.main_quit);

local vbox = ui.Box(ui.Orientation.VERTICAL, 5);
local hbox = ui.Box(ui.Orientation.HORIZONTAL, 5);

local table = ui.Table(["Country", "Capital", "Population"]);
table.add_row(["Australia", "Canberra", "1,234,567"]);
table.add_row(["Brazil", "Brasilia", "2,345,678"]);
table.add_row(["Canada", "Ottawa", "3,456,789"]);
table.add_row(["France", "Paris", "4,567,890"]);

table.connect("row-clicked", function(row, content) {
    print(row.tostring() + "\n");
    for(local i = 0; i < content.len(); i++) {
        print(content[i].tostring() + " ");
    }
    print("\n")
});

hbox.pack_start(vbox);
hbox.pack_start(table);

local btn = ui.Button("Get Selected Row");
btn.connect("clicked", function() {
    local selected_row = table.get_selected_row();
    if(selected_row) {
        print("selected row is " + table.get_selected_row().tostring() + "\n");
    }
    else {
        print("no row selected\n");
    }
});

vbox.pack_start(btn);

local n_rows_btn = ui.Button("Get Number of Rows");
n_rows_btn.connect("clicked", function() {
    print("number of rows is " + table.get_n_rows() + "\n");
});
vbox.pack_start(n_rows_btn);

window.add(hbox);

window.set_resizable(false);
window.show_all();

ui.main();
