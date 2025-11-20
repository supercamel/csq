#!/usr/local/bin/csq

::console <- require("console");

class EchoApp extends console.Application {
    constructor(app_id, title, description, version) {
        base.constructor(app_id, title, description, version);
    }

    function activate() {
        print("EchoApp started. Type 'quit' to exit.\n");

        while (true) {
            print("> ");
            local line = console.read_line();

            // stdout.read_line() likely returns null on EOF
            if (line == null) {
                print("\nEOF detected, exiting.\n");
                break;
            }

            if (line == "quit") {
                print("Goodbye.\n");
                break;
            }

            // just echo it back
            print("You said: " + line + "\n");
        }
    }
}

local app = EchoApp(
    "com.csq.echo",
    "Echo App",
    "Simple interactive console example",
    "1.0"
);

app.run();

