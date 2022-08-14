
public static int main(string[] argv) {
    Gtk.init(ref argv);

    var vm = new Squirrel.Vm(1024);

    vm.on_print.connect((vm, str) => {
        print(str);
    });

    vm.push_root_table();
    csq_wrap_gtk_window(vm);
    csq_wrap_gtk_box(vm);
    csq_wrap_gtk_label(vm);
    csq_wrap_gtk_button(vm);
    csq_wrap_gtk_entry(vm);
    csq_wrap_gtk_treeview(vm);
    csq_wrap_gtk_main(vm);
    csq_wrap_module(vm);

    stdout.printf("%s\n", argv[1]);

    if(argv.length > 1) {
        vm.do_file(argv[1], false, true);
    }
    else {
        stdout.printf("usage: csq [file]\n");
    }

    return 0;
}

