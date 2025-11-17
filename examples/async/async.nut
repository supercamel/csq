#!/usr/local/bin/csq

function main()
{
	print("starting async example\n");
	sleep_async(1000);
	print("async example complete\n");
	main_loop.quit();
}

async_run(main);
main_loop.run();