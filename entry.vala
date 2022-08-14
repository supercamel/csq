
class EntryWrap : Gtk.Entry
{
    public EntryWrap(Squirrel.Vm v)
    {
        vm = v;
    }

    ~EntryWrap() {
        for(int i = 0; i < callbacks.length(); i++) {
            Squirrel.Obj o = callbacks.nth_data(i);
            vm.release(o);
        }
    }        
    public SList<Squirrel.Obj> callbacks;
    private Squirrel.Vm vm;
}

public void csq_wrap_gtk_entry(Squirrel.Vm vm)
{
    vm.push_string("Entry");
    vm.new_class(false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        EntryWrap br = new EntryWrap(vm);
        vm.set_instance_up(1, br);
        br.ref();

        if(vm.get_top() > 1) {
            string label = "";
            vm.get_string(2, out label);
            br.set_text(label);
        }

        vm.set_release_hook(-1, (ptr, sz) => {
            EntryWrap m = ptr as EntryWrap;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("connect");
    vm.new_closure((vm) => {
        EntryWrap br = vm.get_instance(1) as EntryWrap;

        string signal_name;
        vm.get_string(-2, out signal_name); // signal name is passed as the 'second last' parameter

        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object
        vm.add_ref(callback); // reference it so the VM doesn't destroy it as it goes out of scope

        br.callbacks.append(callback); // add to the list of callbacks - so it can be unreferenced later

        Squirrel.Obj self; // keep a copy of the class instance
        vm.get_stack_object(-3, out self);

        switch(signal_name) {
            case "preedit-changed":
                br.preedit_changed.connect((preedit) => {
                    vm.push_object(callback);
                    vm.push_object(self);
                    vm.push_string(preedit);
                    vm.call(2, true, true);
                });
            break;
            default:
                return vm.throw_error("no such signal: " + signal_name);
        }

        return 0; // no values returned 
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_text");
    vm.new_closure((vm) => {
        EntryWrap br = vm.get_instance(1) as EntryWrap;
        string text = "";
        vm.get_string(2, out text);
        br.set_text(text);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("get_text");
    vm.new_closure((vm) => {
        EntryWrap br = vm.get_instance(1) as EntryWrap;
        vm.push_string(br.get_text());
        return 1;
    }, 0);
    vm.new_slot(-3, false);


    vm.new_slot(-3, false);
}