namespace csq
{
public class SquirrelThread : Object {
    public SquirrelThread(Squirrel.Vm base_vm, Squirrel.Obj env) {
        this.base_vm = base_vm;
        this.env = env;
        vm = base_vm.new_thread(1024 * 16);

        base_vm.get_stack_object(-1, out thread_obj);

        base_vm.add_ref(thread_obj);
        base_vm.add_ref(env);
    }

    public void cancel() {
        if(vm.get_state() == Squirrel.VMSTATE.IDLE)
            return; // already done
        cancelled();
    }

    public signal void cancelled();

    public Squirrel.Vm base_vm;
    public Squirrel.Vm vm;
    public Squirrel.Obj thread_obj;
    public Squirrel.Obj foo; // the function to run
    public Squirrel.Obj env; // the environment / 'this' table
    public uint id;
}

public bool check_async_registration(Squirrel.Vm vm)
{
    void* ptr_obj = vm.get_foreign_pointer();
    if(ptr_obj == null) {
        return false;
    }

    if((Object)ptr_obj is SquirrelThread == false) {
        return false;
    }
    return true;
}


}