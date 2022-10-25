
public delegate void RequirePluginFunction (Squirrel.Vm vm);

class csqApp : Application
{
    private csqApp() {
		Object(flags: ApplicationFlags.HANDLES_COMMAND_LINE);
	}

    private int _command_line (ApplicationCommandLine command_line) {
		bool version = false;

		OptionEntry[] options = new OptionEntry[1];
		options[0] = { "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null };

		string[] args = command_line.get_arguments();
		string*[] _args = new string[args.length];
		for (int i = 0; i < args.length; i++) {
			_args[i] = args[i];
		}

		try {
			var opt_context = new OptionContext (" [script.nut] - csq runtime");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			unowned string[] tmp = _args;
			opt_context.parse (ref tmp);
		} catch (OptionError e) {
			command_line.print ("error: %s\n", e.message);
			command_line.print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 0;
		}

		if (version) {
			command_line.print ("csq v0.1\n");
			return 0;
		}

        vm = new Squirrel.Vm(1024*64);

        string path = args[args.length-1];
        if(args.length < 2) {
            stdout.printf("No script specified\n");
            stdout.printf("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 0;
        }

        File file = File.new_for_path(path);
	    if (file.query_exists() && file.query_file_type(FileQueryInfoFlags.NONE) == FileType.REGULAR) {
            vm.push_root_table();
            
            ui.init(vm);
            web.init(vm);
            expose_sleep(vm);
            expose_json(vm);

            loaded_modules = new SList<string>();
            loaded_modules.append(path);

            vm.push_string("require");
            vm.new_closure((vm) => {
                string module_path;
                vm.get_string(2, out module_path);

                int length = (int)loaded_modules.length();
                for(var i = 0; i < length; i++) 
                {
                    if(loaded_modules.nth_data(i) == module_path) {
                        return 0;
                    }
                }

                File module_file = File.new_for_path(module_path);
	            if (module_file.query_exists() && module_file.query_file_type(FileQueryInfoFlags.NONE) == FileType.REGULAR) {
                    if(vm.do_file(module_path, false, true) == false) {
                        return vm.throw_error("Could not load nut " + module_path);
                    }
                    loaded_modules.append(module_path);
                    return 0;
	            } else {
                    string pwdpath = Module.build_path (Environment.get_variable ("PWD"), module_path);
                    var module = Module.open(pwdpath, ModuleFlags.LAZY);
                    module.make_resident();
                    if(module == null) {
                        string csqpath = Environment.get_variable("CSQ_PATH");
                        if(csqpath != null) {
                            pwdpath = Module.build_path (csqpath, module_path);
                            module = Module.open(pwdpath, ModuleFlags.LAZY);
                        }

                        if(module == null) {
                            string pathpath = Module.build_path(Environment.get_variable("PATH"), module_path);
                            module = Module.open(pathpath, ModuleFlags.LAZY);
                            if(module == null) {
                                return vm.throw_error("Could not load module '" + module_path + "'");
                            }
                        }
                    }

                    void* function;
                    module.symbol ("csq_require", out function);

                    RequirePluginFunction req = (RequirePluginFunction)function;
                    stdout.printf("calling require function");
                    req(vm);

                    loaded_modules.append(module_path);
                    return 1;
    	        }

            }, 0);
            vm.new_slot(-3, false);


            vm.do_file(path, false, true);
	    } 
        else {
            stdout.printf("File '%s' not found\n", path);
        }


		return 0;
	}

	public override int command_line (ApplicationCommandLine command_line) {
		// keep the application running until we are done with this commandline
		this.hold ();
		int res = _command_line (command_line);
		this.release ();
		return res;
	}

    public static int main(string[] args)
    {
        Gtk.init(ref args);
        var app = new csqApp();
		int status = app.run (args);
		return status;
    }

    private Squirrel.Vm vm;
    public static SList<string> loaded_modules;
}


/* 
public static int main(string[] argv) {
    Gtk.init(ref argv);

        stdout.printf("%s\n", argv[1]);

    if(argv.length > 1) {
    }
    else {
        stdout.printf("usage: csq [file]\n");
    }

    return 0;
}

*/

