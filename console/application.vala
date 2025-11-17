
namespace console
{
    public class ConsoleApplication : Application {
        public ConsoleApplication(Squirrel.Vm vm, string id, string title) {
            Object(application_id: id, flags: ApplicationFlags.HANDLES_COMMAND_LINE);
            this.vm = vm;
            this.title = title;
        }

        public override int command_line(ApplicationCommandLine command_line) {
            print("command line called");
            this.hold();
            // load the command_line function
            Squirrel.Obj self;
            vm.get_stack_object(1, out self);

            vm.push_string("command_line");
            vm.get(-1);

            Squirrel.Obj callback;
            vm.get_stack_object(-1, out callback);
            vm.push_object(callback);
            vm.push_object(self);
            vm.call(0, true, false);
        
            this.release();
            return 0;
        }

        private Squirrel.Vm vm;
        private string title = "";
    }

    void expose_application(Squirrel.Vm vm)
    {
        vm.push_string("OptionArg");
        vm.new_table();
        vm.push_string("INT");
        vm.push_int(GLib.OptionArg.INT);
        vm.new_slot(-3, true);
        vm.push_string("STRING");
        vm.push_int(GLib.OptionArg.STRING);
        vm.new_slot(-3, true);
        vm.push_string("FILENAME");
        vm.push_int(GLib.OptionArg.FILENAME);
        vm.new_slot(-3, true);
        vm.push_string("FLOAT");
        vm.push_int(GLib.OptionArg.DOUBLE); // Note: squirrel uses float, so this is down cast
        vm.new_slot(-3, true);
        vm.push_string("NONE");
        vm.push_int(GLib.OptionArg.NONE);
        vm.new_slot(-3, true);

        vm.new_slot(-3, false); // add the table to the vm

        vm.push_string("ConsoleApplication");
        vm.new_class(false);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            var top = vm.get_top();
            if(top != 5) {
                vm.throw_error("InvalidArgumentCount");
                return -1;
            }

            string id;
            string title;
            string description;
            string version;
            vm.get_string(2, out id);
            vm.get_string(3, out title);
            vm.get_string(4, out description);
            vm.get_string(5, out version);

            
            var wr = new ConsoleApplication(vm, id, title);
            vm.set_instance_up(1, wr);
            wr.ref();

            vm.set_release_hook(-1, (ptr, sz) => {
                var m = ptr as ConsoleApplication;
                m.unref();
                return 0; 
            });
            return 1;
        }, 0);
        vm.new_slot(-3, false); // add the constructor to the class

        vm.push_string("hold");
        vm.new_closure((vm) => {
            var app = vm.get_instance(1) as ConsoleApplication;
            app.hold();
            return 0;
        }, 0);
        vm.new_slot(-3, false); // add the function to the class

        vm.push_string("release");
        vm.new_closure((vm) => {
            var app = vm.get_instance(1) as ConsoleApplication;
            app.release();
            return 0;
        }, 0);
        vm.new_slot(-3, false); // add the function to the class


        vm.push_string("run");
        vm.new_closure((vm) => {
            var app = vm.get_instance(1) as ConsoleApplication;
            int res = app.run();
            vm.push_int(res);
            return 1;
        }, 0);
        vm.new_slot(-3, false); // add the function to the class

        vm.new_slot(-3, false); // add the class to the vm

        vm.push_string("console");
        vm.new_table();

        vm.push_string("read_line");;
        vm.new_closure((vm) => {
            string line = stdin.read_line();
            vm.push_string(line);
            return 1;
        }, 0);
        vm.new_slot(-3, false); // add the function to the table

        vm.push_string("get_char");
        vm.new_closure((vm) => {
            int c = stdin.getc();
            vm.push_int(c);
            return 1;
        }, 0);
        vm.new_slot(-3, false); // add the function to the table

        vm.new_slot(-3, false); // add the table to the vm
    }
}