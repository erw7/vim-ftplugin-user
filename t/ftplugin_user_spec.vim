describe 'ftplugin_user'

  describe 'init'

    before
      new
      setf test
    end

    after
      close!
    end

    it 'typical init ftplugin'
      Expect ftplugin#user#init('/home/hoge/.vim/ftplugin/test.vim') == 0
      Expect b:did_ftplugin == 1
      redir => g:autocmd
        autocmd ftplugin_user_test
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"
    end

    it 'typical abort init ftplugin'
      let b:did_ftplugin = 1
      Expect ftplugin#user#init('/home/hoge/.vim/ftplugin/test.vim') == 1
    end

    it 'typical init after ftplugin'
      Expect ftplugin#user#init('/home/hoge/.vim/after/ftplugin/test.vim') == 0
      Expect b:did_ftplugin_user_test_after == 1
      redir => g:autocmd
        autocmd ftplugin_user_test_after
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"
    end

    it 'typical abort init after ftplugin'
      let b:did_ftplugin_user_test_after = 1
      Expect ftplugin#user#init('/home/hoge/.vim/after/ftplugin/test.vim') == 1
    end
    it 'typical init after ftplugin with flag'

      Expect ftplugin#user#init('/home/hoge/.vim/after/ftplugin/test_flag1.vim') == 0
      Expect b:did_ftplugin_user_test_after_flag1 == 1
      redir => g:autocmd
        autocmd ftplugin_user_test_after_flag1
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"

      Expect ftplugin#user#init('/home/hoge/.vim/after/ftplugin/test/flag2.vim') == 0
      Expect b:did_ftplugin_user_test_after_flag2 == 1
      redir => g:autocmd
        autocmd ftplugin_user_test_after_flag2
      redir END
      Expect g:autocmd == "\n--- Auto-Commands ---"
    end

    it 'typical abort init after ftplugin with flag'
      let b:did_ftplugin_user_test_after_flag1 = 1
      Expect ftplugin#user#init('/home/hoge/.vim/after/ftplugin/test_flag1.vim') == 1
      let b:did_ftplugin_user_test_after_flag2 = 1
      Expect ftplugin#user#init('/home/hoge/.vim/after/ftplugin/test/flag2.vim') == 1
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
      call ftplugin#user#init('/home/hoge/.vim/ftplugin/test.vim')
      call ftplugin#user#autocmd('SyntasticCheck', 'BufWritePost')
      redir => g:autocmd
        autocmd ftplugin_user_test
      redir END
      Expect g:autocmd =~ 'ftplugin_user_test\s\+BufWritePost\n\s\+<buffer=\d\+>\n\s\+SyntasticCheck'
      Expect b:undo_ftplugin =~ 'execute "autocmd! ftplugin_user_test"'
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
  end

  describe 'let'
    before
      new
      setf test
    end

    after
      close!
    end

    it 'typical let'
      call ftplugin#user#let('b:foo', 1)
      Expect b:foo == 1
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
      let b:foo = 1
      call ftplugin#user#let('b:foo', 2)
      call ftplugin#user#let('b:foo', 3)
      Expect b:foo == 3
      Expect b:undo_ftplugin =~ 'let b:foo = 1'
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
  end
end
