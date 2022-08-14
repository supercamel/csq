
// creates slots in the class for gobject things such as tracking callbacks
void expose_object_base(Squirrel.Vm vm)
{
    vm.push_string("__callbacks");
    vm.new_array(0);
    vm.new_slot(-3, false); 
}
