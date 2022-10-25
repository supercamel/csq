using Gtk;

namespace ui 
{
    void expose_cairo_context(Squirrel.Vm vm) {
        vm.push_string("Context");
        vm.new_class(false);

        vm.push_string("constructor");
        vm.new_closure((vm) => {
            void* ptr;
            vm.get_user_pointer(2, out ptr);
            vm.set_instance_up(1, ptr);
            vm.pop(1);

            vm.set_release_hook(-1, (ptr, sz) => {
                return 0; 
            });
            return 1;
        }, 0);
        vm.set_params_check(2, "xp");
        vm.new_slot(-3, false);

        vm.push_string("rectangle");
        vm.new_closure((vm) => {
            Cairo.Context* cr = vm.get_instance(1);

            long x, y, width, height;
            vm.get_int(2, out x);
            vm.get_int(3, out y);
            vm.get_int(4, out width);
            vm.get_int(5, out height);

            cr->rectangle((int)x, (int)y, (int)width, (int)height);
            return 0;
        }, 0);
        vm.set_params_check(5, "xiiii");
        vm.new_slot(-3, false);

        vm.push_string("move_to");
        vm.new_closure((vm) => {
            Cairo.Context* cr = vm.get_instance(1);
            long x, y;
            vm.get_int(2, out x);
            vm.get_int(3, out y);
            cr->move_to((int)x, (int)y);
            return 0;
        }, 0);
        vm.set_params_check(3, "xii");
        vm.new_slot(-3, false);

        vm.push_string("line_to");
        vm.new_closure((vm) => {
            Cairo.Context* cr = vm.get_instance(1);
            long x, y;
            vm.get_int(2, out x);
            vm.get_int(3, out y);
            cr->line_to((int)x, (int)y);
            return 0;
        }, 0);
        vm.set_params_check(3, "xii");
        vm.new_slot(-3, false);

        vm.push_string("stroke");
        vm.new_closure((vm) => {
            Cairo.Context* cr = vm.get_instance(1);
        stdout.flush();

            cr->stroke();
            return 0;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false);

        vm.push_string("fill");
        vm.new_closure((vm) => {
            Cairo.Context* cr = vm.get_instance(1);
            cr->fill();
            return 0;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false);

        vm.push_string("set_source_rgb");
        vm.new_closure((vm) => {
            var cr = (Cairo.Context*)vm.get_instance(1);
            double r, g, b;
            vm.get_float(2, out r);
            vm.get_float(3, out g);
            vm.get_float(4, out b);
            cr->set_source_rgb((double)r,(double) g,(double) b);
            return 0;
        }, 0);
        vm.set_params_check(4, "xnnn");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }

    void instantiate_cairo_context(Squirrel.Vm vm, void* cr) {
        var top = vm.get_top();

        vm.push_root_table();
        vm.push_string("ui");
        vm.get(-2);
        vm.push_string("Context");
        vm.get(-2);
        vm.push_string("constructor");
        vm.get(-2);

        vm.create_instance(-2);
        vm.push_user_pointer(cr);
        vm.call(2, true, false);


        Squirrel.Obj o;
        vm.get_stack_object(-1, out o);
        vm.add_ref(o);
        vm.set_top(top);
        vm.push_object(o);
        vm.release(o);
    }

    void expose_drawing_area(Squirrel.Vm vm) {
        vm.push_string("DrawingArea");
        vm.new_class(false);

        expose_widget_base(vm);
        vm.push_string("constructor");
        vm.new_closure((vm) => {
            var da = new DrawingArea();
            da.ref();
            vm.set_instance_up(1, da);

            vm.set_release_hook(-1, (ptr, sz) => {
                var m = ptr as DrawingArea;
                m.unref();
                return 0; 
            });
            return 1;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false);

        vm.push_string("_draw_cb");
        vm.push_null();
        vm.new_slot(-3, false);

        vm.push_string("on_draw");
        vm.new_closure((vm) => {
            Squirrel.Obj o;
            vm.get_stack_object(1, out o);
            vm.add_ref(o);

            var da = vm.get_instance(1) as DrawingArea;

            Squirrel.Obj draw_foo;
            vm.get_stack_object(2, out draw_foo);
            vm.add_ref(draw_foo);
            da.draw.connect((cr) => {
                var top = vm.get_top();
                vm.push_object(draw_foo);
                vm.push_object(o);

                // get area of the drawing area
                Gtk.Allocation alloc;
                da.get_allocation(out alloc);
                var width = alloc.width;
                var height = alloc.height;

                instantiate_cairo_context(vm, cr);
                vm.push_int((long)width);
                vm.push_int((long)height);

                run_callback(vm, 4, "on_draw");
                bool result;
                vm.get_bool(-1, out result);
                vm.set_top(top);
                return result;
            });


            return 0;
        }, 0);
        vm.set_params_check(2, "xc");
        vm.new_slot(-3, false);

        vm.push_string("redraw");
        vm.new_closure((vm) => {
            var top = vm.get_top();
            DrawingArea da = vm.get_instance(1) as DrawingArea;
            da.queue_draw();
            return 0;
        }, 0);
        vm.set_params_check(1, "x");
        vm.new_slot(-3, false);

        vm.new_slot(-3, false);
    }
}

