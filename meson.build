project('valapkg', 'c', 'cpp', 'vala',
    default_options: ['cpp_std=c++17']
)

valapkg_SOURCES = [
    'main.vala',
    'init-cmd.vala',
    'package.vala', 
    'add-cmd.vala', 
    'build-cmd.vala', 
    'valabuild/compile.vala', 
    'valabuild/select.vala',
    'util.vala',
    'remove.vala',
    'compile-commands.vala',
    'getcwd.c',
    ]

subdir('build')

dependencies = [
    dependency('threads'),
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    #dependency('libsoup-2.4'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8'),
    dependency('vala-console'),
    meson.get_compiler('vala').find_library('posix')
]

executable('valapkg', valapkg_SOURCES, dependencies : dependencies, install : true)
