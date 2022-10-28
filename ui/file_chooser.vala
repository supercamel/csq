using Gtk;

namespace ui {
    void expose_file_chooser(Squirrel.Vm vm) {
        vm.push_string("FileChooserAction");
        vm.new_table();
        vm.push_string("OPEN");
        vm.push_int(0);
        vm.new_slot(-3, false);

        vm.push_string("SAVE");
        vm.push_int(1);
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);


        vm.push_string("FileChooser");
        vm.new_class(false);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            Gtk.FileChooserAction a;
            long action;
            string title;
            Gtk.Window parent;

            vm.get_string(2, out title);
            parent = vm.get_instance(3) as Gtk.Window;
            vm.get_int(4, out action);
            string first_action;

            if(action == 0) {
                first_action = "Open";
                a = FileChooserAction.OPEN;
            }
            else {
                first_action = "Save";
                a = FileChooserAction.SAVE;
            }

            
            var wr = new Gtk.FileChooserNative(title, parent, a, first_action, "Cancel");
            vm.set_instance_up(1, wr);
            wr.ref();

            vm.set_release_hook(-1, (ptr, sz) => {
                var m = ptr as Gtk.FileChooserNative;
                m.unref();
                return 0; 
            });
            return 1;
        }, 0);
        vm.set_params_check(4, "xsxi");
        vm.new_slot(-3, false); // add the constructor to the class

        vm.push_string("run");
        vm.new_closure((vm) => {
            Gtk.FileChooserNative f = vm.get_instance(1) as Gtk.FileChooserNative;
            var res = f.run();
            if(res == Gtk.ResponseType.ACCEPT) {
                vm.push_bool(true);
            }
            else {
                vm.push_bool(false);
            }
            return 1;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false); // add the run method to the class

        vm.push_string("get_filename");
        vm.new_closure((vm) => {
            Gtk.FileChooserNative f = vm.get_instance(1) as Gtk.FileChooserNative;
            var res = f.get_filename();
            vm.push_string(res);
            return 1;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false); // add the get_filename method to the class

        vm.push_string("set_filter");
        vm.new_closure((vm) => {
            Gtk.FileChooserNative f = vm.get_instance(1) as Gtk.FileChooserNative;
            Gtk.FileFilter filter = new Gtk.FileFilter();
            string filter_string = "";
            vm.get_string(2, out filter_string);
            filter.add_pattern(filter_string);
            filter.set_filter_name(filter_string);
            f.add_filter(filter);
            return 0;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false); // add the set_filter method to the class

        vm.push_string("destroy");
        vm.new_closure((vm) => {
            Gtk.FileChooserNative f = vm.get_instance(1) as Gtk.FileChooserNative;
            f.destroy();
            return 0;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }
}
