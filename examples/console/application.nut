#!/usr/local/bin/csq

::console <- require("console");

class MyApp extends console.Application {
	constructor(app_id, title, description, version) {
		base.constructor(app_id, title, description, version);
	}

	function activate() {
		print("Activated!\n");	
	}
}

::app <- MyApp("com.csq.example", "My Console App", "CSQ Console app demo", "1.0");
app.run();
