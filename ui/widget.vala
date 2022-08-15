
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

    }

}
