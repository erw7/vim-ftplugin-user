filetype plugin on

redir => g:pwd
pwd
redir END
execute 'set runtimepath^=' . substitute(g:pwd, '\n', '', 'g') . '/t/runtime'
execute 'set runtimepath+=' . substitute(g:pwd, '\n', '', 'g') . '/t/runtime/after'

describe 'ftplugin_user'
  describe 'init'

    before
      new
    end

    after
      close!
    end

    it 'typical init ftplugin'
      setf tinit01
      Expect b:did_ftplugin == 1
      redir => g:autocmd
      autocmd ftplugin_user_tinit01
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"
    end

    it 'typical abort init ftplugin'
      let b:did_ftplugin = 1
      setf tinit01
      Expect exists('b:undo_ftplugin') == 0
    end

    it 'typical init after ftplugin'
      setf tinit02
      Expect b:did_ftplugin_user_tinit02_after == 1
      redir => g:autocmd
      autocmd ftplugin_user_tinit02_after
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"
    end

    it 'typical abort init after ftplugin'
      let b:did_ftplugin_user_tinit02_after = 1
      setf tinit02
      Expect exists('b:undo_ftplugin') == 0
    end

    it 'typical init after ftplugin with flag'
      setf tinit03
      Expect b:did_ftplugin_user_tinit03_after_flag1 == 1
      redir => g:autocmd
      autocmd ftplugin_user_tinit03_after_flag1
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"

      setf tinit04
      Expect b:did_ftplugin_user_tinit04_after_flag1 == 1
      redir => g:autocmd
      autocmd ftplugin_user_tinit04_after_flag1
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"
    end

    it 'typical abort init after ftplugin with flag'
      let b:did_ftplugin_user_tinit03_after_flag1 = 1
      setf tinit03
      Expect exists('b:undo_ftplugin') == 0
      let b:did_ftplugin_user_tinit04_after_flag1 = 1
      Expect exists('b:undo_ftplugin') == 0
    end
  end

  describe 'setlocal'
    before
      new
      set tabstop=4
      set ruler
      set nonumber
    end

    after
      close!
    end

    it 'setlocal boolean'
      call ftplugin#user#setlocal('noruler')
      Expect &ruler == 0
      Expect b:undo_ftplugin  =~ '\<set ruler<'
      call ftplugin#user#setlocal('number')
      Expect &number == 1
      Expect b:undo_ftplugin  =~ '\<set number<'
    end

    it 'setlocal number'
      call ftplugin#user#setlocal('tabstop', 2)
      Expect &tabstop == 2
      Expect b:undo_ftplugin =~ '\<set tabstop<'
    end

    it 'setlocal string'
      call ftplugin#user#setlocal('path', '/usr/local/include', '+=')
      Expect &path == '.,/usr/include,,,/usr/local/include'
      Expect b:undo_ftplugin =~ '\<set path<'
    end
  end

  describe 'autocmd'
    before
      new
      setf test
    end

    after
      close!
    end

    it 'typical autocmd'
      setf tautocmd01
      redir => g:autocmd
      autocmd ftplugin_user_tautocmd01
      redir END
      Expect g:autocmd =~ 'ftplugin_user_tautocmd01\s\+BufWritePost\n\s\+<buffer=\d\+>\n\s\+SyntasticCheck'
      Expect b:undo_ftplugin =~ 'execute "autocmd! ftplugin_user_tautocmd01"'
    end

    it 'autocmd for script local function'
      setf tautocmd02
      redir => g:autocmd
      autocmd ftplugin_user_tautocmd02
      redir END
      Expect g:autocmd =~ 'ftplugin_user_tautocmd02\s\+BufWritePost\n\s\+<buffer=\d\+>\n\s\+call\s<SNR>' . b:ftplugin_tautocmd02_sid . '_SyntasticCheck'
    end
  end

  describe 'map'
    before
      new
      setf test
    end

    after
      close!
    end

    it 'typical map with mode'
      call ftplugin#user#map('<F5>', ':make<CR>', 'n')
      redir => g:map
      map <F5>
      redir END
      Expect g:map =~ 'n\s\+<F5>\s\+@:make<CR>'
    end

    it 'typical noremap with mode'
      call ftplugin#user#map('<F5>', ':make<CR>', 'n', 1)
      redir => g:map
      map <F5>
      redir END
      Expect g:map =~ 'n\s\+<F5>\s\+\*@:make<CR>'
    end

    it 'map for script local function'
      setf tmap01
      redir => g:map
      map <F5>
      redir END
      Expect g:map =~ 'n\s\+<F5>\s\+\*@:<C-U>call\s\+<SNR>' . b:ftplugin_tmap01_sid . '_make()<CR>'
    end

    it 'Unmap of typical map with mode'
      call ftplugin#user#map('<F5>', ':make<CR>', 'n')
      Expect b:undo_ftplugin =~ 'nunmap <buffer> <F5>'
    end

    it 'Unmap of typical map with mode and map argument'
      call ftplugin#user#map('<nowait> <silent><special> <script><expr> <F5>', ':make<CR>', 'n')
      Expect b:undo_ftplugin =~ 'nunmap <buffer> <F5>'
    end
  end

  describe 'let'
    before
      new
      setf test
    end

    after
      close!
    end

    it 'typical let for integer'
      call ftplugin#user#let('b:foo', 1)
      Expect b:foo == 1
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let for string'
      call ftplugin#user#let('b:foo', "ab'cd")
      Expect b:foo == "ab'cd"
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let for float'
      call ftplugin#user#let('b:foo', 0.1)
      Expect b:foo == 0.1
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let for array'
      call ftplugin#user#let('b:foo', ['a', 'b', 1])
      Expect b:foo == ['a', 'b', 1]
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let for dictionary'
      call ftplugin#user#let('b:foo', {'a' : 'b'})
      Expect b:foo == {'a':'b'}
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let for Funcref'
      call ftplugin#user#let('b:foo', function('tr'))
      Expect b:foo == function('tr')
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let twice'
      call ftplugin#user#let('b:foo', 1)
      call ftplugin#user#let('b:foo', 2)
      Expect b:foo == 2
      Expect b:undo_ftplugin =~ 'unlet! b:foo'
    end

    it 'typical let exists var'
      let b:foo = 1
      call ftplugin#user#let('b:foo', 2)
      Expect b:foo == 2
      Expect b:undo_ftplugin =~ 'let b:foo = 1'
    end

    it 'typical let exists var twice'
      let b:foo = 0.1
      call ftplugin#user#let('b:foo', 2)
      call ftplugin#user#let('b:foo', 3)
      Expect b:foo == 3
      Expect b:undo_ftplugin =~ 'let b:foo = 0.1'
    end
  end

  describe 'command'
    before
      new
      setf test
    end

    after
      close!
    end

    it 'typical command'
      call ftplugin#user#command('Foo', 'call Foo()')
      redir => g:command
      command Foo
      redir END
      Expect g:command =~ 'b\s\+Foo\s\+0\s\+call Foo()'
      Expect b:undo_ftplugin =~ 'delcommand Foo'
    end

    it 'typical command with args'
      call ftplugin#user#command('Foo', 'call Foo(<f-args>)', '-bar -nargs=*')
      redir => g:command
      command Foo
      redir END
      Expect g:command =~ 'b\s\+Foo\s\+\*\s\+call Foo(<f-args>)'
      Expect b:undo_ftplugin =~ 'delcommand Foo'
    end

    it 'command for script local function'
      setf tcommand01
      redir => g:command
      command SetPath
      redir END
      Expect split(g:command, '\n')[1] =~ '\s\+b\s\+SetPath\s\+0\s\+call\s\+<SNR>' . b:ftplugin_tcommand01_sid . '_set_path()'
    end
  end
end
