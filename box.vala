

class BoxWrap : Gtk.Box
{
    public BoxWrap(Squirrel.Vm v, Gtk.Orientation o, int s)
    {
        orientation = o;
        spacing = s;
        vm = v;
    }

    ~BoxWrap() {
        for(int i = 0; i < callbacks.length(); i++) {
            Squirrel.Obj o = callbacks.nth_data(i);
            vm.release(o);
        }
    }        
    public SList<Squirrel.Obj> callbacks;
    private Squirrel.Vm vm;
}

public void csq_wrap_gtk_box(Squirrel.Vm vm)
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

        BoxWrap wr = new BoxWrap(vm, (Gtk.Orientation)o, (int)s);
        vm.set_instance_up(1, wr);
        wr.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            BoxWrap m = ptr as BoxWrap;
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
        BoxWrap* b;
        vm.get_instance_up(1, out b, null, false);
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
        b->pack_start(w, expand, fill, (int)padding);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("pack_end");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top < 2) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }
        BoxWrap* b;
        vm.get_instance_up(1, out b, null, false);
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
        b->pack_end(w, expand, fill, (int)padding);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_homogeneous");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top != 2) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }
        BoxWrap b = vm.get_instance(1) as BoxWrap;
        bool h;
        vm.get_bool(2, out h);
        b.set_homogeneous(h);
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_spacing");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top != 2) {
            vm.throw_error("InvalidArgumentCount");
            return -1;
        }
        BoxWrap b = vm.get_instance(1) as BoxWrap;
        long s;
        vm.get_int(2, out s);
        b.set_spacing((int)s);
        return 0;
    } , 0);
    vm.new_slot(-3, false);


    vm.new_slot(-3, false); 
}


