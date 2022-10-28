namespace ui
{
    void expose_scrolled(Squirrel.Vm vm)
    {
        vm.push_string("ScrolledWindow");
        vm.new_class(false);

        expose_widget_base(vm);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            var wr = new Gtk.ScrolledWindow(null, null);
            vm.set_instance_up(1, wr);
            wr.ref();

            var w = vm.get_instance(2) as Gtk.Widget;
            wr.add_with_viewport(w);
            wr.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

            vm.push_string("__child");
            vm.push(2);
            vm.set(1);

            vm.set_release_hook(-1, (ptr, sz) => {
                var m = ptr as Gtk.ScrolledWindow;
                m.unref();
                return 0; 
            });
            return 1;
        }, 0);
        vm.set_params_check(2, ".x");
        vm.new_slot(-3, false); // add the constructor to the class

        vm.push_string("__child");
        vm.push_null();
        vm.new_slot(-3, false);

        vm.new_slot(-3, false); // add the class to the root table
    }
}
