
namespace csq
{

GLib.MainLoop main_loop = null;

void expose_main_loop(Squirrel.Vm vm)
{
    GLib.MainLoop loop = new GLib.MainLoop(null, false);
    main_loop = loop;

    vm.push_string("main_loop");
    vm.new_table();

    vm.push_string("run");
    vm.new_closure((vm) => {
        if(main_loop.is_running())
            return vm.throw_error("Main loop is already running.");
    
        main_loop.run();
        return 0;
    }, 0);
    vm.set_params_check(1, ".");
    vm.new_slot(-3, false);

    vm.push_string("quit");
    vm.new_closure((vm) => {
        main_loop.quit();
        return 0;
    }, 0);
    vm.set_params_check(1, ".");
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}

}
