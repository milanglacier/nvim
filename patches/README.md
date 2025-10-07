# Frequently Used Patches

This directory houses a collection of compact, commonly utilized patches
designed for various environments. These modifications are straightforward and
don't require separate branch management (unlike the `vscode` branch used for
`vscode-neovim` configurations). For organizational simplicity, all patches are
consolidated in this single directory.

- **`extended-jk-as-esc-waiting-period.patch`**: Extends the waiting period for
  interpreting `jk` as the `Esc` key. In environments with slower response times
  (e.g., under an SSH connection), the default `100ms` timeout may be
  insufficient to register the `Esc` key correctly when typing `jk` in quick
  succession. This patch adjusts the waiting period to accommodate such
  conditions.
