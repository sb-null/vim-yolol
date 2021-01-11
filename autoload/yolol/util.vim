" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim  

" Get all lines in the buffer as a a list.
function! yolol#util#GetLines()
  let buf = getline(1, '$')

  if &encoding != 'utf-8'
    let buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
  endif

    if &l:fileformat == 'dos'
    " XXX: line2byte() depend on 'fileformat' option.
    " so if fileformat is 'dos', 'buf' must include '\r'.
    let buf = map(buf, 'v:val."\r"')
  endif

  return buf
endfunction  

" CheckBinPath checks whether the given binary exists or not 
" and returns the path of the binary,
function! yolol#util#CheckBinPath(binpath) abort
  " remove whitespaces if user applied something 
  let binpath = substitute(a:binpath, '^\s*\(.\{-}\)\s*$', '\1', '') 

  if executable(binpath)
    if exists('*exepath')
      let binpath = exepath(binpath)
    endif

    return binpath
  endif  
endfunction

function! yolol#util#ShellError() abort
  return v:shell_error
endfunction

" Run a shell command.
" 
" It will temporary set the shell to /bin/sh for Unix-like systems if possible,
" so that we always use a standard POSIX-compatible Bourne shell (and not e.g.
" csh, fish, etc.) See #988 and #1276.
function! s:system(cmd, ...) abort
  " Preserve original shell, shellredir and shellcmdflag values
  let l:shell = &shell
  let l:shellredir = &shellredir
  let l:shellcmdflag = &shellcmdflag

  if executable('/bin/sh')
    set shell=/bin/sh shellredir=>%s\ 2>&1 shellcmdflag=-c
  endif

  try
    return call('system', [a:cmd] + a:000)
  finally
    " Restore original values
    let &shell = l:shell
    let &shellredir = l:shellredir
    let &shellcmdflag = l:shellcmdflag
  endtry
endfunction    

" Shelljoin returns a shell-safe string representation of arglist. The
 " {special} argument of shellescape() may optionally be passed.
function! yolol#util#Shelljoin(arglist, ...) abort
  try
    let ssl_save = &shellslash
    set noshellslash
    if a:0
      return join(map(copy(a:arglist), 'shellescape(v:val, ' . a:1 . ')'), ' ')
    endif

    return join(map(copy(a:arglist), 'shellescape(v:val)'), ' ')
  finally
    let &shellslash = ssl_save
  endtry
endfunction   

" Exec runs a shell command "cmd", which must be a list, one argument per item.
" Every list entry will be automatically shell-escaped
" Every other argument is passed to stdin.
function! yolol#util#Exec(cmd, ...) abort
  if len(a:cmd) == 0
    call yolol#util#EchoError("yolol#util#Exec() called with empty a:cmd")
    return ['', 1]
  endif

  let l:bin = a:cmd[0]

  " CheckBinPath will show a warning for us.
  let l:bin = yolol#util#CheckBinPath(l:bin)
  if empty(l:bin)
    return ['', 1]
  endif
  " Finally execute the command using the full, resolved path. Do not pass the
  " unmodified command as the correct program might not exist in $PATH.
  return call('s:exec', [[l:bin] + a:cmd[1:]] + a:000)
endfunction 

function! yolol#util#Chdir(dir) abort
  if !exists('*chdir')
    let l:olddir = getcwd()
    let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
    execute cd . fnameescape(a:dir)
    return l:olddir
  endif
  return chdir(a:dir)
endfunction

" yolol#util#SetEnv takes the name of an environment variable and what its value
" " should be and returns a function that will restore it to its original value.
function! yolol#util#SetEnv(name, value) abort
  let l:state = {}

  if len(a:name) == 0
    return function('s:noop', [], l:state)
  endif

  let l:remove = 0

  if exists('$' . a:name)
    let l:oldvalue = eval('$' . a:name)
  else
    let l:remove = 1
  endif

  " wrap the value in single quotes so that it will work on windows when there
  " are backslashes present in the value (e.g. $PATH).
  call execute('let $' . a:name . " = '" . a:value . "'")
  if l:remove
    return function('s:unset', [a:name], l:state)
  endif

  return function('yolol#util#SetEnv', [a:name, l:oldvalue], l:state)
endfunction  

function! s:exec(cmd, ...) abort
  let l:bin = a:cmd[0]
  let l:cmd = yolol#util#Shelljoin([l:bin] + a:cmd[1:])
  "call yolol#util#EchoInfo('shell command: ' . l:cmd)
  let l:out = call('s:system', [l:cmd] + a:000)
  return [l:out, yolol#util#ShellError()]
endfunction

" The message can be a list or string; every line with be :echomsg'd separately.
function! s:echo(msg, hi)
  let l:msg = []
  if type(a:msg) != type([])
    let l:msg = split(a:msg, "\n")
  else
    let l:msg = a:msg
  endif

  " Tabs display as ^I or <09>, so manually expand them.
  let l:msg = map(l:msg, 'substitute(v:val, "\t", "        ", "")')

  exe 'echohl ' . a:hi
  for line in l:msg
    echom "vim-yolol: " . line
  endfor
  echohl None
endfunction 

" open browser
function! yolol#util#PlayBrowserCommand() abort
  if executable('xdg-open')
    let yolol_play_browser_command = 'xdg-open %URL%'
  elseif executable('firefox')
    let yolol_play_browser_command = 'firefox %URL% &'
  elseif executable('chromium')
    let yolol_play_browser_command = 'chromium %URL% &'
  else
    let yolol_play_browser_command = ''
  endif
  return get(g:, 'yolol_play_browser_command', yolol_play_browser_command)
endfunction  

" open browser
function! yolol#util#OpenBrowser(url) abort
  let l:cmd = yolol#util#PlayBrowserCommand()
  if len(l:cmd) == 0
    redraw
    echohl WarningMsg
    echo "It seems that you don't have general web browser. Open URL below."
    echohl None
    echo a:url
    return
  endif
  " if setting starts with a !.
  if l:cmd =~ '^!'
    let l:cmd = substitute(l:cmd, '%URL%', '\=escape(shellescape(a:url), "#")', 'g')
    silent! exec l:cmd
  elseif cmd =~ '^:[A-Z]'
    let l:cmd = substitute(l:cmd, '%URL%', '\=escape(a:url,"#")', 'g')
    exec l:cmd
  else
    let l:cmd = substitute(l:cmd, '%URL%', '\=shellescape(a:url)', 'g')
    call yolol#util#System(l:cmd)
  endif
endfunction                                                                                                                                                                                                                                               

" System runs a shell command "str". Every arguments after "str" is passed to stdin.
function! yolol#util#System(str, ...) abort
  return call('s:system', [a:str] + a:000)
endfunction  

" Join joins any number of path elements into a single path, adding a
" " Separator if necessary and returns the result
function! yolol#util#Join(...) abort
  return join(a:000, '/')
endfunction 

function! yolol#util#EchoSuccess(msg)
  call s:echo(a:msg, 'Function')
endfunction
function! yolol#util#EchoError(msg)
  call s:echo(a:msg, 'ErrorMsg')
endfunction
function! yolol#util#EchoWarning(msg)
  call s:echo(a:msg, 'WarningMsg')
endfunction
function! yolol#util#EchoProgress(msg)
  redraw
  call s:echo(a:msg, 'Identifier')
endfunction
function! yolol#util#EchoInfo(msg)
  call s:echo(a:msg, 'Debug')
endfunction

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save  
