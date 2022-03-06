1. Note that I use conda, so I set `let g:CONDA_PATHNAME = "your $CONDA_PREFIX"` at the start
of my `init.vim`. I found that source `conda init` in `.zshenv` would
make the start of nvim very slow, and I decide to not do it.

2. `devicons` should be the one that's last to be plugged in.

3. You should define `<leader>` key mappings before defining any keymaps that uses `<Leader>`
I use `<Space>` as `<Leader>`.

4. nerd font need to be installed. One of the font is provided in the repository.

5. A somewhat annoying things compared to vscode is that I cannot manually set the workspace folder.
As a workaround, I set `<leader>cd` to change working directory to current file,
and `<leader>cu` to move upward one level

6. One of the most annoying things in vim is how to define mnemonic key bindings
yet not leading to conflict/confusing. Especially for text objects,
the initials are often conflicted.

    As of now: some of the text objects are defined as:


    1. `aF`, `iF`, the (entire/inner) body of a function.
    2. `af`, `if`, the (entire/inner) call of a function (defined by `dsf.vim`).
    3. `aL`,`iL`, the (entire/inner) body of a loop
        (Note that I used L instead of l, as l is used in `targets.vim`
        to refer to the "last" object).
    4. `ae`, `ie`, the (entire/inner) body of an expression
        (similar to a call of a function, but `ae` is defined by `treesitter`,
        the twos behave a bit differently.)
    5. `ac`, `ic`, the (entire/inner) body of a if-else condition.
    6. `aC`,`iC`, the (entire/inner) body of a class.
    7. `aa`, `ia` as the (inner/entire) body of an argument.
        (this is defined by `targets.vim`),
        `ina`, `ila` refers to the inner part of the next/last argument.
    8. `a<Leader>a`, `i<Leader>a`, the same as `ia`, `aa`, but is defined via `treesitter`.

7. The jump-to defined via `treesitter` is a bit more
   confusing/non-coherent with text objects.

    1. `]l`, `]L`, `[l`, `[L` are used to jump-to previous/next start/end of a loop.
    2. `]c`, `]C`, `[c`, `[C` are used to jump-to previous/next start/end of a if-else condition.
    3. `]<Leader>c`, `]<Leader>C`, `[<Leader>c`, `[<Leader>C` are used to jump-to previous/next start/end of a if-else condition.
    4. `fF[]` is used to jump-between functions.
    5. `aA[]` is used to jump-between arguments.
    6. `eE[]` is used to jump-between function calls.

