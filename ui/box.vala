
namespace ui
{

private void expose_box(Squirrel.Vm vm)
{
    vm.push_string("Orientation");
    vm.new_table();
    vm.push_string("HORIZONTAL");
    vm.push_int(Gtk.Orientation.HORIZONTAL);
    vm.new_slot(-3, true);
    vm.push_string("VERTICAL");
    vm.push_int(Gtk.Orientation.VERTICAL);
    vm.new_slot(-3, true);
    vm.new_slot(-3, true);


    vm.push_string("Box");
    vm.new_class(false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top != 3) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }

        long o, s;
        vm.get_int(2, out o);
        vm.get_int(3, out s);

        var wr = new Gtk.Box((Gtk.Orientation)o, (int)s);
        vm.set_instance_up(1, wr);
        wr.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.Box;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false); // add the constructor to the class


    vm.push_string("pack_start");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top < 2) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }
        var box = vm.get_instance(1) as Gtk.Box;
        Gtk.Widget* w;
        vm.get_instance_up(2, out w, null, false);
        bool expand = false;
        bool fill = false;
        long padding = 0;

        if(top > 2) {
            vm.get_bool(3, out expand);
        }
        if(top > 3) {
            vm.get_bool(4, out fill);
        }
        if(top > 4) {
            vm.get_int(5, out padding);
        }
        box.pack_start(w, expand, fill, (int)padding);
        return 0;
    }, 0);
    vm.set_params_check(-2, "xxbbi");
    vm.new_slot(-3, false);

    vm.push_string("pack_end");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top < 2) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }
        var box = vm.get_instance(1) as Gtk.Box;
        Gtk.Widget* w;
        vm.get_instance_up(2, out w, null, false);
        bool expand = false;
        bool fill = false;
        long padding = 0;

        if(top > 2) {
            vm.get_bool(3, out expand);
        }
        if(top > 3) {
            vm.get_bool(4, out fill);
        }
        if(top > 4) {
            vm.get_int(5, out padding);
        }
        box.pack_end(w, expand, fill, (int)padding);
        return 0;
    }, 0);
    vm.set_params_check(-2, "xxbbi");
    vm.new_slot(-3, false);

    vm.push_string("set_homogeneous");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top != 2) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }
        var b = vm.get_instance(1) as Gtk.Box;
        bool h;
        vm.get_bool(2, out h);
        b.set_homogeneous(h);
        return 0;
    }, 0);
    vm.set_params_check(2, "xb");
    vm.new_slot(-3, false);

    vm.push_string("set_spacing");
    vm.new_closure((vm) => {
        var b = vm.get_instance(1) as Gtk.Box;
        long s;
        vm.get_int(2, out s);
        b.set_spacing((int)s);
        return 0;
    } , 0);
    vm.set_params_check(2, "xi");
    vm.new_slot(-3, false);


    vm.new_slot(-3, false); 
}

}
