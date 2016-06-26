function! s:SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

if ftplugin#user#init(expand('<sfile>'))
  finish
endif

call ftplugin#user#map('<F5>', ':<C-u>call <SID>make()<CR>', 'n', 1)
call ftplugin#user#let('b:ftplugin_tmap01_sid', s:SID())
call ftplugin#user#end()

