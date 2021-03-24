project('valapkg', 'c', 'vala')

dependencies = [
    dependency('threads'),
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8'),
    meson.get_compiler('vala').find_library('posix')
]

executable('valapkg', [
    'main.vala',
    'init-cmd.vala', 
    'console/console.vala',
    'console/spinner.vala',
    'package.vala', 
    'add-cmd.vala', 
    'build-cmd.vala', 
    'valabuild/compile.vala', 
    'valabuild/select.vala',
    'util.vala',
    'remove.vala',
    'getcwd.c'
    ], dependencies : dependencies, install : true)
