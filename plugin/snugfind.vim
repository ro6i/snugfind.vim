" a snug wrapper over grep

" 0 - non-verbose mode
" 1 - verbose: will echo the switches and commands to be run
" let g:snugfind_verbose = 0

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
  return "search " . " [case " . (g:snugfind_case_sensitive ? "sensitive" : "insensitive") . "] " . " [" . (g:snugfind_regex ? "regex" : "text") . "]  " . "in: " . g:snugfind_dir
endfunction

function! GetFindSettingsSettings()
  return (g:snugfind_case_sensitive ? "s" : "i") . " " . (g:snugfind_regex ? "r" : "-") . " : " . (g:snugfind_dir == "" ? "." : g:snugfind_dir)
endfunction

if !exists("g:snugfind_exclude_dirs")
  let g:snugfind_exclude_dirs = ''
endif
if !exists("g:snugfind_exclude_files")
  let g:snugfind_exclude_files = ''
endif

function! FindText(interactive, ...)
  let l:is_case_sensitive = g:snugfind_case_sensitive
  let l:is_regex = g:snugfind_regex
  let l:current_dir = (g:snugfind_dir == '' ? get(a:, 2, join(map(copy(g:snugfind_dirs), {key, val -> "'" . val . "'"}), ' ')) : "'" . g:snugfind_dir . "'")
  let l:token = ""
  if a:interactive >= 1
    let l:prompt = (a:interactive == 2 ? "settings" : "search") . " " . (l:is_case_sensitive ? "s" : "i") . " " . (l:is_regex ? "r" : "-") . " : " . (l:current_dir == "" ? "." : l:current_dir) . " " . "> "
    echoh Comment
    call inputsave()
    let l:token = input(l:prompt)
    call inputrestore()
    echoh None
    if empty(l:token)
      redraw
      return
    elseif l:token == ':mode'
      execute "normal! \<esc>" | call ToggleFindRegex(0)
      if a:interactive == 1
        return FindText(1)
      else
        return
      endif
    elseif l:token == ':case'
      execute "normal! \<esc>" | call ToggleFindCaseSensitive(0)
      if a:interactive == 1
        return FindText(1)
      else
        return
      endif
    elseif l:token[0:2] == ':in'
      execute "normal! \<esc>" | call SetFindDir(0, token[4:])
      if a:interactive == 1
        return FindText(1)
      else
        return
      endif
    elseif l:token[0:2] == 'in:'
      let l:parsed = matchlist(l:token, '\vin:(".*"|[^ ]*)[ ]+(.+)')[1:2]
      if len(l:parsed) == 2
        let l:dir = matchstr(l:parsed[0], '\v("\zs.+\ze"|.+)')
        let l:str = l:parsed[1]
        return FindText(0, l:str, l:dir)
      endif
    endif
  else
    if empty(a:1)
      redraw
      return
    endif
    let l:token = a:1
  endif

  if executable("rg")
    let l:grepCommand = 'silent grep! ' . shellescape(l:token)
    let excluded_dirs_args = "-g " . "'" . "!{" . g:snugfind_exclude_dirs . "}" . "'"
    let excluded_files_args = "-g " . "'" . "!{" . g:snugfind_exclude_files . "}" . "'"
    let l:command = l:grepCommand . " --line-buffered " . (l:is_regex ? "" : "--fixed-strings") . " " . (l:is_case_sensitive ? "--case-sensitive" : "--ignore-case") . " " . excluded_dirs_args . " " . excluded_files_args . " " . (l:current_dir == '' ? '.' : l:current_dir)
    set grepprg=rg\ --vimgrep\ --no-heading\ --follow\ --pcre2\ --one-file-system
    set grepformat=%f:%l:%c:%m,%f:%l:%m
  else
    let l:grepCommand = 'silent grep! -r -n --exclude-dir={' . g:snugfind_exclude_dirs . '} --exclude={' . g:snugfind_exclude_files . '} -e ' . shellescape(l:token)
    let l:command = l:grepCommand . " " . (l:is_regex ? "" : "-F") . " " . (l:is_case_sensitive ? "" : "-i") . " " . (l:current_dir == '' ? '.' : "'" . l:current_dir . "'")
  endif

  redraw

  if g:snugfind_verbose == 1
    echom "\n"
    echom l:command
  endif

  let l:cwd_temp = getcwd()
  let @/ = l:token
  execute l:command
  execute 'cd' g:quickfix_base_dir
  copen
  normal! "/" . (l:is_regex ? "" : "\\V") . l:token . "\<CR>"
  let @/ = l:token
  execute 'cd' l:cwd_temp
endfunction

function! FindTextPrompt()
  call FindText(1)
  if exists('*lightline#update')
    call lightline#update()
  endif
endfunction

function! FindTextSettings()
  call FindText(2)
  if exists('*lightline#update')
    call lightline#update()
  endif
endfunction

function! FindTextFlat(text)
  let l:savepoint = g:snugfind_regex
  let g:snugfind_regex = 0
  call FindText(0, a:text)
  let g:snugfind_regex = l:savepoint
endfunction

function! FindTextRegex(text)
  let l:savepoint = g:snugfind_regex
  let g:snugfind_regex = 1
  call FindText(0, a:text)
  let g:snugfind_regex = l:savepoint
endfunction

command! -nargs=+ FindTextExact call FindTextFlat(<q-args>)
