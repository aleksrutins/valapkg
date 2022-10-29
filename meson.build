project('valapkg', ['vala', 'c'],
  version : '0.1',
  default_options : ['warning_level=3'])

subproject('vala-console')
vala_console_dep = dependency('vala-console', fallback: ['vala-console', 'vala_console_dep'])

subdir('src')
subdir('server')