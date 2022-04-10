# Dependencies

* To use `markdown.preview.nvim`, you need to have `npm` and `yarn` installed.

* To use `lspconfig`, you need to have the corresponding lsp installed:
    * `R` support requires `R` package `R-language-server` installed.
    * `python` support requires `python` package `pylsp` installed.
    * `lua` support requires `lua-language-server` installed.
    * `latex` support requires `texlab` installed.
`chktex` (latex linter) requires `texlive` distro installed.
    * `vim script` support requires `vim-language-server` installed, which requires `npm` installed.
    * `c/cpp` support requires `clangd` installed.

* I use `homebrew` as package manager, so prebuild binaries provided by `homebrew`
    are automatically included in my `PATH`,
    including:
    * `npm` and `npm` installed packages.
    * `texlab`, `lua-language-server`.

* In general, `R`, `c/cpp` (if installed by `xcode-select install`), `texlive` are automatically included in the `PATH`.

* Some of the binaries provided by other package managers
are not automatically included in the `PATH`,
including `cargo`, `conda`.
    Then I create `lua/bin_path.lua` to manually specify
    the `PATHs` of them.

* Binaries' paths need to be manually specified:
    * if need to use debugger: `DAP.nvim`:
        * `python` (I use `conda`'s python)
    * if need to use REPL: `iron.nvim`:
        * `radian` (a R REPL)
        * `ipython`
    * if need to use `null-ls.nvim`:
        * `stylua` (Lua formatter)
        * `selene` (Lua linter)
        * `codespell` (spell checker)
        * `proselint` (English writing checker)

* Nerd font need to be installed. One of the font is provided in the repository.

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
    6. `aC`,`iC`, `a<leader>c`, `i<leader>c` the (entire/inner) body of a class.
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
    3. `]<Leader>c`, `]<Leader>C`, `[<Leader>c`, `[<Leader>C` are used to jump-to previous/next start/end of a class.
    4. `fF[]` is used to jump-between functions.
    5. `aA[]` is used to jump-between arguments.
    6. `eE[]` is used to jump-between function calls.

# Other Notes

8. You need to define your leader key before defining any keymaps.
    Otherwise, keymap will not be correctly mapped with your leader key.

8. Note that `tree-sitter` will turn `syntax off`, and `pandoc-syntax` and `pandoc-rmarkdown`
relies on the builtin `syntax`, so we need to load `config.pandoc` before we load `config.treesitter`

