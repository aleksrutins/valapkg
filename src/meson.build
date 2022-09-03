valapkg_src = []

subdir('util')
subdir('package')

valapkg_src += files('main.vala')

executable('valapkg',
           valapkg_src,
           dependencies: [
            dependency('libsoup-3.0'),
            dependency('gee-0.8'),
            dependency('json-glib-1.0'),
            vala_console_dep
           ],
           install : true)
