; extends

; shout out to https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/ecma/injections.scm
(string (string_content) @sql
        (#lua-match? @sql "^%s*--sql")
        (#exclude_children! @sql))

(string (string_content) @sql
        (#lua-match? @sql "^%s*--SQL")
        (#exclude_children! @sql))

(string (string_content) @sql
        (#lua-match? @sql "^%s*/\\*.*sql.*\\*/")
        (#exclude_children! @sql))

(string (string_content) @sql
        (#lua-match? @sql "^%s*/\\*.*SQL.*\\*/")
        (#exclude_children! @sql))
