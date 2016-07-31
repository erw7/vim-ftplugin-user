function! s:SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

if ftplugin#user#init(expand('<sfile>'))
  finish
endif

call ftplugin#user#command('SetPath', 'call s:set_path()')
call ftplugin#user#let('b:ftplugin_tcommand01_sid', s:SID())
call ftplugin#user#end()

