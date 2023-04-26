; extends

; shout out to https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/ecma/injections.scm
(string (string_content) @sql
    (#lua-match? @sql "^%s*SELECT")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*UPDATE")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*DELETE")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*CREATE")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*INSERT")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*REPLACE")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*DROP")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*ALTER")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*EXPLAIN")
    (#exclude_children! @sql))

(string (string_content) @sql
    (#lua-match? @sql "^%s*select.*from")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*update.*set")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*delete from.*where")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*create or replace table")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*create table")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*insert into.*values")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*replace into.*values")
    (#exclude_children! @sql))
(string (string_content) @sql
    (#lua-match? @sql "^%s*alter table")
    (#exclude_children! @sql))
