
namespace web
{

    void response_body_to_table(Squirrel.Vm vm, Soup.Message msg)
    {
        vm.new_table();
        vm.push_string("status_code");
        vm.push_int(msg.status_code);
        vm.new_slot(-3, false);

        vm.push_string("uri");
        vm.push_string(msg.uri.to_string(false));
        vm.new_slot(-3, false);

        vm.push_string("method");
        vm.push_string(msg.method);
        vm.new_slot(-3, false);

        vm.push_string("body");
        vm.new_table();
        vm.push_string("data");
        string s = "%s".printf((string)msg.response_body.data);
        vm.push_string(s);
        vm.new_slot(-3, false);

        vm.push_string("length");
        vm.push_int((long)msg.response_body.length);
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }

    void init(Squirrel.Vm vm)
    {
        vm.push_string("web");
        vm.new_table();

        vm.push_string("get");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-1, out url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            session.send_message (message);
            response_body_to_table(vm, message);
            return 1;
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        vm.push_string("get_async");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-1, out url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            var scr = new SuspendedCoroutineGuard(vm);
            session.queue_message (message, (sess, mess) => {
                if(scr.wake_up()) {
                    response_body_to_table(vm, message);
                }
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(2, ".ss");
        vm.new_slot(-3, false);

        vm.push_string("post");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-2, out url);
            string data;
            vm.get_string(-1, out data);

            var session = new Soup.Session ();
            var message = new Soup.Message ("POST", url);
            message.request_body.append_take((uint8[])data.to_utf8());
            session.send_message (message);

            response_body_to_table(vm, message);
            return 1;
        }, 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);

        vm.push_string("post_async");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-2, out url);
            string data;
            vm.get_string(-1, out data);

            var session = new Soup.Session ();
            var message = new Soup.Message ("POST", url);
            message.request_body.append_take((uint8[])data.to_utf8());
            var scr = new SuspendedCoroutineGuard(vm);
            session.queue_message (message, (sess, mess) => {
                if(scr.wake_up()) {
                    response_body_to_table(vm, message);
                }
            });
            return vm.suspend();
        }, 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);

        vm.push_string("put");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-2, out url);
            string data;
            vm.get_string(-1, out data);

            var session = new Soup.Session ();
            var message = new Soup.Message ("PUT", url);
            message.request_body.append_take((uint8[])data.to_utf8());
            session.send_message (message);

            response_body_to_table(vm, message);
            return 1;
        } , 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);


        vm.push_string("put_async");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-2, out url);
            string data;
            vm.get_string(-1, out data);

            var session = new Soup.Session ();
            var message = new Soup.Message ("PUT", url);
            message.request_body.append_take((uint8[])data.to_utf8());
            var scr = new SuspendedCoroutineGuard(vm);
            session.queue_message (message, (sess, mess) => {
                if(scr.wake_up()) {
                    response_body_to_table(vm, message);
                }
            });
            return vm.suspend();
        } , 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);


        vm.push_string("delete");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-1, out url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("DELETE", url);
            session.send_message (message);

            response_body_to_table(vm, message);
            return 1;
        } , 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        vm.push_string("delete_async");
        vm.new_closure((vm) => {
            string url;
            vm.get_string(-1, out url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("DELETE", url);
            var scr = new SuspendedCoroutineGuard(vm);
            session.queue_message (message, (sess, mess) => {
                if(scr.wake_up()) {
                    response_body_to_table(vm, message);
                }
            });
            return vm.suspend();
        } , 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }


}


