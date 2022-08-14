
class WindowWrap : Gtk.Window
{
    public WindowWrap(Squirrel.Vm v)
    {
        vm = v;
    }

    ~WindowWrap() {
        for(int i = 0; i < callbacks.length(); i++) {
            Squirrel.Obj o = callbacks.nth_data(i);
            vm.release(o);
        }
    }        
    public SList<Squirrel.Obj> callbacks;
    private Squirrel.Vm vm;
}


public void csq_wrap_gtk_window(Squirrel.Vm vm)
{
    vm.push_string("Window");
    vm.new_class(false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        WindowWrap wr = new WindowWrap(vm);
        vm.set_instance_up(-1, wr);
        wr.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            WindowWrap m = ptr as WindowWrap;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false); // add the constructor to the class


    vm.push_string("connect");
    vm.new_closure((vm) => {
        WindowWrap* gg;
        vm.get_instance_up(1, out gg, null, false);

        string signal_name;
        vm.get_string(-2, out signal_name); // signal name is passed as the 'second last' parameter


        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object
        vm.add_ref(callback); // reference it so the VM doesn't destroy it as it goes out of scope

        gg->callbacks.append(callback); // add to the list of callbacks - so it can be unreferenced later

        Squirrel.Obj self; // keep a copy of the class instance
        vm.get_stack_object(-3, out self);

        switch(signal_name) {
            case "destroy":
                gg->destroy.connect(() => {
                    vm.push_object(callback);
                    vm.push_object(self);
                    vm.call(1, true, true);
                });
            break;
            default:
                return vm.throw_error("no such signal: " + signal_name);
        }

        return 0; // no values returned
    }, 0);
    vm.new_slot(-3, false); //put the 'connect' function into the class


    vm.push_string("close"); // wrap the foo function
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        wr->close();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_title");
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        string title;
        vm.get_string(-1, out title);
        wr->set_title(title);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("show_all");
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        wr->show_all();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("fullscreen");
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        wr->fullscreen();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("deiconify");
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        wr->deiconify();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("get_default_size");
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        int w, h;
        wr->get_default_size(out w, out h);
        vm.new_array(0);
        vm.push_int(w);
        vm.array_append(-2);
        vm.push_int(h);
        vm.array_append(-2);
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("add");
    vm.new_closure((vm) => {
        WindowWrap* wr;
        vm.get_instance_up(1, out wr, null, false);
        Gtk.Widget* w;
        vm.get_instance_up(2, out w, null, false);
        wr->add(w);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}
