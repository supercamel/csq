
GLib.List<Squirrel.Vm> thread_queue;


class SuspendedCoroutineGuard : Object
{
    public SuspendedCoroutineGuard(uint handle)
    {
        wakeup_handle = handle;
    }

    public void release_handle()
    {
        GLib.Source.remove(wakeup_handle);
    }

    ~SuspendedCoroutineGuard()
    {
    }

    public uint wakeup_handle;
}


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

void release_foreign_pointer(Squirrel.Vm vm)
{
    var foreign_ptr = vm.get_foreign_pointer();
    if(foreign_ptr != null) {
        var fptr = foreign_ptr as GLib.Object;
        fptr.unref();
    }
}

void expose_sleep(Squirrel.Vm vm)
{
    thread_queue = new GLib.List<Squirrel.Vm>();

    vm.push_root_table();
    vm.push_string("sleep_thread");
    vm.new_closure((vm) => {
        long count_ms;
        vm.get_int(-1, out count_ms);

        uint src = GLib.Timeout.add((uint)count_ms, () => {
            vm.push_null();
            thread_queue.append(vm);
            vm.set_vm_release_hook((ptr, sz) => {
                var sus = ptr as SuspendedCoroutineGuard;
                sus.unref();
                return Squirrel.OK;
            });
            GLib.Idle.add(wake_up_threads);
            return false;
        });

        release_foreign_pointer(vm);
        var scr = new SuspendedCoroutineGuard(src);
        vm.set_foreign_pointer(scr);
        scr.ref();

        vm.set_vm_release_hook((ptr, sz) => {
            var sus = ptr as SuspendedCoroutineGuard;
            sus.release_handle();
            sus.unref();
            return Squirrel.OK;
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
        vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object

        Squirrel.Obj self; // keep a copy of the class instance
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
