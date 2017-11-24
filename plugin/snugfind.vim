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

let g:snugfind_exclude_dir = 'project,target,.git,.idea,.ensime_cache'
let g:snugfind_exclude = '.tags,.ensime'

function! FindText(interactive, ...)
  let is_case_sensitive = a:interactive ? g:snugfind_case_sensitive : 0
  let is_regex = a:interactive ? g:snugfind_regex : 0
  let token = ""
  if a:interactive == 1
    let prompt = "search " . (is_case_sensitive ? "s" : ">") . (is_regex ? "r" : ">") . "> "
    echoh Comment
    call inputsave()
    let token = input(prompt)
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
    let token = a:1
    let is_regex = 0
  endif

  let grepCommand = 'silent grep! -r -n --exclude-dir={' . g:snugfind_exclude_dir . '} --exclude={' . g:snugfind_exclude . '} . -e '
  let command = grepCommand . shellescape(token) . " " . (is_regex ? "" : "-F") . " " . (is_case_sensitive ? "" : "-i")

  let @/ = token
  execute command | copen | normal! "/" . (is_regex ? "" : "\\V") . token . "\<CR>"
  let @/ = token
endfunction

function! FindTextPrompt()
  call FindText(1)
endfunction

function! FindTextFlat(text)
  call FindText(0, a:text)
endfunction


command! -nargs=+ FindTextExact call FindTextFlat(<q-args>)
