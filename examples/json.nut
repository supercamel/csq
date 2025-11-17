#!/usr/local/bin/csq

local j = json.parse("{\"field\": 100}");

print(j.field);
print("\n");

j = json.parse("{\"field\": 12.5}");
print(j.field);
print("\n");

j = json.parse("{\"field\":[0,1,2,3]}");
print(j.field[1]);
print("\n");

print(json.stringify(j));
print("\n");


// now test a really big object
j = {};
for (local i = 0; i < 10000000; i++) {
	j["key_" + i]<- "value_" + i;
}
local str = json.stringify(j);

local j2 = json.parse(str);

//json.parse("{bad json}");

