" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

let s:current_dir = expand('<sfile>:p:h')

function! yolol#yodk#Format() abort
  let binPath = s:current_dir[0:-15] . "/bin/yodk"
  let l:curw = winsaveview()

  " Write current unsaved buffer to a temp file
  let l:tmpname = tempname() . '.yolol' 
  call writefile(yolol#util#GetLines(), l:tmpname)

  let current_col = col('.')
  let [l:out, l:err] = yolol#yodk#fmt(binPath, l:tmpname)
  let line_offset = len(readfile(l:tmpname)) - line('$')
  let l:orig_line = getline('.')

  if l:err == 0
    call yolol#yodk#update_file(l:tmpname, expand('%'))
  endif

  call delete(l:tmpname)

  call winrestview(l:curw)

  " be smart and jump to the line the new statement was added/removed and
  " " adjust the column within the line
  let l:lineno = line('.') + line_offset
  call cursor(l:lineno, current_col + (len(getline(l:lineno)) - len(l:orig_line))) 
  syntax sync fromstart
endfunction

" update_file updates the target file with the given formatted source
function! yolol#yodk#update_file(source, target)
  " remove undo point caused via BufWritePre
  try | silent undojoin | catch | endtry
  
  let old_fileformat = &fileformat
  if exists("*getfperm")
    " save file permissions
    let original_fperm = getfperm(a:target)
  endif

  call rename(a:source, a:target)

  " restore file permissions
  if exists("*setfperm") && original_fperm != ''
    call setfperm(a:target , original_fperm)
  endif

  " reload buffer to reflect latest changes
  silent edit!
  "call go#lsp#DidChange(expand(a:target, ':p'))
  let &fileformat = old_fileformat
  let &syntax = &syntax

  "call yolol#fmt#CleanErrors()
endfunction 

" run runs the yolol format command for the given target file and returns
" the output of the executed command. Target is the real file to be formatted.
function! yolol#yodk#fmt(bin_name, target)
  let l:cmd = s:fmt_cmd(a:bin_name, a:target)
  if empty(l:cmd)
    return
  endif
  return yolol#util#Exec(l:cmd)
endfunction 

" run runs the yolol verify command for the given target file and returns
" the output of the executed command. Target is the real file to be formatted.
function! yolol#yodk#verify(bin_name, target)
  let l:cmd = s:verify_cmd(a:bin_name, a:target)
  if empty(l:cmd)
    return
  endif
  return yolol#util#Exec(l:cmd)
endfunction 

" run runs the yolol optimize command for the given target file and returns
" the output of the executed command. Target is the real file to be formatted.
function! yolol#yodk#optimize(bin_name, target)
  let l:cmd = s:optimize_cmd(a:bin_name, a:target)
  if empty(l:cmd)
    return
  endif
  return yolol#util#Exec(l:cmd)
endfunction 

" fmt_cmd returns the command to run as a list.
function! s:fmt_cmd(bin_name, target)
  let l:cmd = [a:bin_name, 'format']
  call add(cmd, a:target)
  return cmd
endfunction   

" verify_cmd returns the command to run as a list.
function! s:verify_cmd(bin_name, target)
  let l:cmd = [a:bin_name, 'verify']
  call add(cmd, a:target)
  return cmd
endfunction   

" optimize_cmd returns the command to run as a list.
function! s:optimize_cmd(bin_name, target)
  let l:cmd = [a:bin_name, 'optimize']
  call add(cmd, a:target)
  return cmd
endfunction   

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save  
