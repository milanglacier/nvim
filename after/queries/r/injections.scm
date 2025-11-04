; extends

; shout out to https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/ecma/injections.scm
(((string_content) @sql
                   (#lua-match? @sql "^%s*--sql")) @injection.content
 (#set! injection.language "sql"))

(((string_content) @sql
                   (#lua-match? @sql "^%s*--SQL")) @injection.content
 (#set! injection.language "sql"))

(((string_content) @sql
                   (#lua-match? @sql "^%s*/\\*.*sql.*\\*/")) @injection.content
 (#set! injection.language "sql"))

(((string_content) @sql
                   (#lua-match? @sql "^%s*/\\*.*SQL.*\\*/")) @injection.content
 (#set! injection.language "sql"))
