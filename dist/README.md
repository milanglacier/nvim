This directory houses various configuration files for tools that integrate with
my Neovim workflow.

### EFM Configuration

My [EFM](./efm-langserver/config.yaml) configuration file should be placed in
the path `~/.config/efm-langserver`.

### NixOS Configuration

These scripts configure Neovim in a NixOS environment:

1. **[neovim.nix](./nixos/neovim.nix):** This script creates an expression to
   build the Neovim program I use on NixOS. It allows successful building of
   Treesitter grammar with `lazy.nvim`, enabling seamless plugin management
   without delegating some plugins to Nix's control.

2. **[fhs.nix](./nixos/fhs.nix):** This script works with Neovim to run REPLs
   that typically require an FHS environment (such as `ipython`). Also see my
   config for [yarepl.nvim](../lua/plugins/cli_tools.lua) and my
   [patch](../patches/nixos/run-yarepl-under-fhs.patch) for running REPLs under
   nixos.

Please note that `neovim.nix` should be imported within the Home Manager
context, while `fhs.nix` should be part of the system module and imported
within the system environment context.
