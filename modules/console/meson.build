# Module source files
module_sources = [
    'console.vala'
]

# Module-specific dependencies (if any)
module_deps = [
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('libsquirrel3'),
    dependency('csq-1.0')
    # Add other dependencies here
]

# VAPI files (if any)
vapi_files = [
    # 'custom.vapi',
]

# Build the shared library
shared_library(
    'console',  # This will become libcsq-module1.so (or .dll on Windows)
    module_sources,
    dependencies: module_deps,
    vala_args: [
        '--library=console'
    ],
    install: true,
    install_dir: modules_install_dir,
)
