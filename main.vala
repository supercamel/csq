public delegate void RequirePluginFunction (Squirrel.Vm vm);

class csqApp : Application
{
    private csqApp() {
        Object(flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    private int _command_line (ApplicationCommandLine command_line) {
        string[] args = command_line.get_arguments();
        
        string script_path = "";
        string[] script_args = {};
        bool show_version = false;
        
        // Only handle --version at interpreter level, pass everything else to script
        for (int i = 1; i < args.length; i++) {
            if (args[i] == "--version" || args[i] == "-v") {
                show_version = true;
            } else if (script_path == "") {
                // First argument that's not --version is the script
                script_path = args[i];
            } else {
                // Everything else goes to script args
                script_args += args[i];
            }
        }

        // Handle version option (only interpreter-level option)
        if (show_version) {
            command_line.print("csq v0.1\n");
            return 0;
        }

        // Check if script was specified
        if (script_path == "") {
            command_line.print("Usage: %s [OPTIONS] SCRIPT [SCRIPT_ARGS...]\n", args[0]);
            command_line.print("Options:\n");
            command_line.print("  -v, --version  Show version\n");
            command_line.print("\nAll arguments except --version are passed to the script.\n");
            return 0;
        }

        // Initialize VM
        vm = new Squirrel.Vm(1024*64);

        File file = File.new_for_path(script_path);
        if (file.query_exists() && file.query_file_type(FileQueryInfoFlags.NONE) == FileType.REGULAR) {
            vm.push_root_table();

            thread_registry = new ThreadRegistry();
            
            // Initialize modules
            ui.init(vm);
            web.init(vm);
            expose_sleep(vm);
            expose_json(vm);
            
            // Pass all script arguments (including --help) to the console module
            console.expose_application(vm, args);

            loaded_modules = new SList<string>();
            loaded_modules.append(script_path);

            // Set up require function
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
                    req(vm);

                    loaded_modules.append(module_path);
                    return 1;
                }

            }, 0);
            vm.new_slot(-3, false);

            // Execute the script
            vm.do_file(script_path, false, true);
        } 
        else {
            command_line.print("File '%s' not found\n", script_path);
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
