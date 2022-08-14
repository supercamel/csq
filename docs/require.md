# Require

csq exposes a function to include additional Squirrel scripts and native modules to your script. 

## Requiring Scripts

When a script is required, it is executed. All class and functions that are defined by the script will be made available to the rest of the program. 

csq will index each script that has been required and silently ignore all calls to require the same script. This is to break circular dependencies and to avoid unnecessarily loading files. 

    require("hello.nut");


## Requiring Native Modules

Native modules are searched for in three paths in this order.

* the current working directory
* the path specified by the CSQ_PATH environment variable (if it is defined)
* the PATH environment variable


To import a native module, simply pass the name of the library to the require function.

    require("mylibrary");


