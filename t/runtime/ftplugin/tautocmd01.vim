if ftplugin#user#init(expand('<sfile>'))
  finish
endif

call ftplugin#user#autocmd('SyntasticCheck', 'BufWritePost')
call ftplugin#user#end()
