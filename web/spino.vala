
namespace web
{
    void expose_cursor(Squirrel.Vm vm)
    {
        vm.push_string("Cursor");
        vm.new_class(false);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            void* up;
            vm.get_user_pointer(-1, out up);
            vm.set_instance_up(1, up);

            vm.set_release_hook(1, (ptr, sz) => {
                var cc = ptr as Spino.Cursor;
                cc.unref();
                return 0;
            });

            return 1;
        }, 0);
        vm.set_params_check(2, ".p");
        vm.new_slot(-3, false);

        vm.push_string("has_next");
        vm.new_closure((vm) => {
            var cur = vm.get_instance(1) as Spino.Cursor;
            vm.push_bool(cur.has_next());
            return 1;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("next");
        vm.new_closure((vm) => {
            var cur = vm.get_instance(1) as Spino.Cursor;
            vm.push_string(cur.next());
            return 1;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("count");
        vm.new_closure((vm) => {
            var cur = vm.get_instance(1) as Spino.Cursor;
            vm.push_int(cur.count());
            return 1;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("set_limit");
        vm.new_closure((vm) => {
            var cur = vm.get_instance(1) as Spino.Cursor;
            long limit;
            vm.get_int(-1, out limit);
            cur.set_limit((uint)limit);
            vm.pop(1);
            return 1;
        }, 0);
        vm.set_params_check(2, "xi");
        vm.new_slot(-3, false);

        vm.push_string("set_projection");
        vm.new_closure((vm) => {
            var cur = vm.get_instance(1) as Spino.Cursor;
            string proj;
            vm.get_string(-1, out proj);
            cur.set_projection(proj);
            vm.pop(1);
            return 1;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }


    void expose_collection(Squirrel.Vm vm)
    {
        vm.push_string("Collection");
        vm.new_class(false);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            void* up;
            vm.get_user_pointer(-1, out up);
            vm.set_instance_up(1, up);

            vm.set_release_hook(1, (ptr, sz) => {
                var cc = ptr as Spino.Collection;
                cc.unref();
                return 0;
            });

            return 1;
        }, 0);
        vm.set_params_check(2, ".p");
        vm.new_slot(-3, false);


        vm.push_string("get_name");
        vm.new_closure((vm) => {
            var c = vm.get_instance(1) as Spino.Collection;
            vm.push_string(c.get_name());
            return 1;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("create_index");
        vm.new_closure((vm) => {
            var c = vm.get_instance(1) as Spino.Collection;

            string idx;
            vm.get_string(-1, out idx);

            c.create_index(idx);
            return 0;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("drop_index");
        vm.new_closure((vm) => {
            var c = vm.get_instance(1) as Spino.Collection;

            string idx;
            vm.get_string(-1, out idx);

            c.drop_index(idx);
            return 0;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("append");
        vm.new_closure((vm) => {
            var c = vm.get_instance(1) as Spino.Collection;

            if(vm.get_object_type(-1) == Squirrel.OBJECTTYPE.TABLE) {
                vm.push_root_table();
                vm.push_string("json");
                vm.get(-2);
                vm.push_string("stringify");
                vm.get(-2);

                Squirrel.Obj foo;
                vm.get_stack_object(-1, out foo);
                vm.add_ref(foo);

                vm.pop(3);

                Squirrel.Obj tbl;
                vm.get_stack_object(2, out tbl);

                vm.push_object(foo);
                vm.push_root_table();
                vm.push_object(tbl);

                vm.call(2, true, true);
            }

            string json;
            vm.get_string(-1, out json);
            c.append(json);
            return 1;
        }, 0);
        vm.set_params_check(2, "xs|t");
        vm.new_slot(-3, false);

        vm.push_string("update");
        vm.new_closure((vm) => {
            var c = vm.get_instance(1) as Spino.Collection;

            string query;
            string doc;

            vm.get_string(-2, out query);

            if(vm.get_object_type(-1) == Squirrel.OBJECTTYPE.TABLE) {
                vm.push_root_table();
                vm.push_string("json");
                vm.get(-2);
                vm.push_string("stringify");
                vm.get(-2);

                Squirrel.Obj foo;
                vm.get_stack_object(-1, out foo);
                vm.add_ref(foo);

                vm.pop(3);

                Squirrel.Obj tbl;
                vm.get_stack_object(-1, out tbl);

                vm.push_object(foo);
                vm.push_root_table();
                vm.push_object(tbl);

                vm.call(2, true, true);
            }
            vm.get_string(-1, out doc);

            c.update(query, doc);
            return 0;
        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("find_one");
        vm.new_closure((vm) => {
            var c = vm.get_instance(1) as Spino.Collection;

            string query;
            vm.get_string(-1, out query);

            vm.push_string(c.find_one(query));
            return 1;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("find");
        vm.new_closure((vm) => {
            var col = vm.get_instance(1) as Spino.Collection;

            string query;
            vm.get_string(-1, out query);
            var cursor = col.find(query);
            cursor.ref();

            vm.push_root_table();
            vm.push_string("web");
            vm.get(-2);

            vm.push_string("Cursor");
            vm.get(-2);

            vm.push_null();
            vm.push_user_pointer(cursor);
            vm.call(2, true, true);
            return 1;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("drop_one");
        vm.new_closure((vm) => {
            var col = vm.get_instance(1) as Spino.Collection;
            string query;
            vm.get_string(-1, out query);
            col.drop_one(query);
            return 0;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("drop");
        vm.new_closure((vm) => {
            var col = vm.get_instance(1) as Spino.Collection;
            string query;
            vm.get_string(-1, out query);
            uint n = col.drop(query, uint32.MAX);
            vm.push_int((long)n);
            return 1;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("drop_older_than");
        vm.new_closure((vm) => {
            var col = vm.get_instance(1) as Spino.Collection;
            long timestamp;
            vm.get_int(-1, out timestamp);

            col.drop_older_than(timestamp);
            return 0;
        }, 0);
        vm.set_params_check(2, "xi");
        vm.new_slot(-3, false);

        vm.push_string("size");
        vm.new_closure((vm) => {
            var col = vm.get_instance(1) as Spino.Collection;
            vm.push_int(col.get_size());
            return 1;
        }, 0);
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }

    void expose_spino(Squirrel.Vm vm)
    {
        vm.push_string("Spino");
        vm.new_class(false);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            var br = new Spino.Database();
            vm.set_instance_up(1, br);
            br.ref();

            vm.set_release_hook(-1, (ptr, sz) => {
                var m = ptr as Spino.Database;
                m.unref();
                return 0; 
            });
            return 1;

        }, 0);
        vm.new_slot(-3, false);

        vm.push_string("get_collection");
        vm.new_closure((vm) => {
            var sp =vm.get_instance(1) as Spino.Database;

            string col_name;
            vm.get_string(-1, out col_name);

            var collection = sp.get_collection(col_name);
            collection.ref();

            vm.push_root_table();
            vm.push_string("web");
            vm.get(-2);

            vm.push_string("Collection");
            vm.get(-2);

            vm.push_null();
            vm.push_user_pointer(collection);
            vm.call(2, true, true);
            return 1;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("save");
        vm.new_closure((vm) => {
            var sp = vm.get_instance(1) as Spino.Database;

            string path;
            vm.get_string(-1, out path);
            sp.save(path);
            return 0;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("load");
        vm.new_closure((vm) => {
            var sp = vm.get_instance(1) as Spino.Database;

            string path;
            vm.get_string(-1, out path);
            sp.load(path);
            return 0;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("enable_journal");
        vm.new_closure((vm) => {
            var sp = vm.get_instance(1) as Spino.Database;
            string path;
            vm.get_string(-1, out path);
            sp.enable_journal(path);
            return 0;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);

        vm.push_string("consolidate");
        vm.new_closure((vm) => {
            var sp = vm.get_instance(1) as Spino.Database;
            string path;
            vm.get_string(-1, out path);
            sp.consolidate(path);
            return 0;
        }, 0);
        vm.set_params_check(2, "xs");
        vm.new_slot(-3, false);


        vm.new_slot(-3, false);


        expose_collection(vm);
        expose_cursor(vm);
    }

}


