let s:ident = { 'id' : '', 'after' : '', 'sid' : '' }

function! ftplugin#user#init(fname) abort
  if has('win32')
    let l:fname = substitute(a:fname, '\\', '/', 'g')
  else
    let l:fname = a:fname
  endif
  let l:ident = matchlist(l:fname, '\%(/\(after\)\)\=/ftplugin/\([^_/]\+\)\%(\%(_\|/\)\(.\+\)\)\=\.vim$')
  if empty(l:ident)
    echoerr 'ftplugin#user#init called with invalid argument.'
    return 1
  endif
  try
    let s:ident['sid'] = s:get_sid(expand(l:fname))
  catch /E716/
    echoerr "Can't get sid"
    return 1
  endtry
  let s:ident['id'] = '_' . l:ident[2] . (l:ident[1] != '' ? '_after' : '') . (l:ident[3] != '' ? '_' . l:ident[3] : '')
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
  let s:ident = { 'id' : '', 'after' : '', 'sid' : '' }
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
  let l:cmd = substitute(a:cmd, '\<s:', '<SNR>' . s:ident['sid'] . '_', 'g')
  execute 'autocmd ftplugin_user' . s:ident['id'] . ' ' . a:event . ' <buffer> ' . (a:0 != 0 ? ' nested ' : '') . l:cmd
  call s:let_undo_ftplugin('execute "autocmd! ftplugin_user' . s:ident['id'] . '"')
endfunction

function! ftplugin#user#map(lhs, rhs, mode, ...) abort
  let l:rhs = substitute(a:rhs, '<SID>', '<SNR>' . s:ident['sid'] . '_', 'g')
  let l:noremap = a:0 != 0 ? 'nore' : ''
  execute a:mode . l:noremap . 'map <buffer> ' . a:lhs . ' ' . l:rhs
  call s:let_undo_ftplugin('execute "' . a:mode . 'unmap <buffer> ' . a:lhs . '"')
endfunction

function! ftplugin#user#let(var, val) abort
  if a:var !~ '^b:'
    let l:var = 'b:' . a:var
  else
    let l:var = a:var
  endif
  let l:val = s:to_string(a:val)

  if !exists(l:var)
    execute 'let ' . l:var . ' = ' . l:val
    call s:let_undo_ftplugin('unlet! ' . l:var, '\<\%(un\)\=let!\= ' . l:var)
  else
    execute 'let ' . 'l:var_save = ' . l:var
    execute 'let ' . l:var . ' = ' . l:val
    call s:let_undo_ftplugin('let ' . l:var . ' = ' . s:to_string(l:var_save), '\<\%(un\)\=let\!\= ' . l:var)
  endif
endfunction

function! ftplugin#user#command(name, cmd, ...) abort
  let l:cmd = substitute(a:cmd, '\<s:', '<SNR>' . s:ident['sid'] . '_', 'g')
  execute 'command!' . (a:0 != 0 ? a:1 : '') . ' -buffer ' . a:name . ' ' . l:cmd
  call s:let_undo_ftplugin('delcommand ' . a:name)
endfunction

function! ftplugin#user#let_undo_ftplugin(cmd, ...) abort
  let l:args = [a:cmd] + a:000
  call call('s:let_undo_ftplugin', l:args)
endfunction

function! s:let_undo_ftplugin(cmd, ...) abort
  let l:pat = (a:0 == 0 ? '\<' . a:cmd : a:1)
  if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = a:cmd
  elseif match(b:undo_ftplugin, l:pat) ==  -1
    let b:undo_ftplugin .= ' | ' . a:cmd
  endif
endfunction

function! s:scriptnames() abort
  let l:result = ''
  redir =>> l:result
    silent scriptnames
  redir END
  return l:result
endfunction

function! s:get_sid(fname) abort
  let l:fnames_dict = {}
  let l:fnames = map(map(split(s:scriptnames(), '\n'), "substitute(v:val, '^\\s\\+', '', '')"), "split(v:val, ':\\s\\+')")
  for l:fname in l:fnames
    if has('win32') || has('win32unix')
      let l:fnames_dict[tolower(substitute(expand(l:fname[1]), '\\', '/', 'g'))] = l:fname[0]
    else
      let l:fnames_dict[expand(l:fname[1])] = l:fname[0]
    endif
  endfor
  if has('win32') || has('win32unix')
    return l:fnames_dict[tolower(substitute(expand(a:fname), '\\', '/', 'g'))]
  else
    return l:fnames_dict[expand(a:fname)]
  endif
endfunction

function! s:to_string(val)
  let l:res = ''
  if type(a:val) == type("")
    return "'" . substitute(a:val, "'", "''", 'g') . "'"
  elseif type(a:val) == type(0.0)
    return printf('%f', a:val)
  else
    return string(a:val)
  endif
endfunction
