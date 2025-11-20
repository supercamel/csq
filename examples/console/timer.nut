#!/usr/local/bin/csq

::console <- require("console");

class TimerApp extends console.Application {
	constructor(app_id, title, description, version) {
		base.constructor(app_id, title, description, version);
	}

	function activate() {
		// Keep the application alive while our async task runs.
		this.hold();

		print("TimerApp: starting 5-second countdown...\n");

		// Run the async job in a Squirrel thread/coroutine.
		async_run(function(n) {
			try {

				for (local i = n; i >= 1; i--) {
					print("TimerApp: " + i + "...\n");
					// sleep_async should yield the Squirrel thread without blocking GLib
					sleep_async(1000);
				}

				print("TimerApp: done, exiting.\n");
				// Release the hold so GLib.Application.run() can return.
				this.release();
			}
			catch(e) {
				print("Error caught in timer coroutine!\n");
				print(e);
				this.release();
			}
		}.bindenv(this), 5); 
	}
}

local app = TimerApp(
		"com.csq.timer",
		"Timer App",
		"Demonstrates async + hold/release",
		"1.0"
		);

app.run();

