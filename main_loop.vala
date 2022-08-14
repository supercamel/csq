
public void csq_wrap_gtk_main(Squirrel.Vm vm)
{
    vm.push_root_table();
    vm.push_string("Gtk"); 
    vm.new_table();

    vm.push_string("main");
    vm.new_closure((vm) => {
        Gtk.main();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("main_quit");
    vm.new_closure((vm) => {
        Gtk.main_quit();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
    vm.pop(1);
}