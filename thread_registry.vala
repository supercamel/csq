using Gee; 
public class ThreadRegistry : Object {
    private uint next_id = 1;
    private HashMap<uint, Squirrel.Vm> threads;

    public ThreadRegistry () {
        threads = new HashMap<uint, Squirrel.Vm> ();
    }

    public uint register_thread (Squirrel.Vm thread) {
        // Keep Squirrel-side ref alive
        uint id = next_id++;
        threads[id] = thread;
        return id;
    }

    public Squirrel.Vm? get_thread (uint id) {
        Squirrel.Vm? t = null;
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
}

ThreadRegistry thread_registry;