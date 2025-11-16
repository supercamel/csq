#!/usr/local/bin/csq

class MyApp extends system.ConsoleApplication {
    constructor(app_id, title, description, version) {
        base.constructor(app_id, title, description, version);
    }


	function activate() {
		print("MyApp activated!\n");
		local args = system.get_args();

		system.run_async(function() {
			print("This is an async method inside a thread!\n");
			sleep_async(500);
			print("Async method inside thread complete!\n");
			this.release();
		}.bindenv(this));
		this.hold();
	}
}

local app = MyApp("com.csq.example", "My Console App", "My awesome console application", "1.0");
app.run();