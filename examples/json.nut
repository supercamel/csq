
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


//json.parse("{bad json}");
