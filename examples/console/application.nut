#!/usr/local/bin/csq

class AsyncTimer {
	function run(name, app, ms, break_count) {
		while (true) {
			sleep_async(ms);
			print("AsyncTimer " + name + ": " + this.count++ + "\n");

			if (count == break_count) {
				break;
			}
		}
	}

	count = 0;
}

class MyApp extends system.ConsoleApplication {
	constructor(app_id, title, description, version) {
		base.constructor(app_id, title, description, version);
	}

	function main() {
		print("MyApp activated!\n");
		local args = system.get_args();

		this.hold();

		local timer = AsyncTimer();
		local async_handle = async_run(timer.run.bindenv(timer), "A", this, 100, 100);

		sleep_async(500);
		async_handle.cancel();
		this.release();

		print(json.stringify(async_handle) + "\n");
	}

	function activate() {
		async_run(this.main.bindenv(this));
	}
}

local app = MyApp("com.csq.example", "My Console App", "My awesome console application", "1.0");
app.run();
