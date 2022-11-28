# Dependencies

The dependencies should installed by yourself.
Automatic LSP installer is not preferred.
However none of them are hard-dependencies.

## `python`

1. `python`.
2. `debugpy`: this module should be included by the `python` at the top of your `$PATH`.
3. `ipython`
4. `yapf`
5. `flake8`
6. `pyright`

## `r`

1. `r-language-server`: this is a R package that should be installed by the `r` at the top of your `$PATH`
2. `radian`

## `lua`

1. `lua-language-server`
2. `stylua`
3. `selene`

## `vimscript`

1. `vim-language-server`

## `markdown`

1. `yarn`: this is required to install `markdown-previem.nvim`.
2. `prettierd`
3. `glow`

## `sql`

1. `sqls`
2. `sqlfluff`

## `bash`

1. `bash-language-server`
2. `shellcheck`

## `latex`

1. `texlab`
2. `chktex`: `texlive` ships with this, so no need to install itself by yourself.
3. `latexindent`: while `texlive` ships this for you, `perl` shipped by macOS cannot
run this program, so I use a `homebrew` installed `latexindent` instead.

## `cpp`

1. `clangd`: Apple's `xcode` command line tools ship this for you.

## general purpose

1. `codespell`
2. `universal-ctags`

# Keymaps

NOTE: this only includes keymaps defined by myself,
and some of the default plugins keymaps
that I used frequently.

The `<Leader>` key is `<Space>`,
the `<LocalLeader>` key is `<Space><Space>` or `\`.

## Builtin

### Movement

| Mode | LHS     | RHS/Functionality                 |
|------|---------|-----------------------------------|
| i    | `<C-b>` | `<Left>`                          |
| i    | `<C-p>` | `<Up>`                            |
| i    | `<C-f>` | `<Right>`                         |
| i    | `<C-n>` | `<Down>`                          |
| i    | `<C-a>` | `<Home>`                          |
| i    | `<C-e>` | `<End>`                           |
| i    | `<C-h>` | `<Backspace>`                     |
| i    | `<C-k>` | Del chars from cursor to line end |
| ivt  | `jk`    | Switch to normal mode             |

### Window

| Mode | LHS           | RHS/Functionality              |
|------|---------------|--------------------------------|
| n    | `<A-f>`       | Move current win to prev tab   |
| n    | `<A-b>`       | Move current win to next tab   |
| n    | `<A-w>`       | Go to next win                 |
| n    | `<A-p>`       | Go to Prev win                 |
| n    | `<A-t>`       | Move this win to new tab       |
| n    | `<A-q>`       | Del this win                   |
| n    | `<A-v>`       | Vertically split current win   |
| n    | `<A-s>`       | Horizontally split current win |
| n    | `<A-h>`       | Go to win to the left          |
| n    | `<A-j>`       | Go to win to the below         |
| n    | `<A-k>`       | Go to win to the above         |
| n    | `<A-l>`       | Go to win to the right         |
| n    | `<A-H>`       | Move current win to the left   |
| n    | `<A-J>`       | Move current win to the below  |
| n    | `<A-K>`       | Move current win to the above  |
| n    | `<A-L>`       | Move current win to the right  |
| n    | `<A-o>`       | Make current win the only win  |
| n    | `<A-=>`       | Balance the win height/width   |
| n    | `<A-]>`       | Downward scroll the float win  |
| n    | `<A-[>`       | Upward scroll the float win    |
| n    | `<Leader>wf`  | Move current win to prev tab   |
| n    | `<Leader>wb`  | Move current win to next tab   |
| n    | `<Leader>ww`  | Go to next win                 |
| n    | `<Leader>wp`  | Go to Prev win                 |
| n    | `<Leader>wT`  | Move this win to new tab       |
| n    | `<Leader>wq`  | Del this win                   |
| n    | `<Leader>wv`  | Vertically split current win   |
| n    | `<Leader>ws`  | Horizontally split current win |
| n    | `<Leader>wh`  | Go to win to the left          |
| n    | `<Leader>wj`  | Go to win to the below         |
| n    | `<Leader>wk`  | Go to win to the above         |
| n    | `<Leader>wl`  | Go to win to the right         |
| n    | `<Leader>wH`  | Move current win to the left   |
| n    | `<Leader>wJ`  | Move current win to the below  |
| n    | `<Leader>wK`  | Move current win to the above  |
| n    | `<Leader>wL`  | Move current win to the right  |
| n    | `<Leader>wo`  | Make current win the only win  |
| n    | `<Leader>w=`  | Balance the win height/width   |
| n    | `<Leader>w]`  | Downward scroll the float win  |
| n    | `<Leader>w[`  | Upward scroll the float win    |
| n    | `<Leader>w\|` | Maximize current win's width   |
| n    | `<Leader>w_`  | Maximize current win's height  |

### Tab

| Mode | LHS              | RHS/Functionality                |
|------|------------------|----------------------------------|
| n    | `<Leader><Tab>n` | Create a new tab                 |
| n    | `<Leader><Tab>c` | Close current tab                |
| n    | `<Leader><Tab>o` | Close other tabs except this one |
| n    | `<Leader><Tab>f` | Go to first tab                  |
| n    | `<Leader><Tab>l` | Go to last tab                   |
| n    | `<Leader><Tab>1` | Go to 1st tab                    |
| n    | `<Leader><Tab>2` | Go to 2nd tab                    |
| n    | `<Leader><Tab>3` | Go to 1st tab                    |
| n    | `<Leader><Tab>4` | Go to 1st tab                    |

### Buffer

| Mode | LHS          | RHS/Functionality      |
|------|--------------|------------------------|
| n    | `<Leader>bd` | Delete current buffer  |
| n    | `<Leader>bw` | Wipeout current buffer |
| n    | `<Leader>bp` | Prev buffer            |
| n    | `<Leader>bn` | Next buffer            |

### Motion

| Mode | LHS  | RHS/Functionality                                         |
|------|------|-----------------------------------------------------------|
| n    | `]b` | Next buffer                                               |
| n    | `[b` | Previous buffer                                           |
| n    | `]q` | Next quickfix list entry                                  |
| n    | `[q` | Prev quickfix list entry                                  |
| n    | `]Q` | Set current quickfix list as newer one in qflist history  |
| n    | `[Q` | Set current quickfix list as older one in qflist history  |
| n    | `]t` | Go to next tag location for currently searched symbol     |
| n    | `[t` | Go to previous tag location for currently searched symbol |

## Miscellenous

| Mode | LHS           | RHS/Functionality                                      |
|------|---------------|--------------------------------------------------------|
| n    | go            | Open URI under cursor                                  |
| n    | `<C-g>`       | `<ESC>`                                                |
| n    | `<Leader>mt`  | search current word from tags file and send to loclist |
| n    | `<Leader>mdc` | Set working dir as current file's dir                  |
| n    | `<Leader>mdu` | Set working dir up one level from current working dir  |
| n    | `<Leader>mc`  | Pick a color scheme                                    |

## UI

### [nvim-notify](https://github.com/rcarriga/nvim-notify)

| Mode | LHS          | RHS/Functionality                   |
|------|--------------|-------------------------------------|
| n    | `<Leader>fn` | Preview notifications via Telescope |

### [Trouble.nvim](https://github.com/folke/trouble.nvim.git)

| Mode | LHS          | RHS/Functionality                                   |
|------|--------------|-----------------------------------------------------|
| n    | `<Leader>xw` | Toggle display of workspace diagnostics via Trouble |
| n    | `<Leader>xd` | Toggle display of document diagnostics via Trouble  |
| n    | `<Leader>xl` | Toggle display of loclist via Trouble               |
| n    | `<Leader>xq` | Toggle display of quickfix list via Trouble         |
| n    | `<Leader>xr` | Toggle display of lsp references via Trouble        |

## Utils

### [Project.nvim](https://github.com/ahmedkhalf/project.nvim)

| Mode | LHS          | RHS/Functionality                  |
|------|--------------|------------------------------------|
| n    | `<Leader>fp` | Show recent projects via Telescope |

### [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

| Mode | LHS          | RHS/Functionality                                          |
|------|--------------|------------------------------------------------------------|
| n    | `<Leader>et` | Toggle file explorer via Nvimtree                          |
| n    | `<Leader>ef` | Toggle file explorer fosusing on current file via Nvimtree |
| n    | `<Leader>er` | Refresh Nvimtree file explorer                             |

### [winshift.nvim](https://github.com/sindrets/winshift.nvim)

| Mode | LHS          | RHS/Functionality        |
|------|--------------|--------------------------|
| n    | `<Leader>wm` | Rearrange windows layout |

## Text Edit

### [mini.comment](https://github.com/echasnovski/mini.nvim)

| Mode | LHS | RHS/Functionality                                            |
|------|-----|--------------------------------------------------------------|
| nv   | gc  | Comment / uncomment the motion / text object / selected text |
| n    | gcc | Comment /uncomment current line                              |
| o    | gc  | Text object: a commented text block                          |

### [dsf.vim](https://github.com/AndrewRadev/dsf.vim)

| Mode | LHS  | RHS/Functionality                                     |
|------|------|-------------------------------------------------------|
| n    | dsf  | Delete a function call, don't delete the arguments    |
| n    | dsnf | Delete next function call, don't delete the arguments |
| n    | csf  | Change a function call, keep arguments the same       |
| n    | csnf | Change next function call, keep arguments the same    |

### [vim-sneak](https://github.com/justinmk/vim-sneak)

| Mode | LHS | RHS/Functionality                       |
|------|-----|-----------------------------------------|
| nvo  | f   | Find the next input character           |
| nvo  | F   | Find the previous input character       |
| nvo  | t   | Guess from `t` vs `f` for vanilla vim   |
| nvo  | T   | Guess from `T` vs `F` for vanilla vim   |
| nv   | s   | Find the next 2 input chars             |
| o    | z   | Motion: Find the next 2 input chars     |
| n    | S   | Find the previous 2 input chars         |
| ov   | Z   | Motion: Find the previous 2 input chars |

### [mini.ai](https://github.com/echasnovski/mini.nvim)

| Mode | LHS  | RHS/Functionality                                             |
|------|------|---------------------------------------------------------------|
| ov   | an   | Text object: find the next following "around" text object     |
| ov   | aN   | Text object: find the previous following "around" text object |
| ov   | in   | Text object: find the next following "inner" text object      |
| ov   | iN   | Text object: find the previous following "inner" text object  |
| nov  | `g[` | Motion: go to the start of the following "around" text object |
| nov  | `g]` | Motion: go to the end of the following "around" text object   |

### [mini.surround](https://github.com/echasnovski/mini.nvim)

| Mode | LHS | RHS/Functionality                                          |
|------|-----|------------------------------------------------------------|
| n    | yss | Add a surround pair for the whole line                     |
| n    | ys  | Add a surround pair for the following motion / text object |
| n    | yS  | Add a surround pair from cursor to line end                |
| v    | S   | Add a surround pair for selected text                      |
| n    | cs  | Change the surround pair                                   |
| n    | ds  | Delete the surround pair                                   |

### [substitute.nvim](https://github.com/gbprod/substitute.nvim)

| Mode | LHS | RHS/Functionality                                                                                      |
|------|-----|--------------------------------------------------------------------------------------------------------|
| nv   | gs  | Substitute the motion / text object / selected text by latest pasted text, don't cut the replaced text |
| n    | gss | Similar to `gs`, operate on the whole line                                                             |
| n    | gS  | Similar to `gs`, operate on text from cursor to line end                                               |

### [vim-textobj-beween](https://github.com/thinca/vim-textobj-between)

| Mode | LHS | RHS/Functionality                                    |
|------|-----|------------------------------------------------------|
| ov   | ab  | Text object: around text between the input character |
| ov   | ib  | Text object: inner text between the input character  |

### [vim-textobj-beween](https://github.com/D4KU/vim-textobj-chainmember)

| Mode | LHS | RHS/Functionality                                     |
|------|-----|-------------------------------------------------------|
| ov   | a.  | Text object: around a chain of chained method calls   |
| ov   | i.  | Text object: inner of a chain of chained method calls |

## Filetype Specific Keymaps

### R

| Mode | LHS          | RHS/Functionality              |
|------|--------------|--------------------------------|
| ov   | `a<Leader>c` | Text objects: a code chunk     |
| ov   | `i<Leader>c` | Text objects: inner code chunk |

### Python
    
| Mode | LHS          | RHS/Functionality              |
|------|--------------|--------------------------------|
| ov   | `a<Leader>c` | Text objects: a code chunk     |
| ov   | `i<Leader>c` | Text objects: inner code chunk |

### Rmarkdown

#### builtin

| Mode | LHS  | RHS/Functionality                |
|------|------|----------------------------------|
| ov   | `ac` | Text object: a code chunk        |
| ov   | `ic` | Text object: inner code chunk    |

#### [dsf.vim](https://github.com/AndrewRadev/dsf.vim)

| Mode | LHS  | RHS/Functionality                |
|------|------|----------------------------------|
| ov   | `ae` | Text object: a function call     |
| ov   | `ie` | Text object: inner function call |

# Other Notes

1. `vim-sneak` defines relatively inconsistent behavior: in normal mode,
use `s/S`, in operator pending mode, use `z/Z`, in visual mode,
use `s/Z`. In normal mode, default mapping `s` is replaced.
In op mode, use `z/Z` is to be compatible with `vim-surround` (mappings: `ys/ds/cs`),
in visual mode, use `s/Z` is to be compatible with
folding (mapping: `zf`) and `vim-surround` (mapping: `S`)

9. You need to define your leader key before defining any keymaps.
Otherwise, keymap will not be correctly mapped with your leader key.

10. Note that `tree-sitter` will turn `syntax off`, and `pandoc-syntax` and `pandoc-rmarkdown`
relies on the builtin `syntax`, so we need to load `config.pandoc` before we load `config.treesitter`

11. `vim-matchup` will (intentionally) hide the status-line if the matched pair are spanned
over entire screen to show the other side of the pair.
