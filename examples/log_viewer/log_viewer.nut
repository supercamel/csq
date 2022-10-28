require("csqmapness");

function apply_log_timestamps(log_entries) {
    local t = 0.0;
    foreach(k, v in log_entries) {
        try { 
            delete log_entries[k].timestamp;
        }
        catch(e) {

        }

        log_entries[k].timestamp <- t;
        if(v.title = "telemetry") {
            t += 0.1;
        }
    }
}

class LogViewer {
    constructor() {
        window.connect("destroy", ui.main_quit);
        local vbox = ui.Box(ui.Orientation.VERTICAL, 0);

        // create the menu bar
        local menu = ui.MenuBar();
        local file = ui.MenuItem("_File");
        local file_menu = ui.Menu();
        local open = ui.MenuItem("_Open");
        local quit = ui.MenuItem("_Quit");

        file_menu.append(open);
        file_menu.append(quit);

        open.on_activate(open_log.bindenv(this));
        quit.on_activate(function() {
            print("quit clicked\n");
            ui.main_quit();
        });

        file.set_submenu(file_menu);
        menu.append(file);

        vbox.pack_start(menu, false, false, 0);

        // create the graph area
        graph.set_hexpand(true);
        graph.set_vexpand(true);
        graph.set_size_request(600, 400); 
        graph.on_draw(draw_graph.bindenv(this));
        vbox.pack_start(graph, true, true, 0);

        // create the hbox with the data selector and map
        local hbox = ui.Box(ui.Orientation.HORIZONTAL, 0);
        local subhbox = ui.Box(ui.Orientation.HORIZONTAL, 0);
        
        subhbox.pack_start(ui.ScrolledWindow(field_table), true, true, 0);

        local button_vbox = ui.Box(ui.Orientation.VERTICAL, 0);
        local add_field_btn = ui.Button("Add Field");
        local remove_field_btn = ui.Button("Remove Field");
        button_vbox.pack_start(add_field_btn, false, false, 0);
        button_vbox.pack_start(remove_field_btn, false, false, 0);
        subhbox.pack_start(button_vbox, false, false, 0);

        subhbox.pack_start(ui.ScrolledWindow(shown_fields), true, true, 0);
        subhbox.set_size_request(600, 400);

        hbox.pack_start(subhbox, false, false, 0);

        field_table.connect("row-clicked", function(row_n, content) {
            field_table.remove_row(row_n);
            shown_fields.add_row(content);

            graph_data = [];
            for(local i = 0; i < shown_fields.get_n_rows(); i++) {
                local row = shown_fields.get_row(i);
                local line = { };
                line.title <- row[0];
                line.points <- [];
                line.y_max <- 0.0;
                line.y_min <- 0.0;

                foreach(k, v in log_data) {
                    foreach(kk, vv in v) {
                        if(kk == row[0]) {
                            local entry = {
                                x = v.timestamp,
                                y = vv
                            }

                            if(line.points.len() == 0) {
                                line.y_min = vv;
                                line.y_max = vv;
                            }
                            else {
                                if(vv > line.y_max) {
                                    line.y_max = vv;
                                }
                                if(vv < line.y_min) {
                                    line.y_min = vv;
                                }
                            }

                            line.points.append(entry); 
                        }
                    }
                }
                graph_data.append(line);
            }
            graph.redraw();
        }.bindenv(this));

        shown_fields.connect("row-clicked", function(row_n, content) {
            shown_fields.remove_row(row_n);
            field_table.add_row(content);
        }.bindenv(this));

        map.add_entity(track);
        map.set_size_request(600, 400);
        hbox.pack_start(map, true, true, 0);

        vbox.pack_start(hbox, false, false, 0);


        window.add(vbox);
        window.show_all();
    };



    function open_log() {
        local dialog = ui.FileChooser("Open Log File", window, ui.FileChooserAction.OPEN);
        dialog.set_filter("*.json");
        if(dialog.run()) {
            local filename = dialog.get_filename();
            log_data = json.parse_file(filename);

            track.clear();
            local avg_lat = 0.0;
            local avg_lon = 0.0;
            local n_points = 0;
            local fields = [];
            foreach(k, v in log_data) {
                if(v.title == "telemetry") {
                    local p = mapness.Entity();
                    p.position.set_degrees(v.latitude, v.longitude);
                    track.add_point(p);

                    avg_lat += v.latitude;
                    avg_lon += v.longitude;
                    n_points++;
                }

                // iterate over the fields in the packet
                // if the field is not in the fields list, add it
                foreach(kk, vv in v) {
                    if(fields.find(kk) == null) {
                        fields.append(kk);
                    }
                }
                
            }

            apply_log_timestamps(log_data);
        
            fields.sort();
            foreach(kk, vv in fields) {
                field_table.add_row([vv]);
            }

            avg_lat /= n_points;
            avg_lon /= n_points;

            local center = mapness.Point();
            center.set_degrees(avg_lat, avg_lon);
            map.set_center_and_zoom(center, 14);

            map.idle_redraw();
        }
        dialog.destroy();
    };

    function map_value(value, in_min, in_max, out_min, out_max) {
        return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    };

    function draw_graph(cr, width, height) {
        // create an array of 10 colours
        local colors = [
            [0.0, 0.0, 1.0],
            [0.0, 1.0, 0.0],
            [1.0, 0.0, 0.0],
            [0.0, 1.0, 1.0],
            [1.0, 0.0, 1.0],
            [1.0, 1.0, 0.0],
            [0.0, 0.0, 0.0],
            [0.5, 0.5, 0.5],
            [0.5, 0.0, 0.0],
            [0.0, 0.5, 0.0]
        ];

        /*
        cr.set_source_rgb(1.0, 1.0, 1.0);
        cr.rectangle(0, 0, width, height);
        cr.fill();
        */
        local i_max = graph_data.len();
        if(i_max > 10) {
            i_max = 10;
        }
        for(local i = 0; i < i_max; i++) {
            cr.set_source_rgb(colors[i][0], colors[i][1], colors[i][2]);
            cr.move_to(width-200, i * 20 + 20);
            cr.show_text(graph_data[i].title);
            cr.fill();

            print(json.stringify(graph_data[i]));
            print("\n");
        }

        for(local i = 0; i < i_max; i++) {
            cr.set_source_rgb(colors[i][0], colors[i][1], colors[i][2]);
            for(local j = 0; j < graph_data[i].points.len(); j++) {
                
                // map y_min and y_max to 20 and height-20
                local y = map_value(graph_data[i].points[j].y, graph_data[i].y_min, graph_data[i].y_max, 20, height-20);

                // map x to 20 and width - 20
                local x = map_value(graph_data[i].points[j].x, graph_data[0].points[0].x, graph_data[0].points[graph_data[0].points.len()-1].x, 20, width-20); 

                if(j == 0) {
                    cr.move_to(x.tointeger(), y.tointeger());
                }
                else {
                    cr.line_to(x.tointeger(), y.tointeger());
                }

            }
            cr.stroke();
        }
        
    };

    function run() {
        ui.main();
    };

    window = ui.Window();
    graph = ui.DrawingArea();
    map = mapness.Map();
    track = mapness.Track();
    field_table = ui.Table(["Field"]);
    shown_fields = ui.Table(["Shown Fields"]);
    log_data = [];
    graph_data = [];
}

local logviewer = LogViewer();
logviewer.run();


/*
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

*/