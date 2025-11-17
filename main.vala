// csq.vala — interpreter with robust `require()`
//
// Build deps: gio-2.0, glib-2.0, gmodule-2.0, gtk+-3.0 (or gtk4 if you prefer)
// Assumes you have Squirrel.Vm bindings and expose_* functions in your project.

using GLib;
using Gee;

public delegate void RequirePluginFunction (Squirrel.Vm vm);

class csqApp : GLib.Application {
    private Squirrel.Vm vm;

    // Module cache (spec → exports object pinned in VM)
    private HashMap<string,Squirrel.Obj> require_cache = new HashMap<string,Squirrel.Obj>();
    // In-flight specs (for cycle detection)
    private HashSet<string> require_loading = new HashSet<string>();

    public static int main (string[] args) {
        Gtk.init (ref args);
        var app = new csqApp ();
        return app.run (args);
    }

    private csqApp () {
        Object (flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    public override int command_line (ApplicationCommandLine command_line) {
        // keep the application running until we are done with this commandline
        this.hold ();
        int res = handle_command_line (command_line);
        this.release ();
        return res;
    }

    private int handle_command_line (ApplicationCommandLine command_line) {
        string[] args = command_line.get_arguments ();

        string script_path = "";
        string[] script_args = {};
        bool show_version = false;

        // Only interpreter-level flag is --version
        for (int i = 1; i < args.length; i++) {
            if (args[i] == "--version" || args[i] == "-v") {
                show_version = true;
            } else if (script_path == "") {
                script_path = args[i];
            } else {
                script_args += args[i];
            }
        }

        if (show_version) {
            command_line.print ("csq v0.1\n");
            return 0;
        }

        if (script_path == "") {
            command_line.print ("Usage: %s [OPTIONS] SCRIPT [SCRIPT_ARGS...]\n", args[0]);
            command_line.print ("Options:\n");
            command_line.print ("  -v, --version  Show version\n\n");
            command_line.print ("All other arguments are passed to the script.\n");
            return 0;
        }

        // Init VM
        vm = new Squirrel.Vm (1024 * 64);

        File file = File.new_for_path (script_path);
        if (!file.query_exists () || file.query_file_type (FileQueryInfoFlags.NONE) != FileType.REGULAR) {
            command_line.print ("File '%s' not found\n", script_path);
            return 1;
        }

        // Push root table
        vm.push_root_table ();

        // Thread registry expected by async layer
        thread_registry = new ThreadRegistry ();

        // Expose core stdlib bits
        expose_async (vm);
        expose_sleep (vm);
        expose_json (vm);
        expose_main_loop (vm);
        // web.init(vm);   // move HTTP out to a module later

        // Inject robust require()
        inject_require (vm);

        // Optionally pass script args via a console module later
        // console.expose_application(vm, args);

        // Execute the script (no push_ret here; script is the entrypoint, not a require'd module)
        if (!vm.do_file (script_path, false, true)) {
            string errmsg = "Error executing script";
            vm.get_last_error ();
            vm.get_string (-1, out errmsg);
            command_line.print ("%s\n", errmsg);
            return 1;
        }

        return 0;
    }

    // ---------------------- require() implementation ----------------------

    private void inject_require (Squirrel.Vm vm) {
        vm.push_string ("require");
        vm.new_closure ((vm) => {
            // Signature: require(spec: string) -> exports(any)
            string spec;
            vm.get_string (2, out spec);
            if (spec == null || spec == "")
                return vm.throw_error ("require: empty spec");

            // Cache hit?
            if (require_cache.has_key (spec)) {
                var cached = require_cache[spec];
                vm.push_object (cached);
                return 1;
            }

            // Prevent cycles
            if (require_loading.contains (spec)) {
                return vm.throw_error ("require: cyclic dependency for '" + spec + "'");
            }
            require_loading.add (spec);

            // Try resolve as script first
            string abspath;
            bool is_script = resolve_script_path (spec, out abspath);

            bool ok = false;
            Squirrel.Obj exports_obj;

            if (is_script) {
                // Execute the module as a file that returns exports
                if (!vm.do_file (abspath, /*raiseerror*/ false, /*push_ret*/ true)) {
                    require_loading.remove (spec);
                    return vm.throw_error ("Could not load nut '" + abspath + "'");
                }
                vm.get_stack_object (-1, out exports_obj);
                vm.add_ref (exports_obj);  // pin for cache
                require_cache[spec] = exports_obj;
                ok = true;
            } else {
                // Load as native module
                Module? mod = open_native_module (spec);
                if (mod == null) {
                    require_loading.remove (spec);
                    return vm.throw_error ("Could not load native module '" + spec + "'");
                }
                mod.make_resident ();

                void* sym = null;
                if (!mod.symbol ("csq_require", out sym) || sym == null) {
                    require_loading.remove (spec);
                    return vm.throw_error ("Native module '" + spec + "' missing csq_require()");
                }

                RequirePluginFunction req = (RequirePluginFunction) sym;

                long top_before = vm.get_top ();
                req (vm);                       // must push exactly one exports value
                long top_after = vm.get_top ();
                if (top_after != top_before + 1) {
                    require_loading.remove (spec);
                    return vm.throw_error ("csq_require() must push a single exports value");
                }

                vm.get_stack_object (-1, out exports_obj);
                vm.add_ref (exports_obj);
                require_cache[spec] = exports_obj;
                ok = true;
            }

            require_loading.remove (spec);

            if (ok) {
                // leave the exports on the stack for the caller
                return 1;
            }
            return vm.throw_error ("Unknown require error for '" + spec + "'");
        }, 0);
        vm.set_params_check (2, ".s");
        vm.new_slot (-3, false);
    }

    // Resolve module spec to an absolute .nut path if it’s a script.
    // Order: exact .nut path → PWD/spec.nut → each CSQ_PATH dir/spec.nut → exe_dir/modules/spec.nut
    private bool resolve_script_path (string spec, out string abs_path) {
        abs_path = "";

        // 1) direct .nut path
        if (spec.has_suffix (".nut")) {
            File f = File.new_for_path (spec);
            if (f.query_exists () && f.query_file_type (FileQueryInfoFlags.NONE) == FileType.REGULAR) {
                abs_path = f.get_path ();
                return true;
            }
        }

        // 2) PWD/spec.nut
        string pwd = Environment.get_variable ("PWD") ?? ".";
        string candidate = Path.build_filename (pwd, spec + ".nut");
        if (FileUtils.test (candidate, FileTest.IS_REGULAR)) {
            abs_path = candidate;
            return true;
        }

        // 3) CSQ_PATH entries
        foreach (var dir in split_paths (Environment.get_variable ("CSQ_PATH"))) {
            candidate = Path.build_filename (dir, spec + ".nut");
            if (FileUtils.test (candidate, FileTest.IS_REGULAR)) {
                abs_path = candidate;
                return true;
            }
        }

        // 4) executable dir /modules/spec.nut (optional nicety)
        string? exe_path = Environment.find_program_in_path ("csq");
        if (exe_path != null) {
            string exedir = Path.get_dirname (exe_path);
            candidate = Path.build_filename (exedir, "modules", spec + ".nut");
            if (FileUtils.test (candidate, FileTest.IS_REGULAR)) {
                abs_path = candidate;
                return true;
            }
        }

        return false;
    }

    // Try to open a native module via CSQ_PATH, PWD, then PATH
    private Module? open_native_module (string spec) {
        // CSQ_PATH
        foreach (var dir in split_paths (Environment.get_variable ("CSQ_PATH"))) {
            string p = Module.build_path (dir, spec);
            var m = Module.open (p, ModuleFlags.LAZY);
            if (m != null) return m;
        }

        // PWD
        string pwd = Environment.get_variable ("PWD") ?? ".";
        {
            string p = Module.build_path (pwd, spec);
            var m = Module.open (p, ModuleFlags.LAZY);
            if (m != null) return m;
        }

        // PATH entries
        foreach (var dir in split_paths (Environment.get_variable ("PATH"))) {
            string p = Module.build_path (dir, spec);
            var m = Module.open (p, ModuleFlags.LAZY);
            if (m != null) return m;
        }
        return null;
    }

    // Split PATH/CSQ_PATH style lists into components
    private static string[] split_paths (string? s) {
        if (s == null || s == "") return {};
#if WINDOWS
        string sep = ";";
#else
        string sep = ":";
#endif
        return s.split (sep);
    }

}
