require("csqmapness");

local window = ui.Window();
window.set_title("Log Viewer");
window.connect("destroy", ui.main_quit);

local vbox = ui.Box(ui.Orientation.VERTICAL, 0);
local menu = ui.MenuBar();
local file = ui.MenuItem("File");
local file_menu = ui.Menu();
local open = ui.MenuItem("Open");
local quit = ui.MenuItem("Quit");
file_menu.append(open);
file_menu.append(quit);
file.set_submenu(file_menu);

local map = mapness.Map();
local track = mapness.Track();

open.on_activate(function() {
    local file_chooser = ui.FileChooser("Open Log File", window, ui.FileChooserAction.OPEN);
    file_chooser.set_filter("*.json");
    if(file_chooser.run()) {
        local filename = file_chooser.get_filename();
        local log_data = json.parse_file(filename);
        track.clear();
        local avg_lat = 0.0;
        local avg_lon = 0.0;
        local n_points = 0;
        foreach(k, v in log_data) {
            if(v.title == "telemetry") {
                local p = mapness.Entity();
                p.position.set_degrees(v.latitude, v.longitude);
                track.add_point(p);

                avg_lat += v.latitude;
                avg_lon += v.longitude;
                n_points++;
            }
        }

        avg_lat /= n_points;
        avg_lon /= n_points;

        local center = mapness.Point();
        center.set_degrees(avg_lat, avg_lon);
        map.set_center_and_zoom(center, 14);

        map.idle_redraw();
    }
}.bindenv(this));

quit.on_activate(function() {
    ui.main_quit();
});

menu.append(file);
vbox.pack_start(menu, false, false, 0);

local graph = ui.DrawingArea();
graph.set_size_request(800, 600);
vbox.pack_start(graph, true, true, 0);

graph.on_draw(function(cr, width, height) {
    cr.set_source_rgb(255, 255, 255);
    cr.rectangle(0, 0, width, height);
    cr.fill();

    cr.set_source_rgb(0, 0, 0);
    cr.move_to(0, 0);
    cr.line_to(100, 100);
    cr.stroke();
    return true;
});

add_timeout(1000, function() {
    graph.redraw();
    return true;
});

graph.set_hexpand(true);
graph.set_vexpand(true);
local hbox = ui.Box(ui.Orientation.HORIZONTAL, 0);

map.set_size_request(400, 400);

local pt = mapness.Entity();
pt.position.set_degrees(12.0, 12.0);
track.add_point(pt);

pt = mapness.Entity();
pt.position.set_degrees(-35.0, 147.0);
track.add_point(pt);

map.add_entity(track);

local pt2 = track.get_point(0);
print(json.stringify(pt2));

print(pt2.position.get_lat());

hbox.pack_start(map, true, true, 0);

vbox.pack_start(hbox, false, false, 0);

window.add(vbox);
window.show_all();

ui.main();
