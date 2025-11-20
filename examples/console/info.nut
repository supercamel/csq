#!/usr/local/bin/csq

::console <- require("console");

class InfoApp extends console.Application {
    constructor(app_id, title, description, version) {
		this.app_id = app_id;
		this.title = title;
		this.description = description;
		this.version = version;
	
        base.constructor(app_id, title, description, version);
    }

    function activate() {
        local args = console.get_args();

        print("=== InfoApp ===\n");
        print("App ID       : " + this.app_id + "\n");
        print("Title        : " + this.title + "\n");
        print("Description  : " + this.description + "\n");
        print("Version      : " + this.version + "\n");
        print("Arguments    :\n");

        // args[0] is usually the executable path, so start at 1
        for (local i = 0; i < args.len(); i++) {
            print("  [" + i + "]: " + args[i] + "\n");
        }

        print("Done.\n");
    }

	app_id = "";
	title = "";
	description = "";
	version = "";
}

// create and run the app
local app = InfoApp(
    "com.csq.infoapp",
    "Info App",
    "Prints application metadata and CLI arguments",
    "1.0"
);

app.run();

