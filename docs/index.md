# CSQ

csq is a Squirrel runtime built on Vala and the GObject ecosystem. Its goal is to enable the cross-platform development of desktop applications in the Squirrel scripting language. 

## Modules

csq will ship with a light weight GUI API (essentially thin, simplified bindings to Gtk), the file system, and some basic network functions.

Native modules can be written in either C or Vala, and are used to further extend csq. Examples of how to bind a Vala class to a Squirrel classes are provided. 

One day we gonna make a native module that uses gobject introspection so we can require any introspectable library. 

