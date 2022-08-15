namespace ui
{

private void expose_label(Squirrel.Vm vm)
{
    vm.push_string("Label");
    vm.new_class(false);

    expose_object_base(vm);
    expose_widget_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        Gtk.Label wr;

        var top = vm.get_top();
        if(top > 1) {
            string text = "";
            vm.get_string(2, out text);
            wr = new Gtk.Label(text);
        }
        else {
            wr = new Gtk.Label("");
        }

        vm.set_instance_up(1, wr);
        wr.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.Label;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_text");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top > 1) {
            string text = "";
            vm.get_string(2, out text);
            var wr = vm.get_instance(1) as Gtk.Label;
            wr.set_text(text);
        }
        else {
            return vm.throw_error("set_text: too few arguments");
        }
        return 0;
    }, 0);
    vm.set_params_check(2, "xs");
    vm.new_slot(-3, false);

    vm.push_string("get_text");
    vm.new_closure((vm) => {
        var wr = vm.get_instance(1) as Gtk.Label;
        string text = wr.get_text();
        vm.push_string(text);
        return 1;
    }, 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);

    vm.push_string("set_use_markup");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.Label;
        bool use_markup = false;
        vm.get_bool(2, out use_markup);
        br.set_use_markup(use_markup);
        return 0;
    }, 0);
    vm.set_params_check(2, "xb");
    vm.new_slot(-3, false);


    vm.push_string("set_xalign");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top > 1) {
            double align = 0.0;
            vm.get_float(2, out align);
            var wr = vm.get_instance(1) as Gtk.Label;
            wr.set_xalign((float)align);
        }
        else {
            return vm.throw_error("set_xalign: too few arguments");
        }
        return 0;
    }, 0);
    vm.set_params_check(2, "xf");
    vm.new_slot(-3, false);

    vm.push_string("set_yalign");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top > 1) {
            double align = 0.0;
            vm.get_float(2, out align);
            var wr = vm.get_instance(1) as Gtk.Label;
            wr.set_yalign((float)align);
        }
        else {
            return vm.throw_error("set_yalign: too few arguments");
        }
        return 0;
    } , 0);
    vm.set_params_check(2, "xf");
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}

}
