
namespace ui
{

private void expose_menu(Squirrel.Vm vm) {
    // expose MenuBar
    vm.push_string("MenuBar");
    vm.new_class(false);

    expose_object_base(vm);
    expose_widget_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var br = new Gtk.MenuBar();
        vm.set_instance_up(1, br);
        br.ref();
        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.MenuBar;
            m.unref();
            return 0;
        });
        return 1;
    }, 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);

    vm.push_string("append");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MenuBar;
        var mi = vm.get_instance(2) as Gtk.MenuItem;

        vm.push_string("__children");
        vm.get(1);
        vm.push(2);
        vm.array_append(-2);

        m.append(mi);
        return 0;
    }, 0);
    vm.set_params_check(2, "xx");
    vm.new_slot(-3, false);

    vm.push_string("__children");
    vm.new_array(0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);


    // expose Menu
    vm.push_string("Menu");
    vm.new_class(false);

    expose_object_base(vm);
    expose_widget_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var br = new Gtk.Menu();
        
        vm.set_instance_up(1, br);
        br.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.Menu;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);

    vm.push_string("append");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.Menu;
        var i = vm.get_instance(2) as Gtk.MenuItem;
        m.append(i);

        vm.push_string("__children");
        vm.get(1);
        vm.push(2);
        vm.array_append(-2);
        return 0;
    }, 0);
    vm.set_params_check(2, "xx");
    vm.new_slot(-3, false);
    
    vm.push_string("__children");
    vm.new_array(0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);

    // expose MenuItem
    vm.push_string("MenuItem");
    vm.new_class(false);

    expose_object_base(vm);
    expose_widget_base(vm);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        string label;
        vm.get_string(2, out label);

        var br = new Gtk.MenuItem.with_label(label);
        
        vm.set_instance_up(1, br);
        br.ref();

        vm.set_release_hook(1, (ptr, sz) => {
            var m = ptr as Gtk.MenuItem;
            stdout.printf("release menuitem %s\n", m.get_label());
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.set_params_check(2, "xs");
    vm.new_slot(-3, false);

    vm.push_string("set_submenu");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MenuItem;
        var s = vm.get_instance(2) as Gtk.Menu;
        m.set_submenu(s);

        vm.push_string("__submenus");
        vm.get(1);
        vm.push(2);
        vm.array_append(-2);

        return 0;
    }, 0);
    vm.set_params_check(2, "xx");
    vm.new_slot(-3, false);

    vm.push_string("on_activate");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MenuItem;

        Squirrel.Obj self; // keep a copy of the class instance
        vm.get_stack_object(1, out self);

        Squirrel.Obj callback;
        vm.get_stack_object(2, out callback);

        m.activate.connect(() => {
            vm.push_object(callback);
            vm.push_object(self);
            run_callback(vm, 1, "on_activate");
        });
        vm.push_string("__on_activate_callback");
        vm.push(2);
        vm.set(1);

        stdout.printf("refs: %i\n", (int)vm.get_ref_count(callback));
        return 0;
    }, 0);
    vm.set_params_check(2, "xc");
    vm.new_slot(-3, false);

    vm.push_string("__on_activate_callback");
    vm.new_closure((vm) => {
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("__submenus");
    vm.new_array(0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}

}