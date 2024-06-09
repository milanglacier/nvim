- [Features](#features)
  - [Modern Devtools Integration](#modern-devtools-integration)
  - [Powerful Text Edit Plugins](#powerful-text-edit-plugins)
  - [Tailored for Data Science](#tailored-for-data-science)
  - [Seamless Integration with Vscode](#seamless-integration-with-vscode)
  - [Text Edit keymaps](#text-edit-keymaps)
    - [Align text keymaps](#align-text-keymaps)
    - [Comment keymaps](#comment-keymaps)
    - [Text objects for functions keymaps](#text-objects-for-functions-keymaps)
    - [Quick navigation keymaps](#quick-navigation-keymaps)
    - [Text objects enhancement keymaps](#text-objects-enhancement-keymaps)
    - [Block text movement](#block-text-movement)
    - [Surround pairs keymaps](#surround-pairs-keymaps)
    - [substitution keymaps](#substitution-keymaps)
    - [Other text objects keymaps](#other-text-objects-keymaps)
  - [Treesitter keymaps](#treesitter-keymaps)
    - [Syntax based text objects keymaps](#syntax-based-text-objects-keymaps)
    - [Syntaxa based navigations keymaps](#syntaxa-based-navigations-keymaps)
    - [Miscellenous](#miscellenous)
- [Other Notes](#other-notes)
- [Discussion](#discussion)

# Features

## Modern Devtools Integration

Built on modern devtools including LSP and treesitter. Treesitter delivers
AST-level highlighting, text objects, and navigations, while LSP offers
features like auto completion, go to definition and reference, and code
diagnostics. By harnessing the power of both Ctags and LSP, this configuration
brings a harmonic blend of old-school and modern development tools.

## Powerful Text Edit Plugins

Vim's exceptional text editing capabilities are further amplified by a host of
powerful plugins focusing on text editing. (Remember it is pure text editing
makes vim vim.)

## Tailored for Data Science

This configuration is specifically tailored toward data science toolsets,
including python, R, SQL, Latex, rmarkdown, and quarto.

## Seamless Integration with Vscode

Curated configuration working together with vscode thanks to
[vscode-neovim](https://github.com/vscode-neovim/vscode-neovim). Access all the
familiar neovim keybindings, including translations of equivalent commands in
vscode, even when working with complex graphical content like Jupyter
notebooks. And many neovim plugins, such as treesitter, can be embedded
seamlessly in vscode, allowing for a smooth and uninterrupted workflow.

**NOTE**: If you plan to use this configuration with `vscode-neovim`, please
use the `vscode` branch. If you wish to use neovim both in the terminal
and in vscode, we suggest creating two folders in `~/.config` or your specified
`$XDG_CONFIG` path. One is `~/.config/nvim`, which uses the default
configuration in the `master` branch, and the other is
`~/.config/vscode-neovim`, which uses the configuration in the `vscode`
branch. This takes advantage of the `NVIM_APPNAME` feature in `nvim 0.9`.

Then, Set `vscode-neovim.NVIM_APPNAME` to `vscode-neovim` in vscode settings.

# Keymaps

NOTE: this only includes keymaps defined by myself,
and some of the default plugins keymaps
that I used frequently.

The `<Leader>` key is `<Space>`,
the `<LocalLeader>` key is `<Space><Space>` or `<Backslash>`.

In case you forget the keymaps
you can always use `<Leader>fk` (`:Telescope keymaps`)
to find all keymaps.

## VSCode Neovim keymaps

There are keymaps configured specifically for vscode. Please check for the file
[vscode.lua](./lua/conf/vscode.lua) for details.

## Text Edit keymaps

### Align text keymaps

The following keymaps rely on [vim-easy-align](https://github.com/junegunn/vim-easy-align)

| Mode | LHS | RHS/Functionality                                                 |
| ---- | --- | ----------------------------------------------------------------- |
| nv   | ga  | Align the motion / text object / selected text by input separator |

### Comment keymaps

The following keymaps rely on [mini.comment](https://github.com/echasnovski/mini.nvim)

| Mode | LHS | RHS/Functionality                                            |
| ---- | --- | ------------------------------------------------------------ |
| nv   | gc  | Comment / uncomment the motion / text object / selected text |
| n    | gcc | Comment /uncomment current line                              |
| o    | gc  | Text object: a commented text block                          |

### Text objects for functions keymaps

The following keymaps rely on [dsf.vim](https://github.com/AndrewRadev/dsf.vim)

| Mode | LHS  | RHS/Functionality                                     |
| ---- | ---- | ----------------------------------------------------- |
| n    | dsf  | Delete a function call, don't delete the arguments    |
| n    | dsnf | Delete next function call, don't delete the arguments |
| n    | csf  | Change a function call, keep arguments the same       |
| n    | csnf | Change next function call, keep arguments the same    |

### Quick navigation keymaps

The following keymaps rely on [vim-sneak](https://github.com/justinmk/vim-sneak)

| Mode | LHS | RHS/Functionality                       |
| ---- | --- | --------------------------------------- |
| nvo  | f   | Find the next input character           |
| nvo  | F   | Find the previous input character       |
| nvo  | t   | Guess from `t` vs `f` for vanilla vim   |
| nvo  | T   | Guess from `T` vs `F` for vanilla vim   |
| nv   | s   | Find the next 2 input chars             |
| o    | z   | Motion: Find the next 2 input chars     |
| n    | S   | Find the previous 2 input chars         |
| ov   | Z   | Motion: Find the previous 2 input chars |

### Text objects enhancement keymaps

The following keymaps rely on [mini.ai](https://github.com/echasnovski/mini.nvim)

| Mode | LHS  | RHS/Functionality                                             |
| ---- | ---- | ------------------------------------------------------------- |
| ov   | an   | Text object: find the next following "around" text object     |
| ov   | aN   | Text object: find the previous following "around" text object |
| ov   | in   | Text object: find the next following "inner" text object      |
| ov   | iN   | Text object: find the previous following "inner" text object  |
| nov  | `g(` | Motion: go to the start of the following "around" text object |
| nov  | `g)` | Motion: go to the end of the following "around" text object   |

### Block text movement

The following keymaps rely on [mini.move](https://github.com/echasnovski/mini.nvim)

| Mode | LHS     | RHS/Functionality            |
| ---- | ------- | ---------------------------- |
| v    | `<A-h>` | Move left the block of text  |
| v    | `<A-j>` | Move down the block of text  |
| v    | `<A-k>` | Move up the block of text    |
| v    | `<A-l>` | Move right the block of text |

### Surround pairs keymaps

The following keymaps rely on [mini.surround](https://github.com/echasnovski/mini.nvim)

| Mode | LHS | RHS/Functionality                                          |
| ---- | --- | ---------------------------------------------------------- |
| n    | yss | Add a surround pair for the whole line                     |
| n    | ys  | Add a surround pair for the following motion / text object |
| n    | yS  | Add a surround pair from cursor to line end                |
| v    | S   | Add a surround pair for selected text                      |
| n    | cs  | Change the surround pair                                   |
| n    | ds  | Delete the surround pair                                   |

### substitution keymaps

The following keymaps rely on [substitute.nvim](https://github.com/gbprod/substitute.nvim)

| Mode | LHS | RHS/Functionality                                                                                      |
| ---- | --- | ------------------------------------------------------------------------------------------------------ |
| nv   | gs  | Substitute the motion / text object / selected text by latest pasted text, don't cut the replaced text |
| n    | gss | Similar to `gs`, operate on the whole line                                                             |
| n    | gS  | Similar to `gs`, operate on text from cursor to line end                                               |

### Other text objects keymaps

The following keymaps rely on [vim-textobj-beween](https://github.com/thinca/vim-textobj-between)

| Mode | LHS | RHS/Functionality                                    |
| ---- | --- | ---------------------------------------------------- |
| ov   | ab  | Text object: around text between the input character |
| ov   | ib  | Text object: inner text between the input character  |

The following keymaps rely on [vim-textobj-chainmember](https://github.com/D4KU/vim-textobj-chainmember)

| Mode | LHS | RHS/Functionality                                     |
| ---- | --- | ----------------------------------------------------- |
| ov   | a.  | Text object: around a chain of chained method calls   |
| ov   | i.  | Text object: inner of a chain of chained method calls |

## Treesitter keymaps

### Syntax based text objects keymaps

| Mode | LHS          | RHS/Functionality                           |
| ---- | ------------ | ------------------------------------------- |
| ov   | af           | Text object: around a function definition   |
| ov   | if           | Text object: inner of a function definition |
| ov   | aC           | Text object: around a class definition      |
| ov   | iC           | Text object: inner of a class definition    |
| ov   | ak           | Text object: the same as `aC`               |
| ov   | ik           | Text object: the same as `iC`               |
| ov   | al           | Text object: around a loop                  |
| ov   | il           | Text object: inner of a loop                |
| ov   | ac           | Text object: around if-else conditions      |
| ov   | ic           | Text object: inner of if-else conditions    |
| ov   | ae           | Text object: around a function call         |
| ov   | `a<Leader>a` | Text object: around a parameter(argument)   |
| ov   | `i<Leader>a` | Text object: inner of a parameter(argument) |

### Syntaxa based navigations keymaps

| Mode | LHS          | RHS/Functionality                           |
| ---- | ------------ | ------------------------------------------- |
| n    | `]f`         | Go to the start of next function definition |
| n    | `]<Leader>c` | Go to the start of next class definition    |
| n    | `]k`         | The same as `]<Leader>c`                    |
| n    | `]l`         | Go to the start of next loop                |
| n    | `]c`         | Go to the start of next if-else conditions  |
| n    | `]e`         | Go to the start of next function call       |
| n    | `]a`         | Go to the start of next parameter(argument) |

| Mode | LHS          | RHS/Functionality                         |
| ---- | ------------ | ----------------------------------------- |
| n    | `]F`         | Go to the end of next function definition |
| n    | `]<Leader>C` | Go to the end of next class definition    |
| n    | `]K`         | The same as `]<Leader>C`                  |
| n    | `]L`         | Go to the end of next loop                |
| n    | `]C`         | Go to the end of next if-else conditions  |
| n    | `]E`         | Go to the end of next function call       |
| n    | `]A`         | Go to the end of next parameter(argument) |

| Mode | LHS          | RHS/Functionality                               |
| ---- | ------------ | ----------------------------------------------- |
| n    | `[f`         | Go to the start of previous function definition |
| n    | `[<Leader>c` | Go to the start of previous class definition    |
| n    | `[k`         | The same as `[<Leader>c`                        |
| n    | `[l`         | Go to the start of previous loop                |
| n    | `[c`         | Go to the start of previous if-else conditions  |
| n    | `[e`         | Go to the start of previous function call       |
| n    | `[a`         | Go to the start of previous parameter(argument) |

| Mode | LHS          | RHS/Functionality                             |
| ---- | ------------ | --------------------------------------------- |
| n    | `[F`         | Go to the end of previous function definition |
| n    | `[<Leader>C` | Go to the end of previous class definition    |
| n    | `[K`         | The same as `[<Leader>C`                      |
| n    | `[L`         | Go to the end of previous loop                |
| n    | `[C`         | Go to the end of previous if-else conditions  |
| n    | `[E`         | Go to the end of previous function call       |
| n    | `[A`         | Go to the end of previous parameter(argument) |

### Miscellenous

| Mode | LHS        | RHS/Functionality                                                     |
| ---- | ---------- | --------------------------------------------------------------------- |
| n    | `<CR><CR>` | Start incremental selection (expand region) based on treesitter nodes |
| v    | `<CR>`     | Expand the region based on scope                                      |
| v    | `<Tab>`    | Expand the region based on treesitter node                            |
| v    | `<S-Tab>`  | Shrink the region based on treesitter node                            |

# Other Notes

1. `vim-sneak` defines relatively inconsistent behavior: in normal mode,
   use `s/S`, in operator pending mode, use `z/Z`, in visual mode,
   use `s/Z`. In normal mode, default mapping `s` is replaced.
   In op mode, use `z/Z` is to be compatible with `vim-surround` (mappings: `ys/ds/cs`),
   in visual mode, use `s/Z` is to be compatible with
   folding (mapping: `zf`) and `vim-surround` (mapping: `S`)

2. You need to define your leader key before defining any keymaps.
   Otherwise, keymap will not be correctly mapped with your leader key.

3. Note that `tree-sitter` will turn `syntax off`, and `pandoc-syntax` and `pandoc-rmarkdown`
   relies on the builtin `syntax`, so we need to load `config.pandoc` before we load `config.treesitter`

4. `vim-matchup` will (intentionally) hide the status-line if the matched pair are spanned
   over entire screen to show the other side of the pair.

# Discussion

1. It is recommended to use the mailing list `~northyear/nvim-devel@lists.sr.ht`.
2. Alternatively, you are also welcome to open a Github issue.
