namespace csq
{

	class ConsoleApplication : GLib.Application
	{
		public ConsoleApplication(Squirrel.Vm vm, string app_id, string app_title, string app_description, string app_version) 
		{ 
			Object(application_id: app_id, flags: ApplicationFlags.HANDLES_COMMAND_LINE);

			this.vm = vm;
			this.app_id = app_id;
			this.app_title = app_title;
			this.app_description = app_description;
			this.app_version = app_version;
		}

		public override int command_line (ApplicationCommandLine command_line) {
			vm.push_object(squirrel_object);
			vm.push_string("activate");
			if(vm.get(-2) != Squirrel.OK) {
				// No handle_options method in Squirrel, continue normal processing
				warning("No activate method found in Squirrel console.Application subclass");
			}

			vm.push_object(squirrel_object); // push 'this'
			if(vm.call(1, true, true) != Squirrel.OK) {
				vm.get_last_error();
				string msg;
				vm.get_string(-1, out msg);
				warning("Error: %s", msg);
			}
			return 0;
		}

		public void set_squirrel_object(Squirrel.Obj obj)
		{
			this.squirrel_object = obj;
		}

		private Squirrel.Vm vm;
		private Squirrel.Obj squirrel_object;
		private string app_id;
		private string app_title;
		private string app_description;
		private string app_version;
	} 

	private string[] args;

	void init(Squirrel.Vm vm, string[] _args)
	{
		args = _args;
	}

	void require(Squirrel.Vm vm)
	{
		vm.new_table();

		vm.push_string("get_args");
		vm.new_closure((vm) => {
			vm.new_array(0);
			for(int i = 0; i < args.length; i++) {
				vm.push_string(args[i]);
				vm.array_append(-2);
			}
			return 1;
		}, 0);
		vm.set_params_check(1, ".");
		vm.new_slot(-3, false);

		vm.push_string("read_line");
		vm.new_closure((vm) => {
			string? line = stdin.read_line();
			if(line != null) {
				vm.push_string(line);
			}
			else {
				vm.push_string("");
			}
			return 1;
		}, 0);
		vm.set_params_check(1, "");
		vm.new_slot(-3, false);

		vm.push_string("get_char");
		vm.new_closure((vm) => {
			int ch = stdout.getc();
			vm.push_int((long)ch);
			return 1;
		}, 0);
		vm.set_params_check(1, "");
		vm.new_slot(-3, false);

		vm.push_string("print");
		vm.new_closure((vm) => {
			string message;
			vm.get_string(-1, out message);
			stdout.printf("%s", message);
			return 0;
		}, 0);
		vm.new_slot(-3, false);

		vm.push_string("println");
		vm.new_closure((vm) => {
			string message;
			vm.get_string(-1, out message);
			stdout.printf("%s\n", message);
			return 0;
		}, 0);
		vm.set_params_check(2, ".s");
		vm.new_slot(-3, false);

		vm.push_string("Application");
		vm.new_class(false);

		vm.push_string("constructor");
		vm.new_closure((vm) => {
			// get the parameters from the stack
			string app_id = "";
			vm.get_string(2, out app_id);

			string app_title = "";
			vm.get_string(3, out app_title);

			string app_description = "";
			vm.get_string(4, out app_description);

			string app_version = "";
			vm.get_string(5, out app_version);

			var app = new ConsoleApplication(vm, app_id, app_title, app_description, app_version);
			vm.set_instance_up(1, app);

			// now give the console app the squirrel object reference
			Squirrel.Obj obj;
			vm.get_stack_object(1, out obj);
			app.set_squirrel_object(obj);

			app.ref();

			vm.set_release_hook(-1, (ptr, sz) => {
				var m = ptr as ConsoleApplication;
				m.unref();
				return 0; 
			});
			return 1;
		}, 0);
		vm.set_params_check(5, ".ssss");
		vm.new_slot(-3, false);

		vm.push_string("run");
		vm.new_closure((inner_vm) => {
			if(check_async_registration(inner_vm)) {
				error("ConsoleApplication.run cannot be called from an async thread.");
				return 0;
			}
			var app = vm.get_instance(1) as ConsoleApplication;
			app.run(args);
			return 0;
		}, 0);
		vm.set_params_check(1, ".");
		vm.new_slot(-3, false);

		vm.push_string("hold");
		vm.new_closure((vm) => {
			var app = vm.get_instance(1) as ConsoleApplication;
			app.hold();
			return 0;
		}, 0);
		vm.set_params_check(1, ".");
		vm.new_slot(-3, false);

		vm.push_string("release");
		vm.new_closure((vm) => {
			var app = vm.get_instance(1) as ConsoleApplication;
			app.release();
			return 0;
		}, 0);
		vm.set_params_check(1, ".");
		vm.new_slot(-3, false);


		// add the class to the table
		vm.new_slot(-3, false);
	}

}
