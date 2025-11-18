
namespace csq 
{

void expose_async(Squirrel.Vm vm)
{
    vm.push_string("async_run");
    vm.new_closure((vm) => {
        long top = vm.get_top();

        // arg 1: system table
        // arg 2: foo (the async function)
        Squirrel.Obj thread_env;
        vm.get_stack_object(1, out thread_env);

        Squirrel.Obj foo;
        vm.get_stack_object(2, out foo);

            // Create new Squirrel thread VM
        stdout.printf("Creating new async thread VM\n");
        var thread = new SquirrelThread(vm, thread_env);

        // Register it in your registry and stash ID as foreign pointer
        thread_registry.register_thread(thread);
        thread.vm.set_foreign_pointer(thread);
        thread.vm.set_vm_release_hook((ptr, sz) => { 
            stdout.printf("Releasing async thread VM\n");
            // The thread is released and unregistered by the thread_registry's check_threads function
            return Squirrel.OK; 
        });

        thread.vm.push_object(foo);
        thread.vm.push_object(thread_env);         // or whatever 'this' / env you want to pass

        // push any parameters after that here
        for(long i = 3; i <= top; i++) {
            Squirrel.Obj param;
            vm.get_stack_object(i, out param);
            thread.vm.push_object(param);
        }
        
        if (thread.vm.call(top - 1, false, false) != Squirrel.OK) {
            thread.vm.get_last_error();
            string msg;
            thread.vm.get_string(-1, out msg);
            warning("Error in async thread: %s", msg);
        }

        vm.new_table();
        vm.push_string("cancel");
        vm.new_closure((vm) => {
            thread.cancel();
            return 0;
        }, 0);
        vm.set_params_check(1, ".");
        vm.new_slot(-3, false);

        return 1;

    }, 0);
    vm.set_params_check(-2, ".c"); // root table + closure

    vm.new_slot(-3, false); // add async_run to the root table


    GLib.Timeout.add (10, () => {
        thread_registry.check_threads();
        return true;
    });
}
}
