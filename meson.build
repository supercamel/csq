project('camsq', 'vala', 'cpp')

dependencies = [
  dependency('glib-2.0'),
  dependency('gee-0.8'),
  dependency('gobject-2.0'),
  dependency('libsquirrel3'),
  dependency('gmodule-2.0'),
  dependency('libsoup-2.4'),
  dependency('spino-1.2'),
  dependency('gtk+-3.0'),
  meson.get_compiler('c').find_library('m', required: false)
  ]

incdir = include_directories('json')

source = files(
  'main.vala',
  'sleep.vala',
  'async.vala',
  'thread_registry.vala',
  'main_loop.vala',
  'json/json.cpp',
  'json/json.vapi'
  )

executable('csq', source, include_directories: incdir, dependencies: dependencies, install: true)

