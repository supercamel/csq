###############################################################################
## Project Options
###############################################################################

project('native_csq_module', 'vala', 'c')
library_name = 'native_module'
description = 'A Native CSQ Module'

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gmodule-2.0'),
  dependency('libsquirrel3')
  ]

sources = files(
  'native_module.vala'
  )


###############################################################################
## probably don't need to edit below this line
###############################################################################

add_global_arguments(['-fPIC'], language: 'c')

lib = shared_library(library_name, sources,
  dependencies: dependencies,
  install: false)

meson.add_install_script('install.sh')
