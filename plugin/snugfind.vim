" a snug wrapper over grep

" 0 - non-verbose mode
" 1 - verbose: will echo the switches and commands to be run
let g:snugfind_verbose = 0

" 0 - case insensitive
" 1 - case sensitive
" TODO: 2 - smart case
let g:snugfind_case_sensitive = 0
function! ToggleFindCaseSensitive(verbose)
  let g:snugfind_case_sensitive = g:snugfind_case_sensitive ? 0 : 1
  if a:verbose == 1 || g:snugfind_verbose == 1
    echom GetFindSettingsMessage()
  endif
endfunction

let g:snugfind_regex = 0
function! ToggleFindRegex(verbose)
  let g:snugfind_regex = g:snugfind_regex ? 0 : 1
  if a:verbose == 1 || g:snugfind_verbose == 1
    echom GetFindSettingsMessage()
  endif
endfunction

let g:snugfind_dir = ""
function! SetFindDir(verbose, value)
  let g:snugfind_dir = a:value
  if a:verbose == 1 || g:snugfind_verbose == 1
    echom GetFindSettingsMessage()
  endif
endfunction

function! GetFindSettingsMessage()
  return "search " . "case " . (g:snugfind_case_sensitive ? "sensitive" : "insensitive") . " " . (g:snugfind_regex ? "regex" : "text") . " " . "in:" . g:snugfind_dir
endfunction

if !exists("g:snugfind_exclude_dirs")
  let g:snugfind_exclude_dirs = ''
endif
if !exists("g:snugfind_exclude_files")
  let g:snugfind_exclude_files = ''
endif

function! FindText(interactive, ...)
  let l:is_case_sensitive = a:interactive ? g:snugfind_case_sensitive : 0
  let l:is_regex = a:interactive ? g:snugfind_regex : 0
  let l:current_dir = a:interactive ? g:snugfind_dir : ""
  let l:token = ""
  if a:interactive == 1
    let l:prompt = "search " . (l:is_case_sensitive ? "cs" : "ci") . " " . (l:is_regex ? "r" : "f") . " in:" . (l:current_dir == "" ? "." : l:current_dir) . " " . "> "
    echoh Comment
    call inputsave()
    let l:token = input(l:prompt)
    call inputrestore()
    echoh None
    if empty(l:token)
      return
    elseif l:token == ':mode'
      execute "normal! \<esc>" | call ToggleFindRegex(0)
      return FindText(1)
    elseif l:token == ':case'
      execute "normal! \<esc>" | call ToggleFindCaseSensitive(0)
      return FindText(1)
    elseif l:token[0:2] == ':in'
      execute "normal! \<esc>" | call SetFindDir(1, token[4:])
      echom "DIR: " . token[4:]
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

    " function! s:exclusionArgs(csvals)
    "   if a:csvals == ''
    "     return ''
    "   endif
    "   let stage1 = split(a:csvals, ',')
    "   let stage2 = copy(stage1)
    "   let stage3 = map(stage2, {pos, val -> "-g " . "'" . "!" . val . "'"})
    "   let ignoreList = join(stage3, ' ')
    "   return ignoreList
    " endfunction

    let l:grepCommand = 'silent grep! ' . shellescape(l:token)
    " let excluded_dirs_args = s:exclusionArgs(g:snugfind_exclude_dirs)
    " let excluded_files_args = s:exclusionArgs(g:snugfind_exclude_files)
    let excluded_dirs_args = "-g " . "'" . "!{" . g:snugfind_exclude_dirs . "}" . "'"
    let excluded_files_args = "-g " . "'" . "!{" . g:snugfind_exclude_files . "}" . "'"
    let l:command = l:grepCommand . " --line-buffered " . (l:is_regex ? "" : "--fixed-strings") . " " . (l:is_case_sensitive ? "--case-sensitive" : "--ignore-case") . " " . excluded_dirs_args . " " . excluded_files_args . " " . (l:current_dir == '' ? '.' : "'" . l:current_dir . "'")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
  else
    let l:grepCommand = 'silent grep! -r -n --exclude-dir={' . g:snugfind_exclude_dirs . '} --exclude={' . g:snugfind_exclude_files . '} -e ' . shellescape(l:token)
    let l:command = l:grepCommand . " " . (l:is_regex ? "" : "-F") . " " . (l:is_case_sensitive ? "" : "-i") . " " . (l:current_dir == '' ? '.' : "'" . l:current_dir . "'")
  endif

  if g:snugfind_verbose == 1
    echom "\n"
    echom l:command
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
