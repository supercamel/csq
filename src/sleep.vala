
namespace csq
{
void expose_sleep(Squirrel.Vm vm)
{
    vm.push_string("sleep_async");
    vm.new_closure((vm) => {
        if(!check_async_registration(vm)) {
            return vm.throw_error("Async thread is not registered. Use async_run to start async functions.");
        }
        long count_ms;
        vm.get_int(-1, out count_ms);

        SquirrelThread thread = vm.get_foreign_pointer() as SquirrelThread;

        uint timeout_id = 0;

        var handle = thread.cancelled.connect(() => {
            if(timeout_id != 0)
                GLib.Source.remove(timeout_id);
        });

        timeout_id = GLib.Timeout.add((uint)count_ms, () => {
            thread.disconnect(handle);
            vm.wake_up(false, false, true, false);
            return false;
        });

        
        return vm.suspend();
    }, 0);
    vm.set_params_check(2, ".i");
    vm.new_slot(-3, false);


    vm.push_string("add_timeout");
    vm.new_closure((vm) => {
        long count_ms;
        vm.get_int(-2, out count_ms);

        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); 
        vm.add_ref(callback);

        Squirrel.Obj self;
        vm.get_stack_object(-3, out self);
        vm.add_ref(self);

        GLib.Timeout.add((uint)count_ms, () => {
            var top = vm.get_top();
            vm.push_object(callback);
            vm.push_object(self);
            vm.run_callback(1, "timeout");

            bool result;
            vm.get_bool(-1, out result);
            if(result == false) {
                vm.release(callback);
                vm.release(self);
            }
            vm.set_top(top);
            return result;
        });
        return 1;
    }, 0);
    vm.set_params_check(3, ".ic");
    vm.new_slot(-3, false);
}

}
