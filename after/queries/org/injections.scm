; extends

(block
  parameter: (expr) @_lang
  (#match? @_lang "^R$")
  (contents) @injection.content
  (#set! injection.include-children)
  (#set! injection.language "r"))

 
