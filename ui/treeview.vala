
namespace ui 
{

private void expose_treeview(Squirrel.Vm vm)
{
    vm.push_string("Table");
    vm.new_class(false);

    expose_object_base(vm);
    expose_widget_base(vm);

    vm.push_string("__n_rows");
    vm.push_int(0);
    vm.new_slot(-3, false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var br = new Gtk.TreeView();
        vm.set_instance_up(1, br);
        br.ref();

        var top = vm.get_top();
        var sz = vm.get_size(-1);
        var column_names = new string[sz];
        var types = new GLib.Type[sz];
        for(int i = 0; i < sz; i++) {
            vm.push_int(i);
            vm.get(-2);
            vm.get_string(-1, out column_names[i]);
            vm.pop(1);
            types[i] = GLib.Type.STRING;
        }

        var liststore = new Gtk.ListStore.newv(types);
        br.set_model(liststore);

        for(int i = 0; i < sz; i++) {
            br.insert_column_with_attributes(-1, column_names[i], new Gtk.CellRendererText(), "text", i);
        }

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.TreeView;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.set_params_check(0, "");
    vm.new_slot(-3, false);

    vm.push_string("connect");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.TreeView;

        string signal_name;
        vm.get_string(-2, out signal_name); 

        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); 

        Squirrel.Obj self; 
        vm.get_stack_object(-3, out self);

        switch(signal_name) {
            case "row-clicked":
                br.row_activated.connect((path, column) => {
                    vm.push_object(callback);
                    vm.push_object(self);
                    vm.push_int(int.parse(path.to_string()));

                    var model = br.get_model() as Gtk.ListStore;
                    Gtk.TreeIter iter;
                    model.get_iter(out iter, path);

                    vm.new_array(0);
                    int n_columns = model.get_n_columns();
                    for(int i = 0; i < n_columns; i++) {
                        var val = GLib.Value(typeof(string));
                        model.get_value(iter, i, out val);

                        vm.push_string(val.get_string());
                        vm.array_append(-2);
                    }

                    run_callback(vm, 3, signal_name);
                });
            break;
            default:
                return vm.throw_error("no such signal: " + signal_name);
        }

        vm.push_string("__callbacks");
        vm.get(1);
        vm.push_object(callback);
        vm.array_append(-2);

        return 0; // no values returned 
    }, 0);
    vm.set_params_check(3, "xsc");
    vm.new_slot(-3, false);

    vm.push_string("add_row");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.TreeView;

        var model = br.get_model() as Gtk.ListStore;
        Gtk.TreeIter iter;
        model.append(out iter);
            

        var sz = vm.get_size(-1);
        int[] columns = new int[sz];
        var text = new GLib.Value[sz];

        for(int i = 0; i < sz; i++) {
            columns[i] = i;

            vm.push_int(i);
            vm.get(-2);
            string s;
            vm.get_string(-1, out s);
            text[i] = GLib.Value(typeof(string));
            text[i].set_string(s);
            vm.pop(1);
        }

        model.set_valuesv(iter, columns, text);

        vm.push_string("__n_rows");
        if(vm.get(1) != Squirrel.OK) {
            vm.pop(1);
            warning("Could not get __n_rows attirubte from ui.Table");
        }
        else {
            long n_rows;
            vm.get_int(-1, out n_rows);
            n_rows++;
            stdout.printf("n rows: %ld\n", n_rows);

            vm.push_string("__n_rows");
            vm.push_int(n_rows);
            vm.set(1);
        }

        return 0;
    }, 0);
    vm.set_params_check(2, "xa");
    vm.new_slot(-3, false);

    vm.push_string("get_row");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.TreeView;

        long row_n;
        vm.get_int(2, out row_n);

        var model = br.get_model() as Gtk.ListStore;
        Gtk.TreeIter iter;
        model.get_iter_from_string(out iter, row_n.to_string());

        vm.new_array(0);
        int n_columns = model.get_n_columns();
        for(int i = 0; i < n_columns; i++) {
            var val = GLib.Value(typeof(string));
            model.get_value(iter, i, out val);

            vm.push_string(val.get_string());
            vm.array_append(-2);
        }

        return 1;
    }, 0);
    vm.set_params_check(2, "xi");
    vm.new_slot(-3, false);

    vm.push_string("get_n_rows");
    vm.new_closure((vm) => {
        vm.push_string("__n_rows");
        vm.get(1);
        return 1;
    }, 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);

    vm.push_string("get_selected_row");
    vm.new_closure((vm) => {
        var br = vm.get_instance(1) as Gtk.TreeView;
        var selection = br.get_selection();
        Gtk.TreeModel model = br.get_model();
        var selected_rows = selection.get_selected_rows(out model);
        if(selected_rows.length() > 0) {
            var path = selected_rows.nth_data(0);
            vm.push_int(int.parse(path.to_string()));
        } else {
            vm.push_null();
        }
        return 1;
    }, 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);


    vm.new_slot(-3, false);
}

}
