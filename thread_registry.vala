using Gee; 
public class ThreadRegistry : Object {
    private uint next_id = 1;
    private HashMap<uint, SquirrelThread> threads;

    public ThreadRegistry () {
        threads = new HashMap<uint, SquirrelThread> ();
    }

    public uint register_thread (SquirrelThread thread) {
        uint id = next_id++;
        threads[id] = thread;
        thread.id = id;
        return id;
    }

    public SquirrelThread? get_thread (uint id) {
        SquirrelThread? t = null;
        if (threads.has_key (id))
            t = threads[id];
        return t;
    }

    public void unregister_thread (uint id) {
        if (threads.has_key (id)) {
            var t = threads[id];
            threads.unset (id);
        }
    }

    public void unregister_all () {
        threads.clear ();
    }

    public void check_threads()
    {
        var to_remove = new ArrayList<uint> ();
        foreach (var pair in threads) {
            var id = pair.key;
            var thread = pair.value;
            if (thread.vm.get_state() == Squirrel.VMSTATE.IDLE) {
                stdout.printf("Cleaning up finished async thread %u\n", id);
                to_remove.add (id);
                thread.base_vm.release (thread.thread_obj);
                thread.base_vm.release (thread.env);
            }
        }
        foreach (var id in to_remove) {
            unregister_thread (id);
        }
    }
}

ThreadRegistry thread_registry;