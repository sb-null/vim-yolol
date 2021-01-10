" vim-yolol

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim  

function! s:checkVersion() abort
  let l:unsupported = 0
  let l:unsupported = !has('patch-8.0.1453')

  if l:unsupported == 1
    echohl Error
    echom "vim-go requires at least Vim 8.0.1453 or Neovim 0.4.0, but you're using an older version."
    echom "Please update your Vim for the best vim-go experience."
    echom "If you really want to continue you can set this to make the error go away:"
    echom "    let g:go_version_warning = 0"
    echom "Note that some features may error out or behave incorrectly."
    echom "Please do not report bugs unless you're using at least Vim 8.0.1453 or Neovim 0.4.0."
    echohl None

    " Make sure people see this.
    sleep
    2
  endif
endfunction

call s:checkVersion()

" NOTE(bc): varying the binary name and the tail of the import path does not
" yet work in module aware mode.
let s:packages = {
  \ 'yodk':        ['https://github.com/dbaumgarten/yodk/releases/latest/download/yodk-linux.zip'],
\ }

" These commands are available on any filetypes
command! -nargs=* -complete=customlist,s:complete YololInstallBinaries call s:YololInstallBinaries()
command! -nargs=* -complete=customlist,s:complete YololUpdateBinaries  call s:YololInstallBinaries()  

" YololInstallBinaries downloads and installs binaries defined in s:packages to
" s:packages
 " packages in the unnamed arguments.
function! s:YololInstallBinaries()

  let err = s:CheckBinaries()
  if err != 0
    return
  endif


  let l:cwd = getcwd()
  let l:binPath = l:cwd . '/bin'
  " vim's executable path is looking in PATH so add our go_bin path to it
  let Restore_path = yolol#util#SetEnv('PATH', l:binPath . ":" . $PATH) 

  for [l:name, l:downloadUrl] in items(s:packages)
    let l:get_cmd = ['curl', '-fSL', '-o', l:binPath . '/latest.zip', l:downloadUrl[0]]
    let l:unpack_cmd = ['unzip', '-o', 'latest.zip']
    let l:del_cmd = ['rm', '-f', 'latest.zip']

    " download the binary
    call yolol#util#Chdir(l:binPath)
    let [l:out, l:err] = yolol#util#Exec(l:get_cmd)
    if l:err
      call yolol#util#EchoError(printf('Error downloading %s: %s', l:downloadUrl, l:out))
    endif
    let [l:out, l:err] = yolol#util#Exec(l:unpack_cmd)
    if l:err
      call yolol#util#EchoError(printf('Error unpacking %s: %s', l:downloadUrl, l:out))
    endif
    let [l:out, l:err] = yolol#util#Exec(l:del_cmd)
    if l:err
      call yolol#util#EchoError(printf('Error deleting %s: %s', l:del_cmd, l:out))
    endif
  endfor

  call call(Restore_path, []) 
  call yolol#util#Chdir(l:cwd)
endfunction



" CheckBinaries checks if the necessary binaries to install the Go tool
" " commands are available.
function! s:CheckBinaries()
  if !executable('curl')
    call yolol#util#EchoError('curl executable not found.')
    return -1
  endif
  if !executable('unzip')
    call yolol#util#EchoError('unzip executable not found.')
    return -1
  endif
endfunction

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim  
