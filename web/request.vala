
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

        vm.push_string("Server");
        vm.new_class(false);

        expose_object_base(vm);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            var br = new Soup.Server(null);
            vm.set_instance_up(1, br);
            br.ref();

            vm.set_release_hook(-1, (ptr, sz) => {
                var m = ptr as Soup.Server;
                m.unref();
                return 0; 
            });
            return 1;
        }, 0);
        vm.new_slot(-3, false); // add constructor to server

        vm.push_string("add_handler");
        vm.new_closure((vm) => {
            var br = vm.get_instance(1) as Soup.Server;

            string endpoint;
            vm.get_string(-2, out endpoint); 

            Squirrel.Obj callback;
            vm.get_stack_object(-1, out callback); //get the callback closure as a Squirrel Object

            Squirrel.Obj self; // keep a copy of the class instance
            vm.get_stack_object(-3, out self);

            if(endpoint == "*" || endpoint == "") {
                endpoint = null;
            }

            br.add_handler(endpoint, (server, msg, path, query, client) => {
                vm.push_object(callback);
                vm.push_object(self);

                vm.new_table();
                vm.push_string("uri");
                vm.push_string(msg.uri.to_string(false));
                vm.new_slot(-3, false);

                vm.push_string("method");
                vm.push_string(msg.method);
                vm.new_slot(-3, false);

                vm.push_string("body");
                vm.new_table();
                vm.push_string("data");
                string s = "%s".printf((string)msg.request_body.data);
                vm.push_string(s);
                vm.new_slot(-3, false);

                vm.push_string("length");
                vm.push_int((long)msg.request_body.length);
                vm.new_slot(-3, false);
                vm.new_slot(-3, false);


                vm.new_table();
                if(query != null) {
                    query.foreach((key, val) => {
                        vm.push_string(key);
                        vm.push_string(val);
                        vm.new_slot(-3, false);
                    });
                }

                if(vm.call(3, true, false) != Squirrel.OK) {
                    string m = "";
                    vm.get_last_error();
                    vm.get_string(-1, out m);
                    warning("Error in server handler %s: %s", path, m);
                }
                else {
                    string type = "text/html";
                    string content = "";
                    long status_code = 200;

                    vm.push_string("type");
                    if(vm.get(-2) == Squirrel.OK) {
                        vm.get_string(-1, out type);
                    }
                    vm.pop(1);

                    vm.push_string("content");
                    if(vm.get(-2) == Squirrel.OK) {
                        vm.get_string(-1, out content);
                    }
                    vm.pop(1);

                    vm.push_string("status_code");
                    if(vm.get(-2) == Squirrel.OK) {
                        vm.get_int(-1, out status_code);
                    }
                    vm.pop(1);

                    msg.set_response (type, Soup.MemoryUse.COPY, content.data);
                    msg.status_code = (uint)status_code;
                }
            });

            vm.push_string("__callbacks");
            vm.get(1);
            vm.push_object(callback);
            vm.array_append(-2);

            return 0;

        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("listen");
        vm.new_closure((vm) => {
            var br = vm.get_instance(1) as Soup.Server;

            long port;
            vm.get_int(-1, out port);

            br.listen_all((uint)port, 0);
            return 0;
        }, 0);
        vm.set_params_check(2, "xi");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false); //add Server to Web

        expose_spino(vm);

        vm.new_slot(-3, false); // add web to root table
    }


}


