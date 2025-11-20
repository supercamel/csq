#!/usr/local/bin/csq

::console <- require("console");

class GreeterApp extends console.Application {
    constructor(app_id, title, description, version) {
        base.constructor(app_id, title, description, version);
    }

    function activate() {
        local args = console.get_args();

        // Very simple manual arg parsing
        local name = null;
        for (local i = 1; i < args.len(); i++) {
            if (args[i] == "--name" && i + 1 < args.len()) {
                name = args[i + 1];
                break;
            }
        }

        if (name != null) {
            print("Hello, " + name + "!\n");
            return;
        }

        print("No name provided. Use --name <yourname> or type it now.\n");
        print("Name: ");
        local line = console.read_line();
        if (line == null || line == "") {
            print("No name entered, exiting.\n");
            return;
        }

        print("Hello, " + line + "!\n");
    }
}

local app = GreeterApp(
    "com.csq.greeter",
    "Greeter App",
    "Greets via CLI arg or interactive prompt",
    "1.0"
);

app.run();

