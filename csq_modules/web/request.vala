namespace csq
{
    // ---------- shared helpers ----------

    void response_body_to_table (Squirrel.Vm vm, Soup.Message msg, uint8[]? response_data = null) {
        vm.new_table();

        vm.push_string("status_code");
        vm.push_int((long) msg.get_status());
        vm.new_slot(-3, false);

        vm.push_string("uri");
        vm.push_string(msg.get_uri().to_string());
        vm.new_slot(-3, false);

        vm.push_string("method");
        vm.push_string(msg.get_method());
        vm.new_slot(-3, false);

        vm.push_string("body");
        vm.new_table();

        vm.push_string("data");
        if (response_data != null) {
            string s = (string) response_data;
            vm.push_string(s);
        } else {
            vm.push_string("");
        }
        vm.new_slot(-3, false);

        vm.push_string("length");
        vm.push_int((long) (response_data != null ? response_data.length : 0));
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }

    void wake_ok (Squirrel.Vm vm) {
        vm.wake_up(true, true, true, false);
    }

    // Cancel a queued Soup.Message from a thread cancel signal
    void cancel_message (Soup.Session session, Soup.Message msg) {
        // In libsoup3, we cancel by aborting the session operation
        session.abort();
    }

    // Helper to set request body
    void set_request_body(Soup.Message msg, string data) {
        var bytes = new Bytes.take(data.data);
        msg.set_request_body_from_bytes("application/octet-stream", bytes);
    }

    // Helper to read response data from input stream
    async uint8[]? read_response_data(InputStream input_stream) {
        try {
            // Use MemoryOutputStream to collect all data
            var mem_stream = new MemoryOutputStream(null, realloc, free);
            yield mem_stream.splice_async(input_stream, 
                OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
                Priority.DEFAULT, null);
            
            return mem_stream.steal_as_bytes().get_data();
        } catch (Error e) {
            return null;
        }
    }

    // Helper for sync requests
    uint8[]? read_response_data_sync(InputStream input_stream) {
        try {
            var mem_stream = new MemoryOutputStream(null, realloc, free);
            mem_stream.splice(input_stream, 
                OutputStreamSpliceFlags.CLOSE_SOURCE | OutputStreamSpliceFlags.CLOSE_TARGET,
                null);
            
            return mem_stream.steal_as_bytes().get_data();
        } catch (Error e) {
            return null;
        }
    }

    // ---------- public API ----------

    void require(Squirrel.Vm vm) {
        vm.new_table();

        // --- GET (sync) ---
        vm.push_string("get");
        vm.new_closure((vm) => {
            string url; vm.get_string(-1, out url);

            var session = new Soup.Session();
            var message = new Soup.Message("GET", url);
            
            // Sync request in libsoup3
            uint8[] response_data = null;
            try {
                var input_stream = session.send(message, null);
                response_data = read_response_data_sync(input_stream);
            } catch (Error e) {
                
            }

            response_body_to_table(vm, message, response_data);
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

            var thread = vm.get_foreign_pointer() as csq.SquirrelThread;
            var session = new Soup.Session();
            var message = new Soup.Message("GET", url);

            // Tie cancellation: if thread is cancelled, cancel the HTTP request
            ulong cancel_id = thread.cancelled.connect(() => {
                stdout.printf("Cancelling GET %s\n", url);
                cancel_message(session, message);
            });

            // Async request in libsoup3 - using the correct pattern from your example
            session.send_async.begin(message, Priority.DEFAULT, null, (obj, res) => {
                // Clean handler
                if (cancel_id != 0) thread.disconnect(cancel_id);

                try {
                    var input_stream = session.send_async.end(res);
                    // Read response data asynchronously
                    read_response_data.begin(input_stream, (obj2, res2) => {
                        var response_data = read_response_data.end(res2);
                        stdout.printf("Finished async GET %s with status %u\n", url, message.get_status());
                        
                        response_body_to_table(thread.vm, message, response_data);
                        wake_ok(thread.vm);
                    });
                } catch (Error e) {
                    if (!(e is IOError.CANCELLED)) {
                        // Handle other errors
                        stdout.printf("Error in async GET: %s\n", e.message);
                        // Push empty response on error
                        response_body_to_table(thread.vm, message, null);
                        wake_ok(thread.vm);
                    }
                }
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
            set_request_body(message, data);

            // Sync request
            uint8[] response_data = null;
            try {
                var input_stream = session.send(message, null);
                response_data = read_response_data_sync(input_stream);
            } catch (Error e) {
                // Handle error silently
            }

            response_body_to_table(vm, message, response_data);
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
            set_request_body(message, data);

            ulong cancel_id = thread.cancelled.connect(() => {
                cancel_message(session, message);
            });

            session.send_async.begin(message, Priority.DEFAULT, null, (obj, res) => {
                if (cancel_id != 0) thread.disconnect(cancel_id);

                try {
                    var input_stream = session.send_async.end(res);
                    read_response_data.begin(input_stream, (obj2, res2) => {
                        var response_data = read_response_data.end(res2);
                        response_body_to_table(thread.vm, message, response_data);
                        wake_ok(thread.vm);
                    });
                } catch (Error e) {
                    if (!(e is IOError.CANCELLED)) {
                        stdout.printf("Error in async POST: %s\n", e.message);
                        response_body_to_table(thread.vm, message, null);
                        wake_ok(thread.vm);
                    }
                }
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
            set_request_body(message, data);

            uint8[] response_data = null;
            try {
                var input_stream = session.send(message, null);
                response_data = read_response_data_sync(input_stream);
            } catch (Error e) {
                // Handle error
            }

            response_body_to_table(vm, message, response_data);
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
            set_request_body(message, data);

            ulong cancel_id = thread.cancelled.connect(() => {
                cancel_message(session, message);
            });

            session.send_async.begin(message, Priority.DEFAULT, null, (obj, res) => {
                if (cancel_id != 0) thread.disconnect(cancel_id);

                try {
                    var input_stream = session.send_async.end(res);
                    read_response_data.begin(input_stream, (obj2, res2) => {
                        var response_data = read_response_data.end(res2);
                        response_body_to_table(thread.vm, message, response_data);
                        wake_ok(thread.vm);
                    });
                } catch (Error e) {
                    if (!(e is IOError.CANCELLED)) {
                        stdout.printf("Error in async PUT: %s\n", e.message);
                        response_body_to_table(thread.vm, message, null);
                        wake_ok(thread.vm);
                    }
                }
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

            uint8[] response_data = null;
            try {
                var input_stream = session.send(message, null);
                response_data = read_response_data_sync(input_stream);
            } catch (Error e) {
                // Handle error
            }

            response_body_to_table(vm, message, response_data);
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

            session.send_async.begin(message, Priority.DEFAULT, null, (obj, res) => {
                if (cancel_id != 0) thread.disconnect(cancel_id);

                try {
                    var input_stream = session.send_async.end(res);
                    read_response_data.begin(input_stream, (obj2, res2) => {
                        var response_data = read_response_data.end(res2);
                        response_body_to_table(thread.vm, message, response_data);
                        wake_ok(thread.vm);
                    });
                } catch (Error e) {
                    if (!(e is IOError.CANCELLED)) {
                        stdout.printf("Error in async DELETE: %s\n", e.message);
                        response_body_to_table(thread.vm, message, null);
                        wake_ok(thread.vm);
                    }
                }
            });

            return vm.suspend();
        }, 0);
        vm.set_params_check(2, ".s");
        vm.new_slot(-3, false);

    }
}