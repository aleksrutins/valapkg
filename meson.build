project('valapkg', 'c', 'vala')

dependencies = [
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    meson.get_compiler('vala').find_library('posix')
]

executable('valapkg', ['main.vala', 'init-cmd.vala', 'console.vala', 'package.vala', 'add-cmd.vala'], dependencies : dependencies, install : true)