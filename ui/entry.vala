
namespace ui
{

private void expose_entry(Squirrel.Vm vm)
{
    vm.push_string("Entry");
    vm.new_class(false);

    expose_widget_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var br = new Gtk.Entry();
        vm.set_instance_up(1, br);
        br.ref();

        if(vm.get_top() > 1) {
            string label = "";
            vm.get_string(2, out label);
            br.set_text(label);
        }

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.Entry;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("connect");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Entry;

        string signal_name;
        vm.get_string(-2, out signal_name); // signal name is passed as the 'second last' parameter

        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object

        Squirrel.Obj self; // keep a copy of the class instance
        vm.get_stack_object(-3, out self);

        switch(signal_name) {
            case "preedit-changed":
                br.preedit_changed.connect((preedit) => {
                    vm.push_object(callback);
                    vm.push_object(self);
                    vm.push_string(preedit);
                    run_callback(vm, 2, signal_name);
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
    vm.new_slot(-3, false);

    vm.push_string("set_text");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Entry;
        string text = "";
        vm.get_string(2, out text);
        br.set_text(text);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("get_text");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Entry;
        vm.push_string(br.get_text());
        return 1;
    }, 0);
    vm.new_slot(-3, false);


    vm.new_slot(-3, false);
}

}
