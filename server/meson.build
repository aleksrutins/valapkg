valapkg_server_src = []

valapkg_server_src += files('main.vala')
executable('valapkg-server', valapkg_server_src, dependencies: [
    dependency('libsoup-3.0'),
    dependency('gee-0.8'),
    dependency('json-glib-1.0'),
    dependency('libpq'),
    vala_console_dep
], install: true)