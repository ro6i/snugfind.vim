# snugfind.vim
A very basic plugin for VIM to make searching in the current directory more convenient. It uses the `grep` command under the hood.

Goals:
1. Make sure the search works without any escaping issues
2. Bring it up easily as a prompt (retaining prompt history comes for free)
3. Customize the search to be able to switch case sensitivity and mode (exact or regex)

## Installation

### [vim-plug](https://github.com/junegunn/vim-plug)
1. Add the following configuration to your `.vimrc`.

        Plug 'ro6i/snugfind.vim'

2. Install with `:PlugInstall`.

## Using
Start the search prompt by entering a command `:call FindTextPrompt ()` or by using a more convenient binding _(see below)_.
Switch between case sensitive/insensitive by either entering a command `:call ToggleFindCaseSensitive()` or by entering `case!` when in the prompt.
Switch between exact/regex by either entering a command `:call ToggleFindRegex()` or by entering `mode!` when in the prompt.

### Convenient bindings

Enter `\f` in _normal_ mode to bring up the search prompt:
```
nnoremap <silent> <Leader>f :call FindTextPrompt()<CR>
```

Enter `\\` in visual mode (when you have some text selected) to run the search and show the result in _quick-fix_ buffer.
Press 
```
vnoremap <silent> <Leader><Leader> y:FindTextExact <C-R>"<CR>
```
this will silently copy the text that is currently selected (no line breaks) into the default register and use it as an input.
