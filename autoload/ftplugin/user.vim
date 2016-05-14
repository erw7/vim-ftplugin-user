let s:ident = { 'id' : '', 'after' : '', }

function! ftplugin#user#init(fname) abort
  let l:ident = matchlist(a:fname, '\%(\%(/\|\\\)\(after\)\)\=\%(/\|\\\)ftplugin\%(/\|\\\)' . &filetype . '\%(\%(_\|/\|\\\)\(.\+\)\)\=\.vim$')
  if empty(l:ident)
    echoerr 'ftplugin#user#init called with invalid argument.'
    return 1
  endif
  let s:ident['id'] = '_' .  &filetype . (l:ident[1] != '' ? '_after' : '') . (l:ident[2] != '' ? '_' . l:ident[2] : '')
  let s:ident['after'] = l:ident[1]
  if s:ident['after'] != ''
    if exists('b:did_ftplugin_user' . s:ident['id'])
      return 1
    endif
    call ftplugin#user#let('b:did_ftplugin_user' . s:ident['id'], 1)
  elseif exists('b:did_ftplugin')
    return 1
  else
    let b:did_ftplugin = 1
  endif
  let b:save_cpo = &cpo
  set cpo&vim
  execute 'augroup ftplugin_user' . s:ident['id']
  autocmd! * <buffer>
  augroup END
  return 0
endfunction

function! ftplugin#user#end() abort
  let &cpo = b:save_cpo
  call s:let_undo_ftplugin('augroup! ftplugin_user' . s:ident['id'])
  let s:ident = { 'id' : '', 'after' : '', }
endfunction

function! ftplugin#user#setlocal(opt, ...) abort
  let l:opt = a:opt
  if a:0 == 0
    execute "setlocal " . l:opt
  elseif a:0 == 1
    execute "setlocal " . l:opt . "=" . a:1
  elseif a:0 == 2
    execute "setlocal " . l:opt . a:2 . a:1
  endif
  let l:opt = substitute(l:opt, '^no\(.\+\)', '\1', '')
  call s:let_undo_ftplugin('set ' . l:opt . '<')
endfunction

function! ftplugin#user#autocmd(cmd, event, ...) abort
  execute 'autocmd ftplugin_user' . s:ident['id'] . ' ' . a:event . ' <buffer> ' . (a:0 != 0 ? ' nested ' : '') . a:cmd
  call s:let_undo_ftplugin('execute "autocmd! ftplugin_user' . s:ident['id'] . '"')
endfunction

function! ftplugin#user#map(lhs, rhs, mode, ...) abort
  let l:noremap = a:0 != 0 ? 'nore' : ''
  execute a:mode . l:noremap . 'map <buffer> ' . a:lhs . ' ' . a:rhs
  call s:let_undo_ftplugin('execute "' . a:mode . 'unmap <buffer> ' . a:lhs . '"')
endfunction

function! ftplugin#user#let(var, val) abort
  if a:var !~ '^b:'
    let l:var = 'b:' . a:var
  else
    let l:var = a:var
  endif
  if !exists(l:var)
    execute 'let ' . l:var . ' = ' . a:val
    call s:let_undo_ftplugin('unlet! ' . l:var, '\<\%(un\)\=let!\= ' . l:var)
  else
    execute 'let ' . 'l:var_save = ' . l:var
    execute 'let ' . l:var . ' = ' . a:val
    call s:let_undo_ftplugin('let ' . l:var . ' = ' . l:var_save, '\<\%(un\)\=let\!\= ' . l:var)
  endif
endfunction

function! ftplugin#user#command(name, cmd, ...) abort
  execute 'command!' . (a:0 != 0 ? a:1 : '') . ' -buffer ' . a:name . ' ' . a:cmd
  call s:let_undo_ftplugin('delcommand ' . a:name)
endfunction

function! s:let_undo_ftplugin(cmd, ...) abort
  let l:pat = (a:0 == 0 ? '\<' . a:cmd : a:1)
  if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = a:cmd
  elseif match(b:undo_ftplugin, l:pat) ==  -1
    let b:undo_ftplugin .= ' | ' . a:cmd
  endif
endfunction
