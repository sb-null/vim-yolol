" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

let s:templatepath = yolol#util#Join(expand('<sfile>:p:h:h:h'), '.github', 'ISSUE_TEMPLATE.md')

function! yolol#issue#New() abort
  let body = yolol#uri#Encode(s:issuebody())
  let url = "https://github.com/sb-null/vim_yolol/issues/new?body=" . l:body
  call yolol#util#OpenBrowser(l:url)
endfunction  

function! s:issuebody() abort
  let lines = readfile(s:templatepath)

  let rtrimpat = '[[:space:]]\+$'
  let body = []
  let body = add(body, "\n#### vim_yolol configuration:\n<details><summary>vim-yolol configuration</summary><br><pre>")  

  let body = add(body, '</pre></details>') 

  let body = add(body, printf("\n#### filetype detection configuration:\n<details><summary>filetype detection</summary><br><pre>%s", execute('filetype')))        
  let body = add(body, '</pre></details>')   
  let body = add(body, '\n#### Yolol code\n<code>')   
  " tbd add yolol code
  let body = add(body, '</code>')   
  return join(body, "\n")  
endfunction  

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save
