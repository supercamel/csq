
GLib.List<Squirrel.Vm> thread_queue;


class SuspendedCoroutineGuard : Object
{
    public SuspendedCoroutineGuard(Squirrel.Vm v)
    {
        vm = v;
        killed = false;

        vm.set_foreign_pointer(this);

        vm.set_vm_release_hook((ptr, sz) => {
            var sus = ptr as SuspendedCoroutineGuard;
            sus.killed = true;
            return Squirrel.OK;
        });
    }

    ~SuspendedCoroutineGuard() {
        if (!killed) {
            vm.set_vm_release_hook(null);
            vm.set_foreign_pointer(null);
            vm.get_last_error();
            if(vm.get_object_type(-1) == Squirrel.OBJECTTYPE.NULL) {
                vm.pop(1);
                vm.wake_up(true, false, true, false);
            } else {
                vm.wake_up(true, false, true, true);
            }
        }
    }

    public bool wake_up() {
        if(killed) {
            return false;
        }
        else {
            thread_queue.append(vm);
            GLib.Idle.add(wake_up_threads);
            return true;
        }
    }

    Squirrel.Vm vm;
    bool killed;
}


bool wake_up_threads() 
{
    thread_queue = new GLib.List<Squirrel.Vm>();
    return false;
}


void expose_sleep(Squirrel.Vm vm)
{
    thread_queue = new GLib.List<Squirrel.Vm>();

    vm.push_root_table();
    vm.push_string("sleep_async");
    vm.new_closure((vm) => {
        long count_ms;
        vm.get_int(-1, out count_ms);


        var scr = new SuspendedCoroutineGuard(vm);

        GLib.Timeout.add((uint)count_ms, () => {
            if(scr.wake_up()) {
                vm.push_null();
            }
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

        Squirrel.Obj self;
        vm.get_stack_object(-3, out self);

        GLib.Timeout.add((uint)count_ms, () => {
            vm.push_object(callback);
            vm.push_object(self);
            run_callback(vm, 1, "timeout");

            bool result;
            vm.get_bool(-1, out result);
            return result;
        });
        return 1;
    }, 0);
    vm.set_params_check(3, ".ic");
    vm.new_slot(-3, false);


    vm.pop(1);
}

public async void pause_until_idle() {
    GLib.Idle.add (() => {
        pause_until_idle.callback ();
        return false;
    });
    yield;
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
