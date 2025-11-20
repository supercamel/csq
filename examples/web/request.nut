#!/usr/local/bin/csq

::web <- require("web");

local result = web.get("http://example.com");
print(json.stringify(result) + "\n");