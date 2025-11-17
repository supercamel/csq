namespace web
{
    // ---------- shared helpers ----------

    void response_body_to_table (Squirrel.Vm vm, Soup.Message msg)
    {
        vm.new_table();

        vm.push_string("status_code");
        vm.push_int((long) msg.status_code);
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
        string s = "%s".printf((string) msg.response_body.data);
        vm.push_string(s);
        vm.new_slot(-3, false);

        vm.push_string("length");
        vm.push_int((long) msg.response_body.length);
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }

    void wake_ok (Squirrel.Vm vm)
    {
        vm.wake_up(true, true, true, false);
    }

    // Cancel a queued Soup.Message from a thread cancel signal
    void cancel_message (Soup.Session session, Soup.Message msg)
    {
        // Soup 2.4 / 3.x compatible: cancel queued message with a "cancelled" status
        session.cancel_message(msg, Soup.Status.CANCELLED);
    }

    // ---------- public API ----------

    void init (Squirrel.Vm vm)
    {
        vm.push_string("web");
        vm.new_table();

        // --- GET (sync) ---
        vm.push_string("get");
        vm.new_closure((vm) => {
            string url; vm.get_string(-1, out url);

            var session = new Soup.Session();
            var message = new Soup.Message("GET", url);
            session.send_message(message);

            response_body_to_table(vm, message);
            return 1;
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        // --- GET (async) ---
        vm.push_string("get_async");
        vm.new_closure((vm) => {
            if (!check_async_registration(vm))
                return vm.throw_error("Async thread is not registered. Use async_run.");

            string url; vm.get_string(-1, out url);

            stdout.printf("Starting async GET %s\n", url);

            var thread = vm.get_foreign_pointer() as SquirrelThread;
            var session = new Soup.Session();
            var message = new Soup.Message("GET", url);

            // Tie cancellation: if thread is cancelled, cancel the HTTP request and wake throwing
            ulong cancel_id = thread.cancelled.connect(() => {
                stdout.printf("Cancelling GET %s\n", url);
                cancel_message(session, message);
            });

            session.queue_message(message, (sess, mess) => {
                // Clean handler
                if (cancel_id != 0) thread.disconnect(cancel_id);

                stdout.printf("Finished async GET %s with status %u\n", url, mess.status_code);
                if (mess.status_code == (uint) Soup.Status.CANCELLED) {
                    return;
                }

                response_body_to_table(thread.vm, mess);
                wake_ok(thread.vm);
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        // --- POST (sync) ---
        vm.push_string("post");
        vm.new_closure((vm) => {
            string url;  vm.get_string(-2, out url);
            string data; vm.get_string(-1, out data);

            var session = new Soup.Session();
            var message = new Soup.Message("POST", url);
            message.request_body.append_take((uint8[]) data.to_utf8());

            session.send_message(message);
            response_body_to_table(vm, message);
            return 1;
        }, 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);

        // --- POST (async) ---
        vm.push_string("post_async");
        vm.new_closure((vm) => {
            if (!check_async_registration(vm))
                return vm.throw_error("Async thread is not registered. Use async_run.");

            string url;  vm.get_string(-2, out url);
            string data; vm.get_string(-1, out data);

            var thread  = vm.get_foreign_pointer() as SquirrelThread;
            var session = new Soup.Session();
            var message = new Soup.Message("POST", url);
            message.request_body.append_take((uint8[]) data.to_utf8());

            ulong cancel_id = thread.cancelled.connect(() => {
                cancel_message(session, message);
            });

            session.queue_message(message, (sess, mess) => {
                if (cancel_id != 0) thread.disconnect(cancel_id);

                if (mess.status_code == (uint) Soup.Status.CANCELLED) {
                    return;
                }

                response_body_to_table(thread.vm, mess);
                wake_ok(thread.vm);
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);

        // --- PUT (sync) ---
        vm.push_string("put");
        vm.new_closure((vm) => {
            string url;  vm.get_string(-2, out url);
            string data; vm.get_string(-1, out data);

            var session = new Soup.Session();
            var message = new Soup.Message("PUT", url);
            message.request_body.append_take((uint8[]) data.to_utf8());

            session.send_message(message);
            response_body_to_table(vm, message);
            return 1;
        }, 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);

        // --- PUT (async) ---
        vm.push_string("put_async");
        vm.new_closure((vm) => {
            if (!check_async_registration(vm))
                return vm.throw_error("Async thread is not registered. Use async_run.");

            string url;  vm.get_string(-2, out url);
            string data; vm.get_string(-1, out data);

            var thread  = vm.get_foreign_pointer() as SquirrelThread;
            var session = new Soup.Session();
            var message = new Soup.Message("PUT", url);
            message.request_body.append_take((uint8[]) data.to_utf8());

            ulong cancel_id = thread.cancelled.connect(() => {
                cancel_message(session, message);
            });

            session.queue_message(message, (sess, mess) => {
                if (cancel_id != 0) thread.disconnect(cancel_id);

                if (mess.status_code == (uint) Soup.Status.CANCELLED) {
                    return;
                }

                response_body_to_table(thread.vm, mess);
                wake_ok(thread.vm);
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(3, ".ss");
        vm.new_slot(-3, false);

        // --- DELETE (sync) ---
        vm.push_string("delete");
        vm.new_closure((vm) => {
            string url; vm.get_string(-1, out url);

            var session = new Soup.Session();
            var message = new Soup.Message("DELETE", url);

            session.send_message(message);
            response_body_to_table(vm, message);
            return 1;
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        // --- DELETE (async) ---
        vm.push_string("delete_async");
        vm.new_closure((vm) => {
            if (!check_async_registration(vm))
                return vm.throw_error("Async thread is not registered. Use async_run.");

            string url; vm.get_string(-1, out url);

            var thread  = vm.get_foreign_pointer() as SquirrelThread;
            var session = new Soup.Session();
            var message = new Soup.Message("DELETE", url);

            ulong cancel_id = thread.cancelled.connect(() => {
                cancel_message(session, message);
            });

            session.queue_message(message, (sess, mess) => {
                if (cancel_id != 0) thread.disconnect(cancel_id);

                if (mess.status_code == (uint) Soup.Status.CANCELLED) {
                    return;
                }

                response_body_to_table(thread.vm, mess);
                wake_ok(thread.vm);
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false); // add web to root
    }
}
