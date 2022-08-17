
namespace web
{

    void init(Squirrel.Vm vm)
    {
        vm.push_string("web");
        vm.new_table();

        vm.push_string("request");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-1, out url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            session.send_message (message);

            string s = "%s".printf((string)message.response_body.data);
            vm.push_string(s);
            return 1;
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        vm.push_string("request_thread");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-1, out url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            var scr = new SuspendedCoroutineGuard(0);
            vm.set_foreign_pointer(scr);
            scr.ref();

            session.queue_message (message, (sess, mess) => {
                vm.set_vm_release_hook((ptr, sz) => {
                    return Squirrel.OK;
                });

                if(scr.wakeup_handle == 1) {
                    return;
                }

                string s = "%s".printf((string)message.response_body.data);
                vm.push_string(s);

                thread_queue.append(vm);
                GLib.Idle.add(wake_up_threads);
            });

            release_foreign_pointer(vm);
            
            vm.set_vm_release_hook((ptr, sz) => {
                var sus = ptr as SuspendedCoroutineGuard;
                sus.wakeup_handle = 1;
                sus.unref();
                return Squirrel.OK;
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }


}


