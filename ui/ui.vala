
namespace ui 
{

void init(Squirrel.Vm vm)
{
    vm.push_root_table();

    vm.push_string("ui");
    vm.new_table();

    expose_window(vm);
    expose_box(vm);
    expose_label(vm);
    expose_button(vm);
    expose_entry(vm);
    expose_treeview(vm);
    expose_messagebox(vm);
    expose_menu(vm);
    expose_main(vm);
    expose_cairo_context(vm);
    expose_drawing_area(vm);
    expose_file_chooser(vm);

    vm.new_slot(-3, false);
    vm.pop(1);
}

}

