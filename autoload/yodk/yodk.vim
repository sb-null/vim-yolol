" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim  

" run runs the yodk format command for the given target file and returns
" the output of the executed command. Target is the real file to be formatted.
function! yodk#fmt#run(bin_name, target)
  let l:cmd = s:fmt_cmd(a:bin_name, a:target)
  if empty(l:cmd)
    return
  endif
  return go#util#Exec(l:cmd)
endfunction 

" run runs the yodk verify command for the given target file and returns
" the output of the executed command. Target is the real file to be formatted.
function! yodk#verify#run(bin_name, target)
  let l:cmd = s:verify_cmd(a:bin_name, a:target)
  if empty(l:cmd)
    return
  endif
  return go#util#Exec(l:cmd)
endfunction 

" run runs the yodk optimize command for the given target file and returns
" the output of the executed command. Target is the real file to be formatted.
function! yodk#optimize#run(bin_name, target)
  let l:cmd = s:optimize_cmd(a:bin_name, a:target)
  if empty(l:cmd)
    return
  endif
  return go#util#Exec(l:cmd)
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
