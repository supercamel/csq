
local db = web.Spino();
local server = web.Server();

local window = ui.Window();
local box = ui.Box(ui.Orientation.VERTICAL, 10);
local table = ui.Table(["Row", "Name", "Type"]);
box.pack_start(table);

window.set_default_size(600, 400);
window.add(box);
window.show_all();
window.connect("destroy", ui.main_quit);


server.add_handler("/data", function(msg, query) {
    print(json.stringify(msg));
    print("\n");

    if(msg.method == "GET") {
        local result = db.get_collection("data").find_one("{name:\"" + query.name + "\"}");
        return {
            status_code = 200,
            type = "text/json",
            content = result
        };
    }

    if(msg.method == "POST") {
        try {
            local tbl = json.parse(msg.body.data);
            db.get_collection("data").append(tbl);

            local arr = [table.get_n_rows().tostring(), tbl.name, tbl.type];
            table.add_row(arr);
             
            return {
                status_code = 200,
                type = "text/html",
                content = "<p>OK</p>"
            };
        }
        catch(err) {
            print("coudl not parse json, probably\n");
            return {
                status_code = 400,
                type = "text/html",
                content = "<p>Could not parse body</p>"
            };
        }
    }

    return {
        status_code = 404,
        type = "text/html",
        content = "<p>page not found</p>"
    };
});

server.add_handler("*", function(msg, query) {
    return {
        status_code = 404,
        type = "text/html",
        content = "<H1>Page not found</H1>"
    };
});

server.listen(8080);


ui.main();


