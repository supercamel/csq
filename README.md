# CSQ

CSQ is a Squirrel language runtime for developing applications using the Squirrel scripting language. 

## Documentation

[ReadTheDocs](https://csq.readthedocs.io)

## How To Build

1. First build and install the squirrel_gobject library [squirrel_gobject](https://github.com/supercamel/squirrel_gobject)

2. Clone this repository
    
    ```
    git clone https://github.com/supercamel/csq
    cd csq
    ```

3. Configure and build 

    ```
    meson builddir
    ninja -C builddir
    ```

4. Try running an example script

    ```
    builddir/csq examples/hello_world.nut
    ```

