# Frequently Used Patches

This directory contains several small, commonly used patches designed for
various environments. These modifications are straightforward and do not need
the creation or maintenance of separate branches (in contrast to the `vscode`
branch used for `vscode-neovim` configurations). For convenience, these patches
are housed within this single directory.

- **`minimal-enabled-lsp.patch`**: Enables a minimal set of LSPs for usage.
- **`extended-jk-as-esc-waiting-period.patch`**: Extends the waiting period for
  interpreting `jk` as the `Esc` key. In environments with slower response times
  (e.g., under an SSH connection), the default `100ms` timeout may be
  insufficient to register the `Esc` key correctly when typing `jk` in quick
  succession. This patch adjusts the waiting period to accommodate such
  conditions.
