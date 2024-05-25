; extends

(block
  parameter: (expr) @_lang
  (#match? @_lang "^jupyter-[rR]$")
  (contents) @injection.content
  (#set! injection.include-children)
  (#set! injection.language "r"))

 
(block
  parameter: (expr) @_lang
  (#match? @_lang "^jupyter-[pP]ython$")
  (contents) @injection.content
  (#set! injection.include-children)
  (#set! injection.language "python"))
