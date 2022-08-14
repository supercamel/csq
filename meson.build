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
  'window.vala',
  'box.vala',
  'label.vala',
  'button.vala',
  'entry.vala',
  'treeview.vala',
  'main_loop.vala',
  'module.vala',
  'module_interface.vala'
  )

executable('csq', source, dependencies: dependencies)

