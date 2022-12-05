project('valapkg', ['vala', 'c'],
  version : '0.1',
  default_options : ['warning_level=3'])

subproject('vala-console')
subproject('prosody')
vala_console_dep = dependency('vala-console', fallback: ['vala-console', 'vala_console_dep'])
prosody_dep = dependency('prosody', fallback: ['prosody', 'prosody_dep'])

include_dirs = []

subdir('src')

if get_option('build_client')
  subdir('cmd')
endif

if get_option('build_server')
  subdir('server')
endif