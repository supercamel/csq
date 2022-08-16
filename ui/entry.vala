
namespace ui
{

private void expose_entry(Squirrel.Vm vm)
{
    vm.push_string("InputPurpose");
    vm.new_table();

    vm.push_string("ALPHA");
    vm.push_int(Gtk.InputPurpose.ALPHA);
    vm.new_slot(-3, true);

    vm.push_string("DIGITS");
    vm.push_int(Gtk.InputPurpose.DIGITS);
    vm.new_slot(-3, true);

    vm.push_string("EMAIL");
    vm.push_int(Gtk.InputPurpose.EMAIL);
    vm.new_slot(-3, true);

    vm.push_string("FREE_FORM");
    vm.push_int(Gtk.InputPurpose.FREE_FORM);
    vm.new_slot(-3, true);

    vm.push_string("NAME");
    vm.push_int(Gtk.InputPurpose.NAME);
    vm.new_slot(-3, true);

    vm.push_string("NUMBER");
    vm.push_int(Gtk.InputPurpose.NUMBER);
    vm.new_slot(-3, true);

    vm.push_string("PASSWORD");
    vm.push_int(Gtk.InputPurpose.PASSWORD);
    vm.new_slot(-3, true);

    vm.push_string("PHONE");
    vm.push_int(Gtk.InputPurpose.PHONE);
    vm.new_slot(-3, true);

    vm.push_string("PIN");
    vm.push_int(Gtk.InputPurpose.PIN);
    vm.new_slot(-3, true);

    vm.push_string("TERMINAL");
    vm.push_int(Gtk.InputPurpose.TERMINAL);
    vm.new_slot(-3, true);

    vm.push_string("URL");
    vm.push_int(Gtk.InputPurpose.URL);
    vm.new_slot(-3, true);
    
    vm.new_slot(-3, false);


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
                    Squirrel.Vm thread;
                    vm.new_thread(256);
                    vm.get_thread(-1, out thread);

                    thread.push_object(callback);
                    thread.push_object(self);
                    thread.push_string(preedit);
                    run_callback(thread, 2, signal_name);
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
    vm.set_params_check(3, "xsf");
    vm.new_slot(-3, false);

    vm.push_string("set_text");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Entry;
        string text = "";
        vm.get_string(2, out text);
        br.set_text(text);
        return 0;
    }, 0);
    vm.set_params_check(2, "xs");
    vm.new_slot(-3, false);

    vm.push_string("get_text");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Entry;
        vm.push_string(br.get_text());
        return 1;
    }, 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);


    vm.push_string("set_input_purpose");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Entry;
        long purpose = 0;
        vm.get_int(2, out purpose);
        br.set_input_purpose((Gtk.InputPurpose)purpose);
        return 0;
    } , 0);
    vm.set_params_check(2, "xi");
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}

}
