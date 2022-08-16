private void expose_sleep(Squirrel.Vm vm)
{
    vm.push_root_table();
    vm.push_string("sleep");
    vm.new_closure((vm) => {
        long time;
        vm.get_int(2, out time);

        GLib.Timeout.add((int)time, () => {
            print("woken up\n");
            vm.push_null();
            vm.wake_up(true, false, true, false);
            return false;
        });

        return vm.suspend();
    }, 0);
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

