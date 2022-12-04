project('valapkg', ['vala', 'c'],
  version : '0.1',
  default_options : ['warning_level=3'])

subproject('vala-console')
vala_console_dep = dependency('vala-console', fallback: ['vala-console', 'vala_console_dep'])

if get_option('build_client')
  subdir('src')
endif

if get_option('build_server')
  subdir('server')
endif