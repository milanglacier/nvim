{
config,
lib,
pkgs,
...
}: {
    home.packages = with pkgs; [
        # build deps
        gcc
        gnumake
        tree-sitter
        # generic lsp
        efm-langserver
        # python
        basedpyright
        black
        # lua
        lua-language-server
        stylua
        # markdown
        prettierd
        vale
    ];
    programs = {
        neovim = {
            enable = true;
            package = pkgs.neovim-unwrapped;

            # Copied from https://github.com/ryan4yin/nix-config/blob/main/home/base/tui/editors/neovim/default.nix

            # These environment variables are needed to build and run binaries
            # with external package managers like mason.nvim.
            #
            # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim.
            # it will be set by nix-ld, so we do not need to set it here again.
            extraWrapperArgs = with pkgs; [
                # LIBRARY_PATH is used by gcc before compilation to search directories
                # containing static and shared libraries that need to be linked to your program.
                "--suffix"
                "LIBRARY_PATH"
                ":"
                "${lib.makeLibraryPath [stdenv.cc.cc zlib]}"

                # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
                # containing .pc files that describe the libraries that need to be linked to your program.
                "--suffix"
                "PKG_CONFIG_PATH"
                ":"
                "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [stdenv.cc.cc zlib]}"
            ];

        };
    };
}
