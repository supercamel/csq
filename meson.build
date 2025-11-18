###############################################################################
## Project Options
###############################################################################

project('csq', 'vala', 'c', 'cpp')
namespace = 'csq'
version = '1.0'
description = 'Csq core library and runtime'

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
  dependency('libsquirrel3'),
  dependency('gmodule-2.0'),
  ]

sources = files(
  'src/thread.vala'
  )


gnome = import('gnome')
pkg = import('pkgconfig')

add_global_arguments(['-fPIC'], language: 'c')

header = namespace.to_lower() + '.h'
vapi = namespace.to_lower() + '-' + version + '.vapi'
typelib = namespace + '-' + version + '.typelib'

lib = static_library(namespace.to_lower(), sources,
  vala_header: header,
  vala_vapi: vapi,
  dependencies: dependencies,
  install: true,
  install_dir: [true, true, true])

pkg.generate(lib,
  version: version,
  name: namespace.to_lower(),
  filebase: namespace.to_lower() + '-' + version,
  description: description,
  subdirs: namespace.to_lower() + '-' + version
  )

executable_sources = files(
  'src/main.vala',
  'src/async.vala',
  'src/main_loop.vala',
  'src/sleep.vala',
  'src/thread.vala',
  'src/thread_registry.vala',
  'src/json/json.cpp',
  'src/json/json.vapi'
)

incdir = include_directories('src/json')

executable('csq', 
  executable_sources,
  include_directories: incdir,
  dependencies: [dependencies],
  install: true
)