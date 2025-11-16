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
  'object_wrapper.vala',
  'callback.vala',
  'thread_registry.vala',
  'system/application.vala',
  'ui/ui.vala',
  'ui/window.vala',
  'ui/box.vala',
  'ui/label.vala',
  'ui/button.vala',
  'ui/entry.vala',
  'ui/treeview.vala',
  'ui/main_loop.vala',
  'ui/widget.vala',
  'ui/messagebox.vala',
  'ui/menu.vala',
  'ui/drawing_area.vala',
  'ui/file_chooser.vala',
  'ui/scrolled.vala',
  'web/request.vala',
  'web/spino.vala',
  'json/json.vapi',
  'json/json.cpp'
  )

executable('csq', source, include_directories: incdir, dependencies: dependencies, install: true)

