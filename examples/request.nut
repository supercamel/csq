#!/usr/local/bin/csq

class MyApp extends system.ConsoleApplication {
	constructor(app_id, title, description, version) {
		base.constructor(app_id, title, description, version);
	}

	function get_page() {
        local result = web.get_async("http://www.google.com");
        print(json.stringify(result));
        print(result.uri + "\n");
        this.release();
	}

	function activate() {
        this.hold();
		async_run(this.get_page.bindenv(this));
	}
}

local app = MyApp("com.csq.example", "My Console App", "My awesome console application", "1.0");
app.run();

