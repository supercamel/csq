

class LabelWrap : Gtk.Label
{
    public LabelWrap(Squirrel.Vm v)
    {
        vm = v;
    }

    ~LabelWrap() {
        for(int i = 0; i < callbacks.length(); i++) {
            Squirrel.Obj o = callbacks.nth_data(i);
            vm.release(o);
        }
    }        
    public SList<Squirrel.Obj> callbacks;
    private Squirrel.Vm vm;
}


public void csq_wrap_gtk_label(Squirrel.Vm vm)
{
    vm.push_string("Label");
    vm.new_class(false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        LabelWrap wr = new LabelWrap(vm);

        var top = vm.get_top();
        if(top > 1) {
            string text = "";
            vm.get_string(2, out text);
            wr.set_text(text);
        }

        vm.set_instance_up(1, wr);
        wr.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            BoxWrap m = ptr as BoxWrap;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_text");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top > 1) {
            string text = "";
            vm.get_string(2, out text);
            LabelWrap wr = vm.get_instance(1) as LabelWrap;
            wr.set_text(text);
        }
        else {
            return vm.throw_error("set_text: too few arguments");
        }
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("get_text");
    vm.new_closure((vm) => {
        LabelWrap wr = vm.get_instance(1) as LabelWrap;
        string text = wr.get_text();
        vm.push_string(text);
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_use_markup");
    vm.new_closure((vm) => {
        LabelWrap br = vm.get_instance(1) as LabelWrap;
        bool use_markup = false;
        vm.get_bool(2, out use_markup);
        br.set_use_markup(use_markup);
        return 0;
    }, 0);
    vm.new_slot(-3, false);


    vm.push_string("set_xalign");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top > 1) {
            double align = 0.0;
            vm.get_float(2, out align);
            LabelWrap wr = vm.get_instance(1) as LabelWrap;
            wr.set_xalign((float)align);
        }
        else {
            return vm.throw_error("set_xalign: too few arguments");
        }
        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("set_yalign");
    vm.new_closure((vm) => {
        var top = vm.get_top();
        if(top > 1) {
            double align = 0.0;
            vm.get_float(2, out align);
            LabelWrap wr = vm.get_instance(1) as LabelWrap;
            wr.set_yalign((float)align);
        }
        else {
            return vm.throw_error("set_yalign: too few arguments");
        }
        return 0;
    } , 0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}
