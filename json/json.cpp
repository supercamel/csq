#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
using namespace std;

#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/reader.h"
#include "rapidjson/filereadstream.h"
#include "json.h"

using namespace rapidjson;



struct MyHandler : public BaseReaderHandler<UTF8<>, MyHandler> {
    bool Null() 
    { 
        squirrel_vm_push_null(vm);
        return true; 
    }

    bool Bool(bool b) 
    { 
        squirrel_vm_push_bool(vm, b);
        return true; 
    }

    bool Int(int i) 
    { 
        squirrel_vm_push_int(vm, i);
        return true; 
    }

    bool Uint(unsigned u) 
    { 
        squirrel_vm_push_int(vm, u);
        return true; 
    }

    bool Int64(int64_t i) 
    { 
        squirrel_vm_push_int(vm, i);
        return true; 
    }

    bool Uint64(uint64_t u) 
    { 
        squirrel_vm_push_int(vm, u);
        return true; 
    }

    bool Double(double d) 
    { 
        squirrel_vm_push_float(vm, d);
        return true; 
    }

    bool String(const char* str, SizeType length, bool copy) 
    { 
        squirrel_vm_push_string(vm, str);
        return true;
    }

    bool StartObject() 
    { 
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
        for(SizeType i = 0; i < memberCount; i++) {
            int obj_pos = (memberCount - i) * 2 + 1;
            squirrel_vm_new_slot(vm, -obj_pos, false);
        }
        return true; 
    }

    bool StartArray() 
    { 
        squirrel_vm_new_array(vm, 0);
        return true; 
    }

    bool EndArray(SizeType elementCount) 
    { 
        for(SizeType i = 0; i < elementCount; i++) {
            int arr_pos = (elementCount - i) + 1;
            squirrel_vm_array_append(vm, -arr_pos);
        }
        return true; 
    }

    SquirrelVm* vm;
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
                stringstream ss;
                int counter = 0;
                ss << "[";
                squirrel_vm_push_null(vm);  //null iterator
                while(SQ_SUCCEEDED(squirrel_vm_next(vm,-2)))
                {
                    if(counter > 0) {
                        ss << ",";
                    }
                    gchar* val;
                    json_stringify(vm);
                    squirrel_vm_get_string(vm, -1, &val);
                    ss << val;

                    counter++;
                    squirrel_vm_pop(vm, 2); //pops key and val before the nex iteration
                }

                squirrel_vm_pop(vm, 2); //pops the null iterator and the array
                ss << "]";
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
        case SQUIRREL_OBJECTTYPE_CLOSURE:
        case SQUIRREL_OBJECTTYPE_NATIVECLOSURE:
            squirrel_vm_push_string(vm, "function");
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

glong json_parse_file(SquirrelVm* vm) 
{
    gchar* filename;
    squirrel_vm_get_string(vm, -1, &filename);
    FILE* fp = fopen(filename, "rb"); // non-Windows use "r"
    if(fp == NULL) {
        return squirrel_vm_throw_error(vm, "Error opening file");
    }
 
    char readBuffer[4096];
    MyHandler handler;
    handler.vm = vm;
    Reader reader;
    FileReadStream is(fp, readBuffer, sizeof(readBuffer));
    if(reader.Parse(is, handler) != kParseErrorNone) {
        cout << "Error offset: " << reader.GetErrorOffset() << endl;
        auto code = reader.GetParseErrorCode();
        // convert code to a meaningful message
        cout << "Error parsing json string: " << code << endl;
        fclose(fp);
        return squirrel_vm_throw_error(vm, "Error parsing json string");
    }
    fclose(fp);
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

    squirrel_vm_push_string(vm, "parse_file");
    squirrel_vm_new_closure(vm, json_parse_file, 0);
    squirrel_vm_set_params_check(vm, 2, ".s");
    squirrel_vm_new_slot(vm, -3, FALSE);

    squirrel_vm_new_slot(vm, -3, FALSE);
}


