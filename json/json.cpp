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
    enum class Ctx { Obj, Arr };
    struct Frame { Ctx kind; };

    SquirrelVm* vm{};
    std::vector<Frame> st;  // container stack

    // Helper: after a value is on top, attach it to the current container
    bool attach_value_to_parent() {
        if (st.empty()) {
            // This is the root value: leave it on stack for caller
            return true;
        }
        if (st.back().kind == Ctx::Arr) {
            // parent: [..., <array>, <value>]
            squirrel_vm_array_append(vm, -2);
            // some bindings keep value; if so, pop it:
            //squirrel_vm_pop(vm, 1);
        } else { // Obj
            // parent: [..., <object>, <key>, <value>]
            squirrel_vm_new_slot(vm, -3, false);
            // new_slot usually consumes key & value, leaving object there
        }
        return true;
    }

    // Primitives: push then immediately attach to parent (if any)
    bool Null()   { squirrel_vm_push_null(vm);  return attach_value_to_parent(); }
    bool Bool(bool b)    { squirrel_vm_push_bool(vm, b);  return attach_value_to_parent(); }
    bool Int(int i)      { squirrel_vm_push_int(vm, i);   return attach_value_to_parent(); }
    bool Uint(unsigned u){ squirrel_vm_push_int(vm, (long long)u); return attach_value_to_parent(); }
    bool Int64(int64_t i){ squirrel_vm_push_int(vm, (long long)i); return attach_value_to_parent(); }
    bool Uint64(uint64_t u){ squirrel_vm_push_int(vm, (long long)u); return attach_value_to_parent(); }
    bool Double(double d){ squirrel_vm_push_float(vm, d); return attach_value_to_parent(); }
    bool String(const char* s, SizeType, bool) { squirrel_vm_push_string(vm, s); return attach_value_to_parent(); }

    // Containers
    bool StartObject() {
        squirrel_vm_new_table(vm);          // push a fresh table
        st.push_back({Ctx::Obj});           // it becomes the current container
        return true;
    }
    bool Key(const char* s, SizeType, bool) {
        // For an object, push key now; when the next value comes,
        // new_slot(vm, -3, false) will consume key+value and set into the object.
        squirrel_vm_push_string(vm, s);
        return true;
    }
    bool EndObject(SizeType) {
        // Finished object is on top. If there is a parent container,
        // attach this object as its value (for arrays) or as the
        // value for the previously pushed key (for objects).
        st.pop_back();
        return attach_value_to_parent();
    }

    bool StartArray() {
        squirrel_vm_new_array(vm, 0);
        st.push_back({Ctx::Arr});
        return true;
    }
    bool EndArray(SizeType) {
        // Array is on top; attach to parent (if any)
        st.pop_back();
        return attach_value_to_parent();
    }
};

glong json_parse(SquirrelVm* vm, gpointer user_data)
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


// --- helpers -------------------------------------------------

static inline void write_json_string_escaped(const char* s, std::ostream& os) {
    rapidjson::StringBuffer sb;
    rapidjson::Writer<rapidjson::StringBuffer> w(sb);
    w.String(s ? s : "");
    os << sb.GetString();
}

static void emit_json(SquirrelVm* vm, int idx, std::ostream& os, int indent, bool pretty);

// indentation utility
static inline void indent_n(std::ostream& os, int n) {
    while (n-- > 0) os << ' ';
}

static void emit_object(SquirrelVm* vm, int idx, std::ostream& os, int indent, bool pretty) {
    os << "{";
    bool first = true;

    squirrel_vm_push_null(vm); // iterator
    while (SQ_SUCCEEDED(squirrel_vm_next(vm, idx - 1))) {
        // stack: [..., <obj>, <key>, <val>]
        if (!first) os << (pretty ? ",\n" : ",");
        if (pretty) { if (first) os << "\n"; indent_n(os, indent + 2); }
        first = false;

        // key -> temp string on top, read, then pop temp
        squirrel_vm_to_string(vm, -2);
        gchar* key_cstr = nullptr;
        squirrel_vm_get_string(vm, -1, &key_cstr);
        write_json_string_escaped(key_cstr, os);
        squirrel_vm_pop(vm, 1); // pop temp string

        os << (pretty ? ": " : ":");

        // value (still at -1)
        emit_json(vm, -1, os, indent + 2, pretty);

        squirrel_vm_pop(vm, 2); // pop original key & value
    }
    squirrel_vm_pop(vm, 1); // pop iterator

    if (pretty && !first) { os << "\n"; indent_n(os, indent); }
    os << "}";
}


static void emit_array(SquirrelVm* vm, int idx, std::ostream& os, int indent, bool pretty) {
    os << "[";
    bool first = true;

    squirrel_vm_push_null(vm); // iterator
    while (SQ_SUCCEEDED(squirrel_vm_next(vm, idx - 1))) {
        // stack: [..., <arr>, <index>, <val>]
        if (!first) os << (pretty ? ",\n" : ",");
        if (pretty) { if (first) os << "\n"; indent_n(os, indent + 2); }
        first = false;

        emit_json(vm, -1, os, indent + 2, pretty);

        squirrel_vm_pop(vm, 2); // pop index & val
    }
    squirrel_vm_pop(vm, 1); // pop iterator

    if (pretty && !first) { os << "\n"; indent_n(os, indent); }
    os << "]";
}

static void emit_json(SquirrelVm* vm, int idx, std::ostream& os, int indent, bool pretty) {
    switch (squirrel_vm_get_object_type(vm, idx)) {
        case SQUIRREL_OBJECTTYPE_TABLE:
        case SQUIRREL_OBJECTTYPE_INSTANCE:
            emit_object(vm, idx, os, indent, pretty);
            break;

        case SQUIRREL_OBJECTTYPE_ARRAY:
            emit_array(vm, idx, os, indent, pretty);
            break;

        case SQUIRREL_OBJECTTYPE_STRING: {
            gchar* s = nullptr;
            squirrel_vm_get_string(vm, idx, &s);
            write_json_string_escaped(s, os);
            break;
        }
        case SQUIRREL_OBJECTTYPE_INTEGER: {
            glong v = 0;
            squirrel_vm_get_int(vm, idx, &v);
            os << v;
            break;
        }
        case SQUIRREL_OBJECTTYPE_FLOAT: {
            float v = 0.0;
            squirrel_vm_get_float(vm, idx, &v);
            // Use default formatting (JSON allows plain IEEE decimal)
            os << v;
            break;
        }
        case SQUIRREL_OBJECTTYPE_BOOL: {
            gboolean b = false;
            squirrel_vm_get_bool(vm, idx, &b);
            os << (b ? "true" : "false");
            break;
        }
        case SQUIRREL_OBJECTTYPE_NULL:
            os << "null";
            break;

        case SQUIRREL_OBJECTTYPE_CLOSURE:
        case SQUIRREL_OBJECTTYPE_NATIVECLOSURE:
            // Keep previous behavior but make it valid JSON (quoted string)
            write_json_string_escaped("function", os);
            break;

        default: {
            // Fallback: to_string then emit as JSON string (safe)
            squirrel_vm_to_string(vm, idx);
            gchar* s = nullptr;
            squirrel_vm_get_string(vm, -1, &s);
            write_json_string_escaped(s, os);
            squirrel_vm_pop(vm, 1);
            break;
        }
    }
}

// --- public API -------------------------------------------------

glong json_stringify(SquirrelVm* vm, gpointer /*user_data*/)
{
    // Optional 2nd arg: condensed (bool). Default = pretty.
    // Calls:
    //   json.stringify(value)           -> pretty
    //   json.stringify(value, true)     -> condensed (no spaces/newlines)
    gboolean condensed = false;
    int value_idx = -1;

    if (squirrel_vm_get_object_type(vm, -1) == SQUIRREL_OBJECTTYPE_BOOL) {
        gboolean b = false;
        squirrel_vm_get_bool(vm, -1, &b);
        condensed = b;
        value_idx = -2;
    } else {
        value_idx = -1;
    }

    std::ostringstream ss;
    emit_json(vm, value_idx, ss, /*indent=*/0, /*pretty=*/!condensed);

    // Pop inputs, push result
    if (value_idx == -2) squirrel_vm_pop(vm, 2); else squirrel_vm_pop(vm, 1);
    squirrel_vm_push_string(vm, ss.str().c_str());
    return 1;
}


glong json_parse_file(SquirrelVm* vm, void* user_data) 
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
    squirrel_vm_new_closure(vm, json_parse, nullptr, 0);
    squirrel_vm_set_params_check(vm, 2, ".s");
    squirrel_vm_new_slot(vm, -3, FALSE);

    squirrel_vm_push_string(vm, "stringify");
    squirrel_vm_new_closure(vm, json_stringify, nullptr, 0);
    squirrel_vm_set_params_check(vm, 2, "..");
    squirrel_vm_new_slot(vm, -3, FALSE);

    squirrel_vm_push_string(vm, "parse_file");
    squirrel_vm_new_closure(vm, json_parse_file, nullptr, 0);
    squirrel_vm_set_params_check(vm, 2, ".s");
    squirrel_vm_new_slot(vm, -3, FALSE);

    squirrel_vm_new_slot(vm, -3, FALSE);
}


