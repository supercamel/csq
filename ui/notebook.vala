namespace ui
{

void expose_notebook(Squirrel.Vm vm)
{
    vm.push_string("Notebook");
    vm.new_class(false);

    expose_widget_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var br = new Gtk.Notebook();
        vm.set_instance_up(1, br);
        br.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.Notebook;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false);



    vm.new_slot(-3, false);
}

}

