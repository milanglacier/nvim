; extends

; shout out to https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/ecma/injections.scm
(string (string_content) @sql
        (#lua-match? @sql "^%s*--sql")
        ((#set! injection.language "sql")))

(string (string_content) @sql
        (#lua-match? @sql "^%s*--SQL")
        ((#set! injection.language "sql")))

(string (string_content) @sql
        (#lua-match? @sql "^%s*/\\*.*sql.*\\*/")
        ((#set! injection.language "sql")))

(string (string_content) @sql
        (#lua-match? @sql "^%s*/\\*.*SQL.*\\*/")
        ((#set! injection.language "sql")))
