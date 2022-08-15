
namespace ui
{
    void expose_widget_base(Squirrel.Vm vm)
    {
        vm.push_string("set_expand");
        vm.new_closure((vm) => {
            Gtk.Widget widget = vm.get_instance(1) as Gtk.Widget;
            bool expand;
            vm.get_bool(2, out expand);
            widget.expand = expand; 
            return 0;
        }, 0);
        vm.set_params_check(-2, "xb");
        vm.new_slot(-3, false);

        vm.push_string("set_vexpand");
        vm.new_closure((vm) => {
            Gtk.Widget widget = vm.get_instance(1) as Gtk.Widget;
            bool expand;
            vm.get_bool(2, out expand);
            widget.hexpand = expand; 
            return 0;
        }, 0);
        vm.set_params_check(-2, "xb");
        vm.new_slot(-3, false);

        vm.push_string("set_hexpand");
        vm.new_closure((vm) => {
            Gtk.Widget widget = vm.get_instance(1) as Gtk.Widget;
            bool expand;
            vm.get_bool(2, out expand);
            widget.vexpand = expand; 
            return 0;
        }, 0);
        vm.set_params_check(-2, "xb");
        vm.new_slot(-3, false);

        vm.push_string("set_opacity");
        vm.new_closure((vm) => {
            Gtk.Widget widget = vm.get_instance(1) as Gtk.Widget;
            float opacity;
            vm.get_float(2, out opacity);
            widget.opacity = (double)opacity; 
            return 0;
        }, 0);
        vm.set_params_check(2, "xf");
        vm.new_slot(-3, false);

        vm.push_string("set_size_request");
        vm.new_closure((vm) => {
            Gtk.Widget widget = vm.get_instance(1) as Gtk.Widget;
            long width;
            vm.get_int(2, out width);
            long height;
            vm.get_int(3, out height);
            widget.set_size_request((int)width, (int)height); 
            return 0;
        }, 0);
        vm.set_params_check(3, "xii");
        vm.new_slot(-3, false);

    }

}
