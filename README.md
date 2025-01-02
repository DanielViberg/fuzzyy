# Fuzzyy

A fuzzy picker for files, strings, help documents and many other things.

It utilizes Vim's native matchfuzzypos function and popup window feature.

Fuzzyy strives to provide an out-of-box experience by using pre-installed
programs to handle complex tasks.

## Screenshots

![screenshot](https://github.com/Donaldttt/resources/blob/main/fuzzyy/demo.png)

[gif](https://github.com/Donaldttt/resources/blob/main/fuzzyy/demo.gif)

## Requirements

- Vim >= 9.0 (there is an old vim8 branch, which works but is no longer maintained)

## Suggested dependencies
- [ripgrep](https://github.com/BurntSushi/ripgrep) (used for FuzzyGrep and
  FuzzyFiles if installed, faster than the defaults and respects gitignore)
- [vim-devicons](https://github.com/ryanoasis/vim-devicons) (used to show
  [devicons](https://devicon.dev/) when listing files if installed)

## Optional dependencies
- [ag](https://github.com/ggreer/the_silver_searcher) (used for FuzzyGrep if
  ripgrep not installed)
- [fd](https://github.com/sharkdp/fd) (used for FuzzyFiles if ripgrep not installed)
- [git](https://git-scm.com/) (used for FuzzyGrep and FuzzyFiles when inside git
  repo and no alternative dependency installed)

## Install

Any plugin manager will work, or you can use Vim's built-in package support:

For vim-plug
```vim
Plug 'Donaldttt/fuzzyy'
```

As Vim package
```
git clone https://github.com/Donaldttt/fuzzyy ~/.vim/pack/Donaldttt/start/fuzzyy
```

## Commands

| Command         | Description                    | Default mapping |
| ---             | ---                            | ---            |
| FuzzyFiles      | search files in project        | \<leader>ff    |
| FuzzyBuffers    | search opened buffers          | \<leader>fb    |
| FuzzyGrep \<args> | grep string in project. if argument is given, it will search the \<args> | \<leader>fg    |
| FuzzyMru        | search the most recent used files | \<leader>fm    |
| FuzzyMruCwd     | search the most recent used files in the current working directory | None   |
| FuzzyInBuffer  \<args> | search lines in current buffer. if argument is given, it will search the \<args> | None    |
| FuzzyHelp       | search :help documents         | None    |
| FuzzyColors     | search installed colorscheme   | None    |
| FuzzyCommands   | search commands                | None    |
| FuzzyCmdHistory |  search command history  | None    |
| FuzzyHighlights | search highlights              | None    |
| FuzzyGitFiles   |  like FuzzyFiles but only shows file in git project  | None    |

- For FuzzyGrep and FuzzyInBuffer, you can define a keymap like this to search the
word under cursor.
    ```vim
        nnoremap <leader>fw :FuzzyGrep <C-R><C-W><CR>
    ```
- FuzzyGrep requires any of `rg`, `ag`, `grep` or `FINDSTR` command.

- FuzzyFiles uses `find` command on UNIX or PowerShell's `Get-ChildItem` on Windows.
  If `rg` of `fd` are installed they will be used instead, with `rg` preferred.

## Navigation

Arrow keys or `ctrl + p`/ `ctrl + n` moves up/down the menu

`ctrl + u`/`ctrl + d` moves up/down the buffer by half page in preview window

`ctrl + i`/`ctrl + f` moves up/down the buffer by one line in preview window

You can set `g:fuzzyy_keymaps` to change these defaults.

### Command Specific keymaps
- FuzzyHighlights
    - `ctrl + k` toggle white preview background color
    - `Enter` will copy selected highlight

- FuzzyMru/FuzzyMruCwd
    - `ctrl + k` toggle between all MRU files and cwd only

- FuzzyBuffers, FuzzyMru, FuzzyFiles, FuzzyGitFiles
    - `ctrl + s` open selected file in horizontal spliting
    - `ctrl + v` open selected file in vertical spliting
    - `ctrl + t` open selected file in new tab page

## Default mappings

You can set `g:fuzzyy_enable_mappings = 0` to disable default mappings

```vim
nnoremap <silent> <leader>ff :FuzzyFiles<CR>
nnoremap <silent> <leader>fg :FuzzyGrep<CR>
nnoremap <silent> <leader>fb :FuzzyBuffers<CR>
nnoremap <silent> <leader>fm :FuzzyMru<CR>
```

## Options

```vim
" Set to 0 to disable default keybindings
" Default to 1
let g:fuzzyy_enable_mappings = 0

" Show devicons when using FuzzyFiles or FuzzyBuffers
" Requires vim-devicons
" Default to 1 if vim-devicons is installed, 0 otherwise
let g:fuzzyy_devicons = 1

" Enable dropdown theme (prompt at top rather than bottom)
" Default to 0
let g:fuzzyy_dropdown = 0

" Fuzzyy avoids opening files in windows containing special buffers, like
" buffers created by file explorer plugins or help and quickfix buffers.
" You can use this to set up some exceptions, the match is on filetype.
" Defaults to ['netrw'] (Netrw is Vim's built-in file explorer plugin)
let g:fuzzyy_reuse_windows = ['netrw']
" Example usage
let g:fuzzyy_reuse_windows = ['netrw', 'bufexplorer', 'mru']

" Make FuzzyFiles & FuzzyGrep respect .gitignore
" only work when
" 1. inside a git repository and git is installed
" 2. or either rg or fd is installed for FuzzyFiles
" 3. or either rg or ag is installed for FuzzyGrep
" Default to 1
let g:fuzzyy_respect_gitignore = 1
" This option can also be set specifically for FuzzyFiles and/or FuzzyGrep using
" g:fuzzyy_files_respect_gitignore and g:fuzzyy_grep_respect_gitignore

" Make FuzzyFiles & FuzzyGrep include hidden files
" Only applied when
" 1. rg, fd or PowerShell Get-ChildItem used with FuzzyFiles
" 2. rg or ag used with FuzzyGrep
" Default to 1
let g:fuzzyy_include_hidden = 1
" This option can also be set specifically for FuzzyFiles and/or FuzzyGrep using
" g:fuzzyy_files_include_hidden and g:fuzzyy_grep_include_hidden

" Make FuzzyFiles & FuzzyGrep follow symbolic links
" Not applied when using git-ls-files, git-grep or FINDSTR
" Default to 0
let g:fuzzyy_files_follow_symlinks = 0
" This option can also be set specifically for FuzzyFiles and/or FuzzyGrep using
" g:fuzzyy_files_follow_symlinks and g:fuzzyy_grep_follow_symlinks

" Make FuzzyFiles, FuzzyGrep, and FuzzyMru always exclude files/directories
" This applies whether .gitignore is respected or not
" The following are the defaults
let g:fuzzyy_exclude_file = ['*.swp', 'tags']
let g:fuzzyy_exclude_dir = ['.git', '.hg', '.svn']
" Set options specifically for FuzzyFiles, FuzzyGrep, and FuzzyMru using
" g:fuzzyy_files_exclude_file, g:fuzzyy_grep_exclude_file etc.

" Add custom ripgrep options for FuzzyFiles & FuzzyGrep
" These are appended to the generated options
" Default to []
let g:fuzzyy_ripgrep_options = []
" Example usage
let g:fuzzyy_ripgrep_options = [
  \ "--no-config",
  \ "--max-filesize=1M",
  \ "--no-ignore-parent",
  \ "--ignore-file " . expand('~/.ignore')
  \ ]
" This option can also be set specifically for FuzzyFiles and/or FuzzyGrep using
" g:fuzzyy_files_ripgrep_options and g:fuzzyy_grep_ripgrep_options

" Change navigation keymaps
" The following is the default
let g:fuzzyy_keymaps = {
\     'menu_up': ["\<c-p>", "\<Up>"],
\     'menu_down': ["\<c-n>", "\<Down>"],
\     'menu_select': ["\<CR>"],
\     'preview_up': ["\<c-i>"],
\     'preview_down': ["\<c-f>"],
\     'preview_up_half_page': ["\<c-u>"],
\     'preview_down_half_page': ["\<c-d>"],
\     'cursor_begining': ["\<c-a>"],          " move cursor to the begining of the line in the prompt
\     'cursor_end': ["\<c-e>"],               " move cursor to the end of the line in the prompt
\     'backspace': ["\<bs>"],
\     'delete_all': ["\<c-k>"],               " delete whole line of the prompt
\     'delete_prefix': [],                    " delete to the start of the line
\     'exit': ["\<Esc>", "\<c-c>", "\<c-[>"], " exit fuzzyy
\ }

" FuzzyBuffers will exclude the buffers in this list. Buffers not included in
" Vim's buffer list are excluded by default, so this is only necessary for
" buffers included in Vim's buffer list, but you want hidden by FuzzyBuffers
" default to []
let g:fuzzyy_buffers_exclude = []

" FuzzyBuffer keymap for commands speicific to FuzzyBuffers
" default to is the following
let g:fuzzyy_buffers_keymap = {
\    'delete_buffer': "",
\    'close_buffer': "\<c-l>",
\ }

" window layout configuraton
" you can override it by setting g:fuzzyy_window_layout
" e.g. You can disable preview window for FuzzyFiles commands by doing this:
" let g:fuzzyy_window_layout = { 'files': { 'preview': 0 } }
" or you change the width of the preview window for FuzzyFiles by doing this:
" let g:fuzzyy_window_layout = { 'files': { 'preview_ratio': 0.6 } }
" Allowed options and their defaults are:
"     'preview': 0,         " 1 means enable preview window, 0 means disable
"     'preview_ratio': 0.5, " 0.5 means preview window will take 50% of the layout
"     'width': 0.8,         " 0.8 means total width of the layout will take 80% of the screen
"     'height': 0.8,        " 0.8 means total height of the layout will take 80% of the screen
"     'xoffset': v:none     " x offset of the windows, 0.1 means 10% from left of the screen
"     'yoffset': v:none     " x offset of the windows, 0.1 means 10% from top of the screen
" x and y offsets are by default calculated to center the windows on the screen
" width, height, and x and y offsets > 0 and < 1 are resolved as percentages
" width, height, and x and y offsets >= 1 are fixed numbers of lines and cols
" Default window layout configuration is:
let g:fuzzyy_window_layout = {
\    'files': {
\        'preview': 1,
\    },
\    'grep': {
\        'preview': 1,
\    },
\    'buffers': {
\        'preview': 1,
\    },
\    'mru': {
\        'preview': 1,
\    },
\    'highlights': {
\        'preview': 1,
\    },
\    'cmdhistory': {
\        'width': 0.6,
\    },
\    'colors': {
\        'width': 0.25,
\        'xoffset': 0.7,
\    },
\    'commands': {
\        'width': 0.4,
\    },
\    help: {
\        'preview': 1,
\        'preview_ratio': 0.6 # reasonable default for a laptop to avoid wrapping
\    },
\    'inbuffer': {
\        'width': 0.7,
\    },
\ }

" It is also possible to modify the colors used for highlighting
" The defaults are shown below, you can change them in your vimrc
" See :help :highlight if you are unfamiliar with Vim highlighting
highlight default link fuzzyyCursor Search
highlight default link fuzzyyNormal Normal
highlight default link fuzzyyBorder Normal
highlight default link fuzzyyMatching Special
highlight default link fuzzyyPreviewMatch CurSearch
```
