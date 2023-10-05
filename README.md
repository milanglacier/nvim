- [Features](#features)
- [Dependencies](#dependencies)
- [Keymaps](#keymaps)
- [Other Notes](#other-notes)
- [Discussion](#discussion)

# Features

- Built on modern devtools including LSP and treesitter. Treesitter delivers
  AST-level highlighting, text objects, and navigations, while LSP offers
  features like auto completion, go to definition and reference, and code
  diagnostics. By harnessing the power of both Ctags and LSP, this
  configuration brings a harmonic blend of old-school and modern development
  tools.

- Vim's exceptional text editing capabilities are further amplified by a host
  of powerful plugins focusing on text editing. (Remember it is pure text
  editing makes vim vim.)

- This configuration is specifically tailored toward data science toolsets,
  including python, R, SQL, Latex, rmarkdown, and quarto.

- Curated configuration working together with vscode thanks to
  [vscode-neovim](https://github.com/vscode-neovim/vscode-neovim). Access all
  the familiar neovim keybindings, including translations of equivalent
  commands in vscode, even when working with complex graphical content like
  Jupyter notebooks. And many neovim plugins, such as treesitter, can be
  embedded seamlessly in vscode, allowing for a smooth and uninterrupted
  workflow.

**NOTE**: If you plan to use this configuration with `vscode-neovim`, please
use the `windows/vscode` branch. If you wish to use neovim both in the terminal
and in vscode, we suggest creating two folders in `~/.config` or your specified
`$XDG_CONFIG` path. One is `~/.config/nvim`, which uses the default
configuration in the `master` branch, and the other is
`~/.config/vscode-neovim`, which uses the configuration in the `windows/vscode`
branch. This takes advantage of the `NVIM_APPNAME` feature in `nvim 0.9`. There
are two ways to ask `vscode-neovim` to use the configuration from the
`~/.config/vscode-neovim` folder as opposed to the default folder:

1. Create a bash script like the following:

```bash
#!bin/bash
NVIM_APPNAME=vscode-neovim nvim "$@"
```

Then, in vscode, set `vscode-neovim.neovimExecutablePaths.darwin` to
`your_path/to_the/bash_script`, changing darwin to match your system.

2. set `vscode-neovim.NVIM_APPNAME` to `vscode-neovim` in vscode settings.

# Dependencies

You will need a C compiler in order to build the `treesitter`
grammar. This can be either `gcc`, `clang`, or `msvc`. To ensure that
Neovim can find the compiler, make sure it is included in your `PATH`.

# Keymaps

Please read the README in the main branch for a comprehensive overview
of all keymaps specifications.

Basically most keymaps related to text-editing apply in
`vscode-neovim`. However, those keymaps related to LSP and neovim's
unique UI, are typically not applicable to `vscode-neovim`.

Furthermore, please consult `./lua/conf/vscode.lua` for a complete
list of keymaps specific for `vscode-neovim`.

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
