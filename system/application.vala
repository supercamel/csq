long deregister_thread(void* ptr, long sz) {
        uint id = (uint)ptr;
        thread_registry.unregister_thread(id);
        return Squirrel.OK;
    }

namespace console
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

    void expose_application(Squirrel.Vm vm, string[] args)
    {
        vm.push_string("system");
        vm.new_table();

        vm.push_string("run_async");
        vm.new_closure((vm) => {
            long top = vm.get_top();

            // arg 1: system table
            // arg 2: foo (the async function)
            Squirrel.Obj foo;
            vm.get_stack_object(2, out foo);

            stdout.printf("creating async thread...\n");
            stdout.flush();

            // Create new Squirrel thread VM
            var thread_vm = vm.new_thread(1024 * 16);

            //Ref the thread
            Squirrel.Obj thread_obj;
            vm.get_stack_object(-1, out thread_obj);
            vm.add_ref(thread_obj);

            // Register it in your registry and stash ID as foreign pointer
            uint id = thread_registry.register_thread(thread_vm);
            thread_vm.set_foreign_pointer((void*) id);
            thread_vm.set_vm_release_hook((ptr, sz) => { 
                uint _id = (uint)ptr; 
                thread_registry.unregister_thread(_id); 
                return Squirrel.OK; 
            });

            thread_vm.push_object(foo);
            thread_vm.push_root_table();         // or whatever 'this' / env you want to pass
            
            stdout.printf("Starting async thread...\n");
            stdout.flush();

            if (thread_vm.call(1, false, false) != Squirrel.OK) {
                thread_vm.get_last_error();
                string msg;
                thread_vm.get_string(-1, out msg);
                warning("Error in async thread: %s", msg);
                // unref thread
                vm.release(thread_obj);
            }

            // run_async returns nothing, or you can return the thread_obj if you want a handle
            return 0;
        }, 0);
        vm.set_params_check(2, ".c"); // system + closure
        vm.new_slot(-3, false);

        vm.push_string("get_args");
        vm.new_closure((vm) => {
            var app = vm.get_instance(1) as ConsoleApplication;
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
            var line = stdout.read_line();
            vm.push_string(line);
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

        vm.push_string("ConsoleApplication");
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
        vm.new_closure((vm) => {
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

        // add the console table to the root table
        vm.new_slot(-3, false);
    }
}