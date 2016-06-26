function! s:SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

if ftplugin#user#init(expand('<sfile>'))
  finish
endif

call ftplugin#user#autocmd('call s:SyntasticCheck()', 'BufWritePost')
call ftplugin#user#let('b:ftplugin_tautocmd02_sid', s:SID())
call ftplugin#user#end()

