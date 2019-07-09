" a snug wrapper over grep

" 0 - case insensitive
" 1 - case sensitive
" TODO: 2 - smart case
let g:snugfind_case_sensitive = 0
function! ToggleFindCaseSensitive(verbose)
  let g:snugfind_case_sensitive = g:snugfind_case_sensitive ? 0 : 1
  if a:verbose == 1
    echom GetFindSettingsMessage()
  endif
endfunction

let g:snugfind_regex = 0
function! ToggleFindRegex(verbose)
  let g:snugfind_regex = g:snugfind_regex ? 0 : 1
  if a:verbose == 1
    echom GetFindSettingsMessage()
  endif
endfunction

function! GetFindSettingsMessage()
  return "search " . "case " . (g:snugfind_case_sensitive ? "sensitive" : "insensitive") . " " . (g:snugfind_regex ? "regex" : "text")
endfunction

if !exists("g:snugfind_exclude_dir")
  let g:snugfind_exclude_dir = ''
endif
if !exists("g:snugfind_exclude")
  let g:snugfind_exclude = ''
endif

function! FindText(interactive, ...)
  let l:is_case_sensitive = a:interactive ? g:snugfind_case_sensitive : 0
  let l:is_regex = a:interactive ? g:snugfind_regex : 0
  let l:token = ""
  if a:interactive == 1
    let l:prompt = "search " . (l:is_case_sensitive ? "s" : ">") . (l:is_regex ? "r" : ">") . "> "
    echoh Comment
    call inputsave()
    let l:token = input(l:prompt)
    call inputrestore()
    echoh None
    if empty(token)
      return
    elseif token == 'mode!'
      execute "normal! \<esc>" | call ToggleFindRegex(0)
      return FindText(1)
    elseif token == 'case!'
      execute "normal! \<esc>" | call ToggleFindCaseSensitive(0)
      return FindText(1)
    endif
  else
    if empty(a:1)
      return
    endif
    let l:token = a:1
    let l:is_regex = 0
  endif

  if executable("rg")
    let l:grepCommand = 'silent grep! ' . shellescape(l:token)
    let l:command = l:grepCommand . " " . (l:is_regex ? "" : "--fixed-strings") . " " . (l:is_case_sensitive ? "" : "--case-sensitive")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
  else
    let l:grepCommand = 'silent grep! -r -n --exclude-dir={' . g:snugfind_exclude_dir . '} --exclude={' . g:snugfind_exclude . '} . -e ' . shellescape(l:token)
    let l:command = l:grepCommand . " " . (l:is_regex ? "" : "-F") . " " . (l:is_case_sensitive ? "" : "-i")
  endif

  let @/ = l:token
  execute l:command | copen | normal! "/" . (l:is_regex ? "" : "\\V") . l:token . "\<CR>"
  let @/ = l:token
endfunction

function! FindTextPrompt()
  call FindText(1)
endfunction

function! FindTextFlat(text)
  call FindText(0, a:text)
endfunction

command! -nargs=+ FindTextExact call FindTextFlat(<q-args>)
