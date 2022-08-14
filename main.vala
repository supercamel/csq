
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

        vm = new Squirrel.Vm(1024);

        vm.on_print.connect((vm, str) => {
            print(str);
        });

        vm.push_root_table();
        csq_wrap_gtk_window(vm);
        csq_wrap_gtk_box(vm);
        csq_wrap_gtk_label(vm);
        csq_wrap_gtk_button(vm);
        csq_wrap_gtk_entry(vm);
        csq_wrap_gtk_treeview(vm);
        csq_wrap_gtk_main(vm);
        csq_wrap_module(vm);

        if(args.length < 2) {
            stdout.printf("No script specified\n");
            stdout.printf("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 0;
        }

        string path = args[args.length-1];
        File file = File.new_for_path(path);
	    if (file.query_exists() && file.query_file_type(FileQueryInfoFlags.NONE) == FileType.REGULAR) {
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

