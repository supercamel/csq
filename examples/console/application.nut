#!/usr/local/bin/csq "hello world"


class MyApp extends ConsoleApplication {
	function command_line(args) {
		print("Hello, Console Application!\n");
		return 0;
	}
}


local app = MyApp("com.csq.example", "My Console App", "My awesome console application", "1.0");
app.run();