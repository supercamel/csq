
namespace ui
{

private void expose_main(Squirrel.Vm vm)
{
    vm.push_string("main");
    vm.new_closure((vm) => {
        Gtk.main();
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("main_quit");
    vm.new_closure((vm) => {
        GLib.Idle.add(() => {
            Gtk.main_quit();
            return false;
        });
        return 0;
    }, 0);
    vm.new_slot(-3, false);
}

}
