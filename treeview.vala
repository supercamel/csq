
class TableWrap : Gtk.TreeView
{
    public TableWrap(Squirrel.Vm v)
    {
        vm = v;
        n_rows = 0;
    }

    ~TableWrap() {
        for(int i = 0; i < callbacks.length(); i++) {
            Squirrel.Obj o = callbacks.nth_data(i);
            vm.release(o);
        }
    }        

    public int n_rows;
    public SList<Squirrel.Obj> callbacks;
    private Squirrel.Vm vm;
}

public void csq_wrap_gtk_treeview(Squirrel.Vm vm)
{
    vm.push_string("Table");
    vm.new_class(false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        TableWrap br = new TableWrap(vm);
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
            TableWrap m = ptr as TableWrap;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("connect");
    vm.new_closure((vm) => {
        TableWrap br = vm.get_instance(1) as TableWrap;

        string signal_name;
        vm.get_string(-2, out signal_name); // signal name is passed as the 'second last' parameter

        Squirrel.Obj callback;
        vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object
        vm.add_ref(callback); // reference it so the VM doesn't destroy it as it goes out of scope

        br.callbacks.append(callback); // add to the list of callbacks - so it can be unreferenced later

        Squirrel.Obj self; // keep a copy of the class instance
        vm.get_stack_object(-3, out self);

        switch(signal_name) {
            case "row-clicked":
                br.row_activated.connect((path, column) => {
                    /* 
                    vm.push_object(callback);
                    vm.push_object(self);
                    vm.push_string(preedit);
                    vm.call(2, true, true);
                    */
                });
            break;
            default:
                return vm.throw_error("no such signal: " + signal_name);
        }

        return 0; // no values returned 
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("add_row");
    vm.new_closure((vm) => {
        TableWrap br = vm.get_instance(1) as TableWrap;

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

        br.n_rows++;

        return 0;
    }, 0);
    vm.new_slot(-3, false);

    vm.push_string("get_row");
    vm.new_closure((vm) => {
        TableWrap br = vm.get_instance(1) as TableWrap;

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
    vm.new_slot(-3, false);

    vm.push_string("get_n_rows");
    vm.new_closure((vm) => {
        TableWrap br = vm.get_instance(1) as TableWrap;
        vm.push_int(br.n_rows);
        return 1;
    }, 0);
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}