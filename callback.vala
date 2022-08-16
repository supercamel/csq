
GLib.List<Squirrel.Vm> thread_queue;


bool wake_up_threads() 
{
    var list_copy = new GLib.List<Squirrel.Vm>();

    thread_queue.foreach((vm) => {
        list_copy.append(vm);
    });

    thread_queue = new GLib.List<Squirrel.Vm>();

    list_copy.foreach((vm) => {
        vm.wake_up(true, false, true, false);
    });

    return false;
}

void expose_sleep(Squirrel.Vm vm)
{
    thread_queue = new GLib.List<Squirrel.Vm>();

    vm.push_root_table();
    vm.push_string("sleep");
    vm.new_closure((vm) => {
        long count_ms;
        vm.get_int(-1, out count_ms);

        GLib.Timeout.add((uint)count_ms, () => {
            print("timeout\n");
            vm.push_null();
            thread_queue.append(vm);
            GLib.Idle.add(wake_up_threads);
            return false;
        });

        return vm.suspend();
    }, 0);
    vm.set_params_check(2, ".i");
    vm.new_slot(-3, false);
    vm.pop(1);
}

void run_callback(Squirrel.Vm vm, int n_params, string signal_name)
{
    if(vm.call(n_params, true, false) != Squirrel.OK) {
        string msg = "";
        vm.get_last_error();
        vm.get_string(-1, out msg);
        warning("Error in signal handler %s: %s", signal_name, msg);
    }
}
