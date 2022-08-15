
namespace ui
{

private void expose_messagebox(Squirrel.Vm vm)
{
    // push the message type enum
    vm.push_string("MessageType");
    vm.new_table();

    vm.push_string("INFO");
    vm.push_int(Gtk.MessageType.INFO);
    vm.new_slot(-3, true);

    vm.push_string("WARNING");
    vm.push_int(Gtk.MessageType.WARNING);
    vm.new_slot(-3, true);

    vm.push_string("QUESTION");
    vm.push_int(Gtk.MessageType.QUESTION);
    vm.new_slot(-3, true);

    vm.push_string("ERROR");
    vm.push_int(Gtk.MessageType.ERROR);
    vm.new_slot(-3, true);

    vm.push_string("OTHER");
    vm.push_int(Gtk.MessageType.OTHER);
    vm.new_slot(-3, true);
    vm.new_slot(-3, true);


    vm.push_string("MessageBox");
    vm.new_class(false);

    vm.push_string("constructor");
    vm.new_closure((vm) => {
        var parent = vm.get_instance(2) as Gtk.Window;

        long message_type;
        vm.get_int(3, out message_type);

        var br = new Gtk.MessageDialog(
                parent, 
                Gtk.DialogFlags.DESTROY_WITH_PARENT, 
                (Gtk.MessageType)message_type, 
                Gtk.ButtonsType.NONE, 
                "");
        
        vm.set_instance_up(1, br);
        br.ref();

        vm.set_release_hook(-1, (ptr, sz) => {
            var m = ptr as Gtk.MessageDialog;
            m.unref();
            return 0; 
        });
        return 1;
    }, 0);
    vm.set_params_check(3, "xxi");
    vm.new_slot(-3, false);

    vm.push_string("set_text");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MessageDialog;
        string text = "";
        vm.get_string(2, out text);
        m.text = text;
        return 0;
    }, 0);
    vm.set_params_check(2, "xs");
    vm.new_slot(-3, false);

    vm.push_string("set_secondary_text");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MessageDialog;
        string text = "";
        vm.get_string(2, out text);
        m.secondary_text = text;
        return 0;
    } , 0);
    vm.set_params_check(2, "xs");
    vm.new_slot(-3, false);

    vm.push_string("add_response");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MessageDialog;
        string text;
        vm.get_string(2, out text);
        long response;
        vm.get_int(3, out response);
        m.add_button(text, (int)response);
        return 0;
    } , 0);
    vm.set_params_check(3, "xsi");
    vm.new_slot(-3, false);

    vm.push_string("run");
    vm.new_closure((vm) => {
        var m = vm.get_instance(1) as Gtk.MessageDialog;
        m.show_all();
        int response = m.run();
        m.destroy();
        vm.push_int(response);
        return 1;
    } , 0);
    vm.set_params_check(1, "x");
    vm.new_slot(-3, false);

    vm.new_slot(-3, false);
}



}