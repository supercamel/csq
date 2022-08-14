namespace ui
{


private void expose_window(Squirrel.Vm vm)
{
    vm.push_string("Window");
    vm.new_class(false);

    expose_object_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var wr = new Gtk.Window();
        vm.set_instance_up(-1, wr);
        wr.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.Window;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false); // add the constructor to the class


    vm.push_string("connect");
    vm.new_closure((vm) => {
        var gg = vm.get_instance(1) as Gtk.Window;

        string signal_name;
        vm.get_string(-2, out signal_name); // signal name is passed as the 'second last' parameter


        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object

        Squirrel.Obj self; // keep a copy of the class instance
        vm.get_stack_object(-3, out self);

        switch(signal_name) {
            case "destroy":
                gg.destroy.connect(() => {
                    vm.push_object(callback);
                    vm.push_object(self);
                    run_callback(vm, 1, signal_name);
                });
            break;
            default:
                return vm.throw_error("no such signal: " + signal_name);
        }

        vm.push_string("__callbacks");
        vm.get(1);
        vm.push_object(callback);
        vm.array_append(-2);

        return 0; // no values returned
    }, 0);
    vm.new_slot(-3, false); //put the 'connect' function into the class


    vm.push_string("close");
    vm.new_closure((vm) => {
        var window = vm.get_instance(1) as Gtk.Window;
        window.close();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_title");
    vm.new_closure((vm) => {
        var window = vm.get_instance(1) as Gtk.Window;
        string title;
        vm.get_string(-1, out title);
        window.set_title(title);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("show_all");
    vm.new_closure((vm) => {
        var window = vm.get_instance(1) as Gtk.Window;
        window.show_all();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("fullscreen");
    vm.new_closure((vm) => {
        var window = vm.get_instance(1) as Gtk.Window;
        window.fullscreen();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("deiconify");
    vm.new_closure((vm) => {
        var window = vm.get_instance(1) as Gtk.Window;
        window.deiconify();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("get_default_size");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Window;
        int w, h;
        wr.get_default_size(out w, out h);
        vm.new_array(0);
        vm.push_int(w);
        vm.array_append(-2);
        vm.push_int(h);
        vm.array_append(-2);
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_decorated");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Window;
        bool decorated;
        vm.get_bool(2, out decorated);
        wr.decorated = decorated;
        return 0;
    } , 0);
    vm.new_slot(-3, false);

    vm.push_string("get_decorated");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Window;
        vm.push_bool(wr.decorated);
        return 1;
    } , 0);
    vm.new_slot(-3, false);

    vm.push_string("set_resizable");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Window;
        bool resizable;
        vm.get_bool(2, out resizable);
        wr.resizable = resizable;
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_icon");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Window;
        string icon_path;
        vm.get_string(2, out icon_path);
        try {
            wr.set_icon_from_file(icon_path);
        }
        catch(Error e) {
            return vm.throw_error(e.message);
        }
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_transient_for");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Window;
        Gtk.Window* parent;
        vm.get_instance_up(2, out parent, null, false);
        wr.set_transient_for(parent);
        return 0;
    }, 0);
    vm.new_slot(-3, false);


    vm.push_string("add");
    vm.new_closure((vm) => {
        var window = vm.get_instance(1) as Gtk.Window;
        Gtk.Widget* w;
        vm.get_instance_up(2, out w, null, false);
        window.add(w);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}

}
