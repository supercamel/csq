project('csq-modules', 'vala', 'c',
    version: '1.0.0',
    license: 'LGPL-2.1-or-later',
    default_options: [
        'warning_level=3',
        'default_library=shared',
    ]
)

# Compiler and dependencies
valac = meson.get_compiler('vala')
add_project_arguments(['--vapidir=' + meson.current_source_dir()], language: 'vala')

# Dependencies that all modules might need
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')

# Common dependencies for modules
common_deps = [glib_dep, gobject_dep]

# Default installation to home directory
home_dir = run_command('sh', '-c', 'echo $HOME', check: true).stdout().strip()
modules_install_dir = home_dir / '.csq' / 'modules'

# Option to install to system instead
if get_option('install_to_system')
    modules_install_dir = get_option('prefix') / get_option('libdir') / 'csq' / 'modules'
endif

message('Installing modules to: ' + modules_install_dir)

# Find all module directories
modules = []
foreach dir : ['web', 'console']  # Add your module names here
    if run_command('test', '-d', dir, check: false).returncode() == 0
        modules += dir
    endif
endforeach

# Build each module
foreach module : modules
    subdir(module)
endforeach

# Summary
message('Building modules: ' + ', '.join(modules))
