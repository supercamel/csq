
void csq_wrap_module(Squirrel.Vm vm)
{
    vm.push_string("require");
    vm.new_closure((vm) => {
        string path;
        vm.get_string(2, out path);

        File file = File.new_for_path(path);
	    if (file.query_exists() && file.query_file_type(FileQueryInfoFlags.NONE) == FileType.REGULAR) {
            if(vm.do_file(path, false, true) == false) {
                return vm.throw_error("Could not load nut " + path);
            }
            return 0;
	    } else {
            string pwdpath = Module.build_path (Environment.get_variable ("PWD"), path);
            var module = Module.open(pwdpath, ModuleFlags.LAZY);
            if(module == null) {
                string csqpath = Environment.get_variable("CSQ_PATH");
                if(csqpath != null) {
                    pwdpath = Module.build_path (csqpath, path);
                    module = Module.open(pwdpath, ModuleFlags.LAZY);
                }

                if(module == null) {
                    string pathpath = Module.build_path(Environment.get_variable("PATH"), path);
                    module = Module.open(pathpath, ModuleFlags.LAZY);
                    if(module == null) {
                        return vm.throw_error("Could not load module '" + path + "'");
                    }
                }
            }

            void* function;
            module.symbol ("csq_require", out function);

            RequirePluginFunction req = (RequirePluginFunction)function;
            stdout.printf("calling require function");
            req(vm);

            return 1;
	    }

    }, 0);
    vm.new_slot(-3, false);
}

