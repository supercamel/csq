project('camsq', 'vala')

dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('libsquirrel3'),
  dependency('gmodule-2.0'),
  dependency('gtk+-3.0'),
  meson.get_compiler('c').find_library('m', required: false)
  ]

source = files(
  'main.vala',
  'module.vala',
  'ui/window.vala',
  'ui/box.vala',
  'ui/label.vala',
  'ui/button.vala',
  'ui/entry.vala',
  'ui/treeview.vala',
  'ui/main_loop.vala'
  )

executable('csq', source, dependencies: dependencies)

