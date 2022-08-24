#include <iostream>
#include <sstream>
#include <vector>
using namespace std;

#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/reader.h"
#include "json.h"

using namespace rapidjson;



struct MyHandler : public BaseReaderHandler<UTF8<>, MyHandler> {
    bool Null() 
    { 
        squirrel_vm_push_null(vm);
        push_element();
        return true; 
    }

    bool Bool(bool b) 
    { 
        squirrel_vm_push_bool(vm, b);
        push_element();
        return true; 
    }

    bool Int(int i) 
    { 
        squirrel_vm_push_int(vm, i);
        push_element();
        return true; 
    }

    bool Uint(unsigned u) 
    { 
        squirrel_vm_push_int(vm, u);
        push_element();
        return true; 
    }

    bool Int64(int64_t i) 
    { 
        squirrel_vm_push_int(vm, i);
        push_element();
        return true; 
    }

    bool Uint64(uint64_t u) 
    { 
        squirrel_vm_push_int(vm, u);
        push_element();
        return true; 
    }

    bool Double(double d) 
    { 
        squirrel_vm_push_float(vm, d);
        push_element();
        return true; 
    }

    bool String(const char* str, SizeType length, bool copy) 
    { 
        squirrel_vm_push_string(vm, str);
        push_element();
        return true;
    }

    bool StartObject() 
    { 
        depth_stack.push_back(-3);
        squirrel_vm_new_table(vm);
        return true; 
    }

    bool Key(const char* str, SizeType length, bool copy) 
    { 
        squirrel_vm_push_string(vm, str);
        return true;
    }

    bool EndObject(SizeType memberCount) 
    { 
        depth_stack.pop_back();
        if(depth_stack.size() > 1) {
            push_element();
        }
        return true; 
    }

    bool StartArray() 
    { 
        squirrel_vm_new_array(vm, 0);
        depth_stack.push_back(-2);
        return true; 
    }

    bool EndArray(SizeType elementCount) 
    { 
        depth_stack.pop_back();
        push_element();
        return true; 
    }

    void push_element()
    {
        if(depth_stack.back() == -2) {
            squirrel_vm_array_append(vm, depth_stack.back());
        }
        else if(depth_stack.back() == -3) {
            squirrel_vm_new_slot(vm, depth_stack.back(), false);
        }
    }

    SquirrelVm* vm;
    std::vector<int> depth_stack;
};

glong json_parse(SquirrelVm* vm)
{
    gchar* json;
    squirrel_vm_get_string(vm, -1, &json);
    MyHandler handler;
    handler.vm = vm;
    Reader reader;
    StringStream ss(json);
    if(reader.Parse(ss, handler) != kParseErrorNone) {
        return squirrel_vm_throw_error(vm, "Error parsing json string");
    }
    return 1;
}

glong json_stringify(SquirrelVm* vm)
{
    switch(squirrel_vm_get_object_type(vm, -1))
    {
        case SQUIRREL_OBJECTTYPE_TABLE:
        case SQUIRREL_OBJECTTYPE_INSTANCE:
            {
                stringstream ss;
                ss << "{";
                squirrel_vm_push_null(vm);

                int count = 0;
                while(SQ_SUCCEEDED(squirrel_vm_next(vm,-2)))
                {

                    if(count++ > 0) {
                        ss << ",";
                    }

                    gchar* key;
                    squirrel_vm_get_string(vm, -2, &key);


                    ss << "\"" << key << "\":";
                    json_stringify(vm);

                    gchar* val;
                    squirrel_vm_get_string(vm, -1, &val);
                    ss << val;
                    squirrel_vm_pop(vm, 2);

                }
                ss << "}";
                squirrel_vm_pop(vm,2); 

                squirrel_vm_push_string(vm, ss.str().c_str());
            }
            break;
        case SQUIRREL_OBJECTTYPE_ARRAY:
            {
                int sz = squirrel_vm_get_size(vm, -1);
                stringstream ss;
                ss << "[";
                int count = 0;
                for(int i = 0; i < sz; i++) {
                    if(i > 0) {
                        ss << ",";
                    }

                    squirrel_vm_push_int(vm, i);
                    squirrel_vm_get(vm, -2);

                    json_stringify(vm);

                    gchar* val;
                    squirrel_vm_get_string(vm, -1, &val);
                    ss << val;

                    squirrel_vm_pop(vm, 2);
                }
                ss << "]";

                squirrel_vm_pop(vm, 1);
                squirrel_vm_push_string(vm, ss.str().c_str());
            }
            break;
        case SQUIRREL_OBJECTTYPE_STRING:
            {
                stringstream ss;

                gchar* str;
                squirrel_vm_get_string(vm, -1, &str);

                rapidjson::StringBuffer sb;
                rapidjson::Writer<StringBuffer> writer(sb); // edited
                writer.String(str);

                squirrel_vm_pop(vm, 1);

                squirrel_vm_push_string(vm, sb.GetString());
            }
            break;
        case SQUIRREL_OBJECTTYPE_NULL:
            squirrel_vm_push_string(vm, "null");
            break;
        default:
            {
                squirrel_vm_to_string(vm, -1);
                gchar* str;
                squirrel_vm_get_string(vm, -1, &str);
                gchar* str_copy = g_strdup(str);
                squirrel_vm_pop(vm, 2);
                squirrel_vm_push_string(vm, str_copy);
            }
    }
    return 1;
}


void expose_json(SquirrelVm* vm)
{
    squirrel_vm_push_string(vm, "json");
    squirrel_vm_new_table(vm);

    squirrel_vm_push_string(vm, "parse");
    squirrel_vm_new_closure(vm, json_parse, 0);
    squirrel_vm_set_params_check(vm, 2, ".s");
    squirrel_vm_new_slot(vm, -3, FALSE);

    squirrel_vm_push_string(vm, "stringify");
    squirrel_vm_new_closure(vm, json_stringify, 0);
    squirrel_vm_set_params_check(vm, 2, "..");
    squirrel_vm_new_slot(vm, -3, FALSE);

    squirrel_vm_new_slot(vm, -3, FALSE);
}


