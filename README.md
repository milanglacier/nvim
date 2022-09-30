# Language with rich features support

`R`, `Python`, `latex`, `cpp`, `SQL`, `lua` is supported.
Including language server, auto-completion, formatter, linter.
Some linters/formatters use `null-ls` as an auxiliary media for CLI tools.

# Dependencies

I don't use nvim plugins like `nvim-lsp-installer`, because
I think the task of installing a third party CLI tools should
be handled by your system package manager, not by a CLI application itself,
so just install the denpendencies by yourself.

## `python`

1. `python*`.
2. `debugpy`: this module should be included by the `python*` specified above.
3. `ipython*`
4. `yapf*`
5. `flake8*`
6. `pylint*`
7. `pyright`

## `r`

1. `r-language-server`: this should be installed by the `r` included in the `PATH`.
2. `radian*`

## `lua`

1. `lua-language-server`
2. `stylua`
3. `selene`

## `vimscript`

18. `vim-language-server*`

## `markdown`

30. `yarn`: this is required to install `markdown-previem.nvim`.
31. `prettierd*`
32. `glow`

## `sql`

20. `sqls*`
21. `sqlfluff`

## `bash`

24. `bash-language-server`
25. `shellcheck`

## `latex`

29. `texlab`
30. `chktex`: `texlive` ships with this, so no need to install itself by yourself.
31. `latexindent`: while `texlive` ships this for you, `perl` shipped by macOS cannot
    run this program, so I use a `homebrew` installed `latexindent` instead.

## `cpp`

1. `clangd`: Apple's `xcode` command line tools ship this for you.

## general purpose

26. `proselint`
27. `codespell`
28. `universal-ctags`

# Text Obj mappings

6. One of the most annoying things in vim is how to define mnemonic key bindings
    yet not leading to conflict/confusing. Especially for text objects,
    the initials are often conflicted.

        As of now: some of the text objects are defined as:

        1. `af`, `if`, the (entire/inner) body of a function.
        3. `al`,`il`, the (entire/inner) body of a loop
            (Note that I used l so I changed `targets.vim`'s config
            to refer `N` to as the "previous" object).
        4. `ae`, `ie`, the (entire/inner) body of an expression.
            (when in `rmd`, the functionality is provided by dsf,
            otherwise it is provided by treesitter,
            the twos behave a bit differently.)
        5. `ac`, `ic`, the (entire/inner) body of a if-else condition.
        6. `aC`,`iC`, `a<leader>c`, `i<leader>c`, `ak`, `ik` the (entire/inner) body of a class.
        7. `aa`, `ia` as the (inner/entire) body of an argument.
            (this is defined by `targets.vim`),
            `ina`, `iNa` refers to the inner part of the next/last argument.
        8. `a<Leader>a`, `i<Leader>a`, the same as `ia`, `aa`, but is defined via `treesitter`.
        9. `latex` specific textobj is defined via `<localleader>`:
            1. `<localleader>f` refers to a frame (no `a`/`i` prefix).
            2. `<localleader>s` refers to a statement.
            3. `<localleader>b` refers to a block.
            3. `<localleader>c` refers to a class (section/subsection).
        10. `<Leader>T` provides a way to select textobjs
        based on labels (like easy-motion or sneak).

7. The jump-to defined via `treesitter` is a bit more
    confusing/non-coherent with text objects.

    1. `]l`, `]L`, `[l`, `[L` are used to jump-to previous/next start/end of a loop.
    2. `]c`, `]C`, `[c`, `[C` are used to jump-to previous/next start/end of a if-else condition.
    3. `]<Leader>c`, `]<Leader>C`, `[<Leader>c`, `[<Leader>C`, `[]kK` are used to jump-to previous/next start/end of a class.
    4. `fF[]` is used to jump-between functions.
    5. `aA[]` is used to jump-between arguments.
    6. `eE[]` is used to jump-between function calls.

# Other Notes

8. `vim-sneak` defines relatively inconsistent behavior: in normal mode,
   use `s/S`, in operator pending mode, use `z/Z`, in visual mode,
   use $s/Z$. In normal mode, default mapping $s$ is replaced.
   In op mode, use `z/Z` is to be compatible with `vim-surround` (mappings: `ys/ds/cs`),
   in visual mode, use `s/Z` is to be compatible with
   folding (mapping: `zf`) and `vim-surround` (mapping: `S`)

9. You need to define your leader key before defining any keymaps.
   Otherwise, keymap will not be correctly mapped with your leader key.

10. Note that `tree-sitter` will turn `syntax off`, and `pandoc-syntax` and `pandoc-rmarkdown`
    relies on the builtin `syntax`, so we need to load `config.pandoc` before we load `config.treesitter`

11. `vim-matchup` will (intentionally) hide the status-line if the matched pair are spanned
    over entire screen to show the other side of the pair.
