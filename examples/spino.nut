
local db = web.Spino();

local col = db.get_collection("TestCol");

col.append({
    name = "Sam",
    hugeCock = false  
});


col.update("{name: \"Sam\"}", {hugeCock = true});

local cursor = col.find("{name: \"Sam\"}");

cursor.set_projection("{\"name\":1}").set_limit(1);

while(cursor.has_next()) {
    print(cursor.next());
    print("\n");
}


